//
//  WFCLoginViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/7/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCLoginViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "AppDelegate.h"
#import "WFCBaseTabBarController.h"
#import "MBProgressHUD.h"
#import "UILabel+YBAttributeTextTapAction.h"

#import "AppService.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "WFCUConfigManager.h"
#import "WFCPrivacyViewController.h"
#import "UIView+gradient.h"


//是否iPhoneX YES:iPhoneX屏幕 NO:传统屏幕
#define kIs_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0f ||[UIScreen mainScreen].bounds.size.height == 896.0f )

#define kStatusBarAndNavigationBarHeight (kIs_iPhoneX ? 88.f : 64.f)

#define  kTabbarSafeBottomMargin        (kIs_iPhoneX ? 34.f : 0.f)

#define HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]


@interface WFCLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIView  * containerView;


@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UIButton *loginBtn;

@property (strong, nonatomic) UIView *userNameLine;
@property (strong, nonatomic) UIView *passwordLine;

@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@property (nonatomic, strong) UILabel *privacyLabel;
@end

@implementation WFCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"login_background"];
    backgroundImageView.userInteractionEnabled = true;
    [self.view addSubview:backgroundImageView];
    
    
    CGFloat x = (self.view.bounds.size.width - 271) / 2;
    UIImageView * headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(x, 60, 271, 28)];
    headerImage.image = [UIImage imageNamed:@"login_header"];

    [self.view addSubview:headerImage];
    
    
    NSString *savedName = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedName];
   
    CGRect bgRect = self.view.bounds;
    CGFloat paddingEdge = 15;
    CGFloat inputHeight = 50;
    CGFloat hintHeight = 26;
    CGFloat topPos = 26;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(15, 141, bgRect.size.width - 30, (bgRect.size.width - 30) * 1.1)];
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.masksToBounds = true;
    self.containerView.backgroundColor = [UIColor whiteColor];
    [backgroundImageView addSubview:self.containerView];
    
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingEdge, topPos, 100, hintHeight)];
    [hintLabel setText:@"账户名"];
    hintLabel.textAlignment = NSTextAlignmentLeft;
    hintLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
    
    topPos += hintHeight + 5;
    
    UIView *userNameContainer = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos, self.containerView.bounds.size.width - 2 * paddingEdge, inputHeight)];
    
    
    self.userNameLine = [[UIView alloc] initWithFrame:CGRectMake(0, inputHeight - 1, userNameContainer.frame.size.width, 1.f)];
    self.userNameLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, userNameContainer.frame.size.width - 20, inputHeight - 1)];
    self.userNameField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.userNameField.placeholder = @"请输入您的账户名";
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypePhonePad;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    topPos += inputHeight + 20;

    
    UILabel * passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingEdge, topPos, 100, hintHeight)];
    [passwordLabel setText:@"密码"];
    passwordLabel.textAlignment = NSTextAlignmentLeft;
    passwordLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
    
    topPos += hintHeight + 5;
    
    UIView *passwordContainer  = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos, self.containerView.bounds.size.width - paddingEdge * 2, inputHeight)];
    
    
    self.passwordLine = [[UIView alloc] initWithFrame:CGRectMake(0, inputHeight - 1, passwordContainer.frame.size.width, 1.f)];
    self.passwordLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, passwordContainer.frame.size.width - 20 , inputHeight - 1)];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordField.placeholder = @"请输入您的密码";
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordField.delegate = self;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
//    self.sendCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(passwordContainer.frame.size.width - 72, (inputHeight - 1 - 20) / 2.0, 72, 33)];
//    [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    self.sendCodeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
//    self.sendCodeBtn.layer.borderWidth = 1;
//    self.sendCodeBtn.layer.cornerRadius = 4;
//    self.sendCodeBtn.layer.borderColor = [UIColor colorWithHexString:@"0x191919"].CGColor;
//    [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x171717"] forState:UIControlStateNormal];
//    [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x171717"] forState:UIControlStateSelected];
//    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
//    self.sendCodeBtn.enabled = NO;
    
    
    topPos += inputHeight + 58;
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(paddingEdge, topPos, self.containerView.bounds.size.width - paddingEdge * 2, 53)];
    [self.loginBtn addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 4.f;
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.loginBtn.backgroundColor = kMainColor;
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    self.loginBtn.enabled = NO;
    
    [self.containerView addSubview:hintLabel];
    
    [userNameContainer addSubview:self.userNameField];
    [userNameContainer addSubview:self.userNameLine];
    [self.containerView addSubview:userNameContainer];
    
    [self.containerView addSubview:passwordLabel];
    [self.containerView addSubview:passwordContainer];
    
    [passwordContainer addSubview:self.passwordField];
    [passwordContainer addSubview:self.passwordLine];
    [passwordContainer addSubview:self.sendCodeBtn];
    
    [self.containerView addSubview:self.loginBtn];
    
    self.userNameField.text = savedName;
    
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
    [backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
    
    self.privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.view.bounds.size.height - 40 - kTabbarSafeBottomMargin, self.view.bounds.size.width-32, 40)];
    self.privacyLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"登录即代表你已同意《倚天通用户协议》和《倚天通隐私政策》" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                                                                                                                     NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [text setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                          NSForegroundColorAttributeName : [UIColor blueColor]} range:NSMakeRange(9, 9)];
    [text setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                          NSForegroundColorAttributeName : [UIColor blueColor]} range:NSMakeRange(19, 9)];
    self.privacyLabel.attributedText = text ;
    [self.privacyLabel setUserInteractionEnabled:YES];
    
    __weak typeof(self)ws = self;
    [self.privacyLabel yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(9, 9)), NSStringFromRange(NSMakeRange(19, 9))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        WFCPrivacyViewController * pvc = [[WFCPrivacyViewController alloc] init];
        pvc.isPrivacy = (range.location == 19);
        [ws.navigationController pushViewController:pvc animated:YES];
        
    }];
    
    [backgroundImageView addSubview:self.privacyLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:@"短信发送中" forState:UIControlStateNormal];
    __weak typeof(self)ws = self;
    [[AppService sharedAppService] sendCode:self.userNameField.text success:^{
       [ws sendCodeDone:YES];
    } error:^(NSString * _Nonnull message) {
        [ws sendCodeDone:NO];
    }];
}

