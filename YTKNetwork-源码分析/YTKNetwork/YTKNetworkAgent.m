//
//  YTKNetworkAgent.m
//
//  Copyright (c) 2012-2014 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "YTKNetworkAgent.h"
#import "YTKNetworkConfig.h"
#import "YTKNetworkPrivate.h"
#import "AFDownloadRequestOperation.h"
#import "AFNetworking.h"

@implementation YTKNetworkAgent
{
    AFHTTPRequestOperationManager *_manager;
    YTKNetworkConfig *_config;       // 网络配置类
    NSMutableDictionary<NSString *, YTKBaseRequest *> *_requestsRecord; // 用于网络请求缓存的
    dispatch_queue_t _requestProcessingQueue;   // 请求队列
}

+ (YTKNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _config = [YTKNetworkConfig sharedInstance];
        _manager = [AFHTTPRequestOperationManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.operationQueue.maxConcurrentOperationCount = 4; // 设置最大并发数
        _manager.securityPolicy = _config.securityPolicy; // 这是安全策略
    }
    return self;
}

//  组合url
- (NSString *)buildRequestUrl:(YTKBaseRequest *)request {
    NSString *detailUrl = [request requestUrl]; // 后半部分
    
//    这里多了个判断
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    // filter url  添加参数
    NSArray *filters = [_config urlFilters];
    for (id<YTKUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
    }

    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            // 当某个url使用cdn的时候   （适用的情况是 假设每个 url使用不同的cdn的情况）
            baseUrl = [request cdnUrl];
        } else {
    //      使用默认的cdn
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    // 组合完成
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}


// 添加网络请求 ————>>>>> 处理公共逻辑

/**
 
 */
- (void)addRequest:(YTKBaseRequest *)request {
    YTKRequestMethod method = [request requestMethod]; // get 还是 post方法
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument; // 请求参数
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];

    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == YTKRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == YTKRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }

    requestSerializer.timeoutInterval = [request requestTimeoutInterval];

    // if api need server username and password
    // 当请求需要服务器 账号 和 密码的时候
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                          password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }

    // if api need add custom value to HTTPHeaderField
    //   设置公共的请求头
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        // 这里以这种 allkeys的方式是因为设置请求头 是以key - value的形式设置的，所以不用分顺序
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                YTKLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }

    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        
    //  自定义请求
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:customUrlRequest];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
        request.requestOperation = operation;
        operation.responseSerializer = _manager.responseSerializer;
        [_manager.operationQueue addOperation:operation];
    } else {
        if (method == YTKRequestMethodGet) {
            // 断点续传
            if (request.resumableDownloadPath) {
                // add parameters to URL;
                NSString *filteredUrl = [YTKNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];

                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
                                                                                                 targetPath:request.resumableDownloadPath shouldResume:YES];
                // 设置断点续传的 blcok 
                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
                request.requestOperation = operation;
                
                // 添加到线程组中去
                [_manager.operationQueue addOperation:operation];
            } else {
                request.requestOperation = [self requestOperationWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodPost) {
            if (constructingBlock != nil) {
                NSError *serializationError = nil;
                NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:&serializationError];
                if (serializationError) {
                    dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
                        [self handleRequestResult:nil];
                    });
                } else {
                    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [self handleRequestResult:operation];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self handleRequestResult:operation];
                    }];
                    request.requestOperation = operation;
                    [_manager.operationQueue addOperation:operation];
                }
            } else {
                request.requestOperation = [self requestOperationWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodHead) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPut) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodDelete) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPatch) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:url parameters:param];
        } else {
            YTKLog(@"Error, unsupport method type");
            return;
        }
    }

    // Set request operation priority
    //   设置操作有限级
    switch (request.requestPriority) {
        case YTKRequestPriorityHigh:
            request.requestOperation.queuePriority = NSOperationQueuePriorityHigh;
            break;
        case YTKRequestPriorityLow:
            request.requestOperation.queuePriority = NSOperationQueuePriorityLow;
            break;
        case YTKRequestPriorityDefault:
        default:
            request.requestOperation.queuePriority = NSOperationQueuePriorityNormal;
            break;
    }

    // retain operation
    YTKLog(@"Add request: %@", NSStringFromClass([request class]));
    
    // 添加记录
    [self addOperation:request];
}


// 取消请求
- (void)cancelRequest:(YTKBaseRequest *)request {
    [request.requestOperation cancel];
    [self removeOperation:request.requestOperation];
    [request clearCompletionBlock];
}

// 取消所有请求
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        YTKBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

//
- (BOOL)checkResult:(YTKBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}


    // 处理 请求结果 （包括缓存，回传等json数据的处理）
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    YTKBaseRequest *request = _requestsRecord[key];
    
    YTKLog(@"Finished Request: %@", NSStringFromClass([request class])); // 打印日志 -> 已经完成
    
    if (request) {
        // statusCode >= 200 && statusCode <=299
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request toggleAccessoriesWillStopCallBack]; // 处理指示器
            [request requestCompleteFilter]; // 处理缓存相关的
            
            // 处理代理相关
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
        //         回调 request
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            
            // ？？
            [request toggleAccessoriesDidStopCallBack];
        } else {
            YTKLog(@"Request %@ failed, status code = %ld",
                     NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            
            // 处理失败
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            // 处理失败 回调
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
    [self removeOperation:operation]; // 去除请求缓存记录
    //
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

// 添加请求记录
- (void)addOperation:(YTKBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}


- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    
    // 添加线程锁
    @synchronized(self) {
        // 从记录的字典中 移除 请求记录
        [_requestsRecord removeObjectForKey:key];
    }
    YTKLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}


//
- (AFHTTPRequestOperation *)requestOperationWithHTTPMethod:(NSString *)method
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
    //        如果没有所在线程的话，就回主线程去处理数据
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil];
        });
        return nil;
    }

    //   配置 operation 线程操作
    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 处理 这个请求
        [self handleRequestResult:operation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation];
    }];

    // 添加到线程组
    [_manager.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)requestOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    
    //   设置 operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = _manager.responseSerializer;
    operation.shouldUseCredentialStorage = _manager.shouldUseCredentialStorage;
    operation.credential = _manager.credential;
    operation.securityPolicy = _manager.securityPolicy;

    // 设置 operation 操作 和 线程组相关的
    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = _manager.completionQueue;
    operation.completionGroup = _manager.completionGroup;

    return operation;
}

@end
