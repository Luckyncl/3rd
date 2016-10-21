

#import "YTKNetworkConfig.h"


#import "YTKRequest.h"  

#import "YTKNetworkPrivate.h"

@interface YTKRequest()

@property (strong, nonatomic) id cacheJson;

@end

@implementation YTKRequest
{
    BOOL _dataFromCache;  // 数据是不是从缓存中取得的
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}


// 缓存版本 （）
- (long long)cacheVersion {
    return 0;
}


// Sensitive 敏感的
- (id)cacheSensitiveData {
    return nil;
}

// 检测文件路径  （不存在的话就创建）
- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
  
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        // 如果不存在的话，就创建一个文件夹
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            
            //
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        YTKLog(@"create cache directory failed, error = %@", error);
    } else {
        [YTKNetworkPrivate addDoNotBackupAttribute:path];
    }
}

    //  缓存路径
- (NSString *)cacheBasePath {

    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];

    // filter cache base path
    //
    NSArray<id<YTKCacheDirPathFilterProtocol>> *filters = [[YTKNetworkConfig sharedInstance] cacheDirPathFilters];
    if (filters.count > 0) {
        for (id<YTKCacheDirPathFilterProtocol> f in filters) {
            // 实现缓存协议
            path = [f filterCacheDirPath:path withRequest:self];
        }
    }

    //
    [self checkDirectory:path];
    return path;
}

    // 创建网络缓存的文件名 （md5加密过的）
- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl]; // 取得url的后半部分
    NSString *baseUrl = [YTKNetworkConfig sharedInstance].baseUrl;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    
    //  根据版本号缓存数据 
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@ Sensitive:%@",
                                                        (long)[self requestMethod], baseUrl, requestUrl,
                                                        argument, [YTKNetworkPrivate appVersionString], [self cacheSensitiveData]];
    
    NSString *cacheFileName = [YTKNetworkPrivate md5StringFromString:requestInfo];
    return cacheFileName;
}



// 创建缓存文件全路径（没有版本）
- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}


// 带版本的缓存文件全路径
- (NSString *)cacheVersionFilePath {
    NSString *cacheVersionFileName = [NSString stringWithFormat:@"%@.version", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheVersionFileName];
    return path;
}



//  缓存文件大小
- (long long)cacheVersionFileContent {
    NSString *path = [self cacheVersionFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        
        NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return [version longLongValue];
    } else {
        return 0;
    }
}

  // 缓存文件存在时间
- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        YTKLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }

    // 创建时间 减去 现在的时间 然后取反
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}



//  开始发送请求，实际上就是添加到 operation
- (void)start {
    if (self.ignoreCache) {
        [super start];
        return;
    }

    // check cache time
    if ([self cacheTimeInSeconds] < 0) {
        [super start];
        return;
    }

    // check cache version
    long long cacheVersionFileContent = [self cacheVersionFileContent];
    if (cacheVersionFileContent != [self cacheVersion]) {
        [super start];
        return;
    }

    // check cache existance
    NSString *path = [self cacheFilePath]; // 缓存文件路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        [super start];
        return;
    }

    // check cache time
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        [super start];
        return;
    }

    // load cache
    //  没有缓存数据的话，就发送请求
    _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_cacheJson == nil) {
        [super start];
        return;
    }

    // 有缓存数据当然要 设置 标识喽
    _dataFromCache = YES;
    [self requestCompleteFilter];
    YTKRequest *strongSelf = self;
    
    // 这里有一个问题， request的代理是 谁？？
    [strongSelf.delegate requestFinished:strongSelf];
    
    
    // 回传
    if (strongSelf.successCompletionBlock) {
        strongSelf.successCompletionBlock(strongSelf);
    }
    [strongSelf clearCompletionBlock];
}


// 开始请求，没有缓存
- (void)startWithoutCache {
    [super start];
}



// 获得缓存的json数据
- (id)cacheJson {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }
}

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

// 检测 缓存数据的 --->> 版本
- (BOOL)isCacheVersionExpired {
    // check cache version
    long long cacheVersionFileContent = [self cacheVersionFileContent];
    if (cacheVersionFileContent != [self cacheVersion]) {
        return YES;
    } else {
        return NO;
    }
}


//  返回 解析完的 json 数据
- (id)responseJSONObject {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        return [super responseJSONObject];
    }
}

#pragma mark - Network Request Delegate

    //
- (void)requestCompleteFilter {
    [super requestCompleteFilter];
    [self saveJsonResponseToCacheFile:[super responseJSONObject]];
}

// 手动将其他请求的JsonResponse写入该请求的缓存
// 比如AddNoteApi, UpdateNoteApi都会获得Note，且其与GetNoteApi共享缓存，可以通过这个接口写入GetNoteApi缓存

    // 使用 归解档 来保存 json 数据
- (void)saveJsonResponseToCacheFile:(id)jsonResponse {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = jsonResponse;
        if (json != nil) {
            [NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]];
            [NSKeyedArchiver archiveRootObject:@([self cacheVersion]) toFile:[self cacheVersionFilePath]];
        }
    }
}

@end
