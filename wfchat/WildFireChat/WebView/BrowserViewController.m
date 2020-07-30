//
//  BrowserViewController.m
//  WKWebViewDemo
//
//  Created by 赵伟 on 2020/7/15.
//  Copyright © 2020 赵伟. All rights reserved.
//

#import "BrowserViewController.h"
#import <WebKit/WebKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "WFCConfig.h"

#define KS_APP_VERSION      [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]



@interface BrowserViewController ()<WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) NSString *basePath;

@property (nonatomic, strong) WKWebView * webView;

@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;   //返回按钮
@property (nonatomic, strong) UIBarButtonItem *closeBarButtonItem;  //关闭按钮
@property (nonatomic, strong) UIBarButtonItem *moreBarButtonItem;  //右侧按钮

@property(nonatomic, assign) BrowserSourceType * sourceType;

/**
 返回按钮点击事件
 */
- (void)kswv_backBarButtonItemHandler;

/**
 关闭按钮点击事件
 */
- (void)kswv_closeBarButtonItemHandler;


/**
 更多按钮点击事件
 */
- (void)kswv_moreBarButtonItemHandler;


@end

@implementation BrowserViewController


#pragma mark - Get

- (WKWebView *)webView {
    if (_webView == nil) {

        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
//         WKUserContentController *userContentController = self.webView.configuration.userContentController;
//        configuration.applicationNameForUserAgent = @"HaoBan 1.0";
        configuration.userContentController = userContentController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
//        _webView.scrollView.header = [[HBHeaderRefreshView alloc] initWithDelegate:self];
        
       
        @try {
           
            [userContentController addScriptMessageHandler:self name:@"configMenus"];
            [userContentController addScriptMessageHandler:self name:@"displayMenusButton"];
            [userContentController addScriptMessageHandler:self name:@"openShareAlert"];
            [userContentController addScriptMessageHandler:self name:@"payment"];
            [userContentController addScriptMessageHandler:self name:@"log"];
            [userContentController addScriptMessageHandler:self name:@"goBack"];
            [userContentController addScriptMessageHandler:self name:@"autoShared"];
            [userContentController addScriptMessageHandler:self name:@"sendShared"];
            [userContentController addScriptMessageHandler:self name:@"openChatSession"];
            [userContentController addScriptMessageHandler:self name:@"openLogin"];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    return _webView;
}

- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[NJKWebViewProgressView alloc] init];
        _progressView.progressBarView.backgroundColor = kMainColor;
    }
    return _progressView;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (_backBarButtonItem == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"nav_back"];
        //        image = [image kswv_imageWithTintColor:[UIColor blueColor]];
        [button setImage:image forState:UIControlStateNormal];
//        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button setTintColor:[UIColor blackColor]];
        [button addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [button setFrame:CGRectMake(0, 0, 44, 44)];

        _backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _backBarButtonItem;
}

- (void)backButtonHandler:(id)sender {
    [self kswv_backBarButtonItemHandler];
}

- (UIBarButtonItem *)closeBarButtonItem {
    if (_closeBarButtonItem == nil) {
        _closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                               style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(kswv_closeBarButtonItemHandler)];
        _closeBarButtonItem.tintColor = kMainColor;
    }
    return _closeBarButtonItem;
}

- (UIBarButtonItem *)moreBarButtonItem {

    if (_moreBarButtonItem == nil) {
//        _moreBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
//                                                            target:self
//                                                            action:@selector(kswv_moreBarButtonItemHandler)];
//        _moreBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"分享_01.png"] style:UIBarButtonItemStylePlain target:self action:@selector(kswv_moreBarButtonItemHandler)];
        _moreBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(kswv_moreBarButtonItemHandler)];
        _moreBarButtonItem.tintColor = kMainColor;
    }
    return _moreBarButtonItem;
}


#pragma mark - Init

+ (instancetype)createInstanceWithURL:(NSURL *)URL withType:(BrowserSourceType)type{
    return [[BrowserViewController alloc] initWithURL:URL withType:type];
}

- (instancetype)initWithURL:(NSURL *)URL withType:(BrowserSourceType)type{
    self = [super init];
    if (self) {
        self.URL = URL;
        self.sourceType = type;
    }
    return self;
}

- (void)dealloc {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.progressView removeFromSuperview];
//    [self removeObserver:self forKeyPath:kUserLoginSuccessNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setProgressView:nil];
    @try {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"URL"];
    } @catch (NSException *exception) {
    }
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
}