- (void)updateCountdown:(id)sender {
    int second = (int)([NSDate date].timeIntervalSince1970 - self.sendCodeTime);
    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%ds", 60-second] forState:UIControlStateNormal];
    if (second >= 60) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.sendCodeBtn.enabled = YES;
    }
}
- (void)sendCodeDone:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送成功";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            self.sendCodeTime = [NSDate date].timeIntervalSince1970;
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                                 selector:@selector(updateCountdown:)
                                                              userInfo:nil
                                                               repeats:YES];
            [self.countdownTimer fire];
            
            
            [hud hideAnimated:YES afterDelay:1.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送失败";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.sendCodeBtn.enabled = YES;
            });
        }
    });
}

- (void)resetKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    self.userNameLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.passwordField resignFirstResponder];
    self.passwordLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)onLoginButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *password = self.passwordField.text;
  
    if (!user.length || !password.length) {
        return;
    }
    
    [self resetKeyboard:nil];
    
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.label.text = @"登录中...";
  [hud showAnimated:YES];
  
    [[AppService sharedAppService] login:user password:password success:^(NSString *userId, NSString *token, NSString  *webToken, BOOL newUser) {
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:kSavedName];
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:kSavedToken];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kSavedUserId];
        [[NSUserDefaults standardUserDefaults] setObject:webToken forKey:kSavedWebToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSuccessNotification object:nil];
        NSLog(@"token :%@  \n webToken: %@ \n userID: %@",token,webToken,userId);
        
    //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
        [[WFCCNetworkService sharedInstance] connect:userId token:token];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [hud hideAnimated:YES];
//            WFCBaseTabBarController *tabBarVC = [WFCBaseTabBarController new];
//            tabBarVC.newUser = newUser;
//            [UIApplication sharedApplication].delegate.window.rootViewController =  tabBarVC;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } error:^(int errCode, NSString *message) {
        NSLog(@"login error with code %d, message %@", errCode, message);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"登录失败";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
    } else if(textField == self.passwordField) {
        [self onLoginButton:nil];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.userNameField) {
        self.userNameLine.backgroundColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9];
        self.passwordLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    } else if (textField == self.passwordField) {
        self.userNameLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.passwordLine.backgroundColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9];
    }
    return YES;
}
#pragma mark - UITextInputDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    if (textInput == self.userNameField) {
        [self updateBtn];
    } else if (textInput == self.passwordField) {
        [self updateBtn];
    }
}
//TODO: 当记住上一次手机号时，这个验证有问题
- (void)updateBtn {
    if ([self isValidNumber]) {
        if (!self.countdownTimer) {
            self.sendCodeBtn.enabled = YES;
            [self.sendCodeBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9] forState:UIControlStateNormal];
            self.sendCodeBtn.layer.borderColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9].CGColor;
        } else {
            self.sendCodeBtn.enabled = NO;
            self.sendCodeBtn.layer.borderColor = [UIColor colorWithHexString:@"0x191919"].CGColor;
            [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x171717"] forState:UIControlStateNormal];
            [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x171717"] forState:UIControlStateSelected];
        }
        
        if ([self isValidCode]) {
            [self.loginBtn setBackgroundColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]];
//            [self.loginBtn wfcu_gradientBackgroundColorWithStartColor:[UIColor redColor] withEndColor:[UIColor purpleColor]];
            self.loginBtn.enabled = YES;
        } else {
            [self.loginBtn setBackgroundColor:[UIColor grayColor]];
//             [self.loginBtn wfcu_gradientBackgroundColorWithStartColor:[UIColor grayColor] withEndColor:[UIColor grayColor]];
            self.loginBtn.enabled = NO;
        }
    } else {
        self.sendCodeBtn.enabled = NO;
        [self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        [self.loginBtn setBackgroundColor:[UIColor grayColor]];
//        [self.loginBtn wfcu_gradientBackgroundColorWithStartColor:[UIColor grayColor] withEndColor:[UIColor grayColor]];
        self.loginBtn.enabled = NO;
    }
}

- (BOOL)isValidNumber {
//    NSString * MOBILE = @"^((1[34578]))\\d{9}$";
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    if (self.userNameField.text.length == 11 && ([regextestmobile evaluateWithObject:self.userNameField.text] == YES)) {
//        return YES;
//    } else {
//        return NO;
//    }
    
    if (self.userNameField.text.length > 1) {
        return YES;
    } else {
        return NO;
    }
    
}

- (BOOL)isValidCode {
    if (self.passwordField.text.length >= 0) {
        return YES;
    } else {
        return NO;
    }
}
@end
