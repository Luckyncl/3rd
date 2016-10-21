#import "ViewController.h"
#import "YTKBatchRequest.h"
#import "YTKChainRequest.h"
#import "GetImageApi.h"
#import "GetUserInfoApi.h"
#import "RegisterApi.h"
#import "YTKBaseRequest+AnimatingAccessory.h"


#import "MyTestRequest.h"
@interface ViewController ()<YTKChainRequestDelegate>

@end

@implementation ViewController

/// Send batch request
//   发送批量的请求

//  适用于一个页面 显示的时候有多个接口的情况 ，并且需要都请求成功的时候，处理json数据
- (void)sendBatchRequest {
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"1.jpg"];
    GetImageApi *b = [[GetImageApi alloc] initWithImageId:@"2.jpg"];
    GetImageApi *c = [[GetImageApi alloc] initWithImageId:@"3.jpg"];
    GetUserInfoApi *d = [[GetUserInfoApi alloc] initWithUserId:@"123"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[a, b, c, d]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        NSLog(@"succeed");
        NSArray *requests = batchRequest.requestArray;
        GetImageApi *a = (GetImageApi *)requests[0];
        GetImageApi *b = (GetImageApi *)requests[1];
        GetImageApi *c = (GetImageApi *)requests[2];
        GetUserInfoApi *user = (GetUserInfoApi *)requests[3];
        // deal with requests result ...
        NSLog(@"%@, %@, %@, %@", a, b, c, user);
    } failure:^(YTKBatchRequest *batchRequest) {
        NSLog(@"failed");
    }];
}


// 用于处理 网络请求有依赖关系的 情况。
- (void)sendChainRequest {
    RegisterApi *reg = [[RegisterApi alloc] initWithUsername:@"username" password:@"password"];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:reg callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        RegisterApi *result = (RegisterApi *)baseRequest;
        NSString *userId = [result userId];
        GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
        [chainRequest addRequest:api callback:nil];
        
    }];
    chainReq.delegate = self;
    // start to send request
    [chainReq start];
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest {
    // all requests are done
    
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request {
    // some one of request is failed
}






// 添加缓存数据的用法
- (void)loadCacheData {
    NSString *userId = @"1";
    GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
    if ([api cacheJson]) {
        NSDictionary *json = [api cacheJson];
        NSLog(@"json = %@", json);
        // show cached data
    }

    api.animatingText = @"正在加载";
    api.animatingView = self.view;

    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
       
        NSLog(@"update ui");
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"failed");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testSendRequest];
}




-(void)testSendRequest
{
    MyTestRequest *myTestRequest = [[MyTestRequest alloc] init];
    
    
//    myTestRequest.animatingText = @"ssss";

    [myTestRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"请求成功--- json == %@",request.responseJSONObject);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"请求失败");
    }];


}


//- (void)loginButtonPressed:(id)sender {
//    NSString *username = self.UserNameTextField.text;
//    NSString *password = self.PasswordTextField.text;
//    if (username.length > 0 && password.length > 0) {
//        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
//        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//            // 你可以直接在这里使用 self
//            NSLog(@"succeed");
//            
//        } failure:^(YTKBaseRequest *request) {
//            // 你可以直接在这里使用 self
//            NSLog(@"failed");
//        }];
//    }
//}
//

//注意：你可以直接在block回调中使用 `self`，不用担心循环引用。因为 YTKRequest 会在执行完 block 回调之后，将相应的 block 设置成 nil。从而打破循环引用。
//



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