#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString * webToken = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedWebToken];
    self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.URL.absoluteString]];
    
    [self.view addSubview:self.webView];

    
    self.navigationController.navigationBar.tintColor = kMainColor;
    if (self.sourceType != BrowserSourceWork) {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
        self.webView.frame = self.view.bounds;
    }else {
        self.webView.frame = CGRectMake(0, 0, kScreenWidth, self.view.bounds.size.height - kTabBarHeight);
    }
    
    if (self.URL == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
        self.URL = [NSURL fileURLWithPath:path];
    }
    
    self.webView.allowsBackForwardNavigationGestures = YES;
    
    
    NSString *str = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleExecutable"], KS_APP_VERSION];
    
    [self.webView setValue:str forKey:@"applicationNameForUserAgent"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    
    self.basePath = self.URL.path;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLoginSuccessed) name:kUserLoginSuccessNotification object:nil];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];

    if (parent == nil) {
        @try {
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"configMenus"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"displayMenusButton"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"openShareAlert"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"payment"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"log"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"goBack"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"autoShared"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"sendShared"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"openChatSession"];
            [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"openLogin"];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}



/**
 更多按钮点击事件
 */
- (void)kswv_moreBarButtonItemHandler {
    
    //判断是否登陆
//    if ([HBUserToolkit shared].isLogin == YES) {
//        //登录状态
//        [self.shareAlertView showWindow:self.menus];
//    } else {
//        //未登录状态
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[HBPhoneNumLoginViewController new]];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//
//    }
}

/**
 返回按钮点击事件
 */
- (void)kswv_backBarButtonItemHandler {
    
    if (self.backBarButtonItem == nil) {
        return;
    }
    if ([self.basePath isEqualToString:self.webView.URL.path]) {
        return [self kswv_closeBarButtonItemHandler];
    }
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        if (self.sourceType == BrowserSourceWork) {
            self.navigationItem.leftBarButtonItems = @[self.backBarButtonItem];
        } else {
            self.navigationItem.leftBarButtonItems = @[self.backBarButtonItem, self.closeBarButtonItem];
        }
        
    } else {
        [self kswv_closeBarButtonItemHandler];
    }
}

/**
 关闭按钮点击事件
 */
- (void)kswv_closeBarButtonItemHandler {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress >= self.progressView.progress) {
            [self.progressView setProgress:progress animated:YES];
        } else {
            [self.progressView setProgress:progress animated:NO];
        }
    }else if ([keyPath isEqualToString:@"URL"]){
        // 可以在这里进行拦截并做相应的处理
        NSLog(@"URL------%@",_webView.URL.absoluteString);
        if (self.sourceType == BrowserSourceWork) {
            if ([_webView.URL.absoluteString isEqualToString:[NSString stringWithFormat:@"%@",AppWebWork]]) {
                [self.navigationItem.leftBarButtonItem.customView setHidden:YES];
            } else {
                self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
                [self.navigationItem.leftBarButtonItem.customView setHidden:NO];
            }
        }
    }
}

- (void) onUserLoginSuccessed {
    NSString * webToken = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedWebToken];
    self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.URL.absoluteString,webToken]];
    [self.webView reload];
}

- (void)updateFrameOfProgressView {
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView.frame = barFrame;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@" ---- %@", navigationResponse.response);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"+++ %@",navigationAction.request.URL);
    NSLog(@"+++ %@", navigationAction.request.allHTTPHeaderFields);
    
    if ([[NSString stringWithFormat:@"%@",navigationAction.request.URL] rangeOfString:@"comfirmPay"].location !=NSNotFound ) {
        NSLog(@"没有登录");
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[HBLoginViewController new]];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    
//    if (navigationAction.navigationType == WKNavigationTypeFormSubmitted) {
//        return decisionHandler(WKNavigationActionPolicyCancel);
//    }
    if([[NSString stringWithFormat:@"%@",navigationAction.request.URL] rangeOfString:@"tel:"].location !=NSNotFound) {
        //包含电话号码
        //拨打电话
        NSLog(@"yes");
        KS_DISPATCH_MAIN_QUEUE(^{
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        });
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        //界面跳转
        NSLog(@"no");
//        navigationAction.request
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

//- (void)cleanCacheWithCompletionHandler:(void (^)(void))completionHandler {
//
//    if ([WKWebsiteDataStore class]) {
//
//        NSSet *websiteDataTypes = [NSSet setWithArray:@[ WKWebsiteDataTypeDiskCache,
//                                                         WKWebsiteDataTypeMemoryCache,
//                                                         WKWebsiteDataTypeOfflineWebApplicationCache]];
//        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
//        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:completionHandler];
//    } else {
//
//        completionHandler();
//    }
//}


//准备加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
//    self.showSharedMenus = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    //显示加载状态
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (self.navigationController && self.progressView.superview != self.navigationController.navigationBar) {
        [self updateFrameOfProgressView];
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
    //重置加载进度
    [self.progressView setProgress:0];
    [self.progressView setProgress:0.05f animated:YES];
}

//开始加载
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //KVO监听加载进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
}

//完成加载
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
//    self.webView.scrollView.header.state = KSRefreshViewStateDefault;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.title = webView.title;
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    } @catch (NSException * exception) {
        
    }
    
    NSString *script = @"try { tsingda.event.emit('TsingdaJSBridgeEventOnReady'); } catch(e) {}";
    [self.webView evaluateJavaScript:script completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        
    }];
//    [self.webView evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML"
//                   completionHandler:^(id res, NSError *error) {
//        NSLog(@"%@", res);
//    }];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.title = webView.title;
    NSLog(@"加载失败");
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    } @catch (NSException *exception) {
        
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        completionHandler();
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        completionHandler(NO);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        completionHandler(YES);
    }];
    [alert addAction:okCancel];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"configMenus"]) {
        [self JSBridgeConfigMenusdidReceiveValues:[message body]];
    } else if ([message.name isEqualToString:@"displayMenusButton"]) {
//        self.showSharedMenus = [message.body boolValue];
//        if (!self.showSharedMenus) {
//            self.moreBarButtonItem = nil;
//        }
    } else if ([message.name isEqualToString:@"openShareAlert"]) {
//        [self.shareAlertView showWindow:self.menus];
    } else if ([message.name isEqualToString:@"payment"]) {
//        [self payment:[message body]];
    } else if ([message.name isEqualToString:@"log"]) {
        NSLog(@"%@", [message body]);
    } else if ([message.name isEqualToString:@"goBack"]) {
        [self kswv_closeBarButtonItemHandler];
    } else if ([message.name isEqualToString:@"openChatSession"]) {
        //联系商户
        [self ContactTheMerchant:[message body]];
    } else if ([message.name isEqualToString:@"openLogin"]) {
        [self openLoginHandler];
    }
}

- (void)JSBridgeConfigMenusdidReceiveValues:(NSArray *)values {

//    [self.menus removeAllObjects];
    
    BOOL isAgency = true;
//    if ([HBUserToolkit shared].isLogin && ![NSString isNullOrEmpty:[HBUserToolkit shared].userDetailsInfoModel.agentId]) {
//        isAgency = YES;
//    }
    for (int i = 0; i < values.count; i++) {
        NSString *str = [values objectAtIndex:i];
        if ([str isEqualToString:@"WeChatSession"] ||
            [str isEqualToString:@"WeChatTimeline"] ||
            [str isEqualToString:@"IntraoralFriend"] ||
            [str isEqualToString:@"IntraoralSession"] ||
            [str isEqualToString:@"AgencyHomePage"]) {
//            if (![self.menus containsObject:str]) {
//                if ([str isEqualToString:@"AgencyHomePage"] && !isAgency) {
//                    continue;
//                } else {
//                    [self.menus addObject:str];
//                }
//            }
        }
    }

    self.navigationItem.rightBarButtonItem = self.moreBarButtonItem;
    
//    if (self.menus.count > 0 && self.showSharedMenus) {
//        self.navigationItem.rightBarButtonItem = self.moreBarButtonItem;
//    } else {
//        self.navigationItem.rightBarButtonItem = nil;
//    }
}

//联系商户
-(void)ContactTheMerchant:(NSDictionary *)info {
    
    // 跳转到聊天界面
    // 如果之前有聊天 或者 之前没有聊天
    // 给店主发送商品信息
    //info 包含内容  需要的
    
//    [[TSIMKitManager shared] asyncFetchUserToken:@"" nickname:@"" avatar:@"" result:^(id  _Nullable responseObject, NSError * _Nullable error) {
//        if ([[responseObject objectForKey:@"code"]integerValue] == 200) {
//            KS_DISPATCH_MAIN_QUEUE(^{
//                NSDictionary *info = [responseObject objectForKey:@"info"];
//                NSString *accid = [info objectForKey:@"accid"];
//                NIMSession *session = [NIMSession session:accid type:NIMSessionTypeP2P];
//                //获取打开聊天界面的类名
//                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//                [center postNotificationName:@"__TSIM_NOTIFICATION_OPEN_SESSION" object:session];
//            });
//        }
//    }];
    
    
    //    //构造消息
    //    Attachment * attachment = [Attachment new];
    //    attachment.type = @"10003";//联系店主
    //    attachment.imageUrl = @"11111";
    //    attachment.title = @"题目";
    //    attachment.desc = @"描述信息";
    //
    //    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    //    customObject.attachment = attachment;
    //    NIMMessage *message               = [[NIMMessage alloc] init];
    //    message.messageObject             = customObject;
    //    message.apnsContent = @"分享了一个内容";
    //    NSMutableDictionary * dic = [NSMutableDictionary new];
    //    [dic setObject:dataItem.accId forKey:@"session"];
    //    [dic setObject:@(session.sessionType) forKey:@"sessionType"];
    //    message.from = session.sessionId;
    //    message.apnsPayload = dic;
    //    //发送消息
    //    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
    
}

- (void)openLoginHandler {
//    UIViewController *login = [UIViewController new];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
//    [self presentViewController:nav animated:YES completion:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login" message:@"native login" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        
    }];
    [alert addAction:okCancel];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

/**
 * @brief 主线程运行block语句块
 */
CG_INLINE void KS_DISPATCH_MAIN_QUEUE(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
