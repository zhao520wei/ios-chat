//
//  WFCBaseTabBarController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCBaseTabBarController.h"
#import <WFChatClient/WFCChatClient.h>
  
#import "DiscoverViewController.h"

#ifdef WFC_MOMENTS
#import <WFMomentUIKit/WFMomentUIKit.h>
#import <WFMomentClient/WFMomentClient.h>
#endif
#import "UIImage+ERCategory.h"
#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

#import "WFCMeTableViewController.h"
#import "WFCUConversationTableViewController.h"
#import "WFCUContactListViewController.h"
#import "WFCArchitectureViewController.h"
#import "AutoBreadcrumbViewController.h"
#import "UIColor+YH.h"
#import "WFCUConfigManager.h"
#import "BrowserViewController.h"
#import "WFCConfig.h"

@interface WFCBaseTabBarController ()

@end

@implementation WFCBaseTabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *vc = [WFCUConversationTableViewController new];
    vc.title = LocalizedString(@"Message");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UITabBarItem *item = nav.tabBarItem;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIImage *colorImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02] size:CGSizeMake(width, 1)];
    [nav.navigationBar setShadowImage:colorImage];
   
    
    item.title = LocalizedString(@"Message");
    item.image = [UIImage imageNamed:@"tabbar_chat"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_chat_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    
    self.firstNav = nav;
    
    
    
//    vc = [AutoBreadcrumbViewController new];
//    vc.title = LocalizedString(@"Contact");
//    nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    [nav.navigationBar setShadowImage:colorImage];
//    item = nav.tabBarItem;
//    item.title = LocalizedString(@"Contact");
//    item.image = [UIImage imageNamed:@"tabbar_contacts"];
//    item.selectedImage = [[UIImage imageNamed:@"tabbar_contacts_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
//    [self addChildViewController:nav];
    
    vc = [WFCUContactListViewController new];
    vc.title = LocalizedString(@"Contact");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Contact");
    item.image = [UIImage imageNamed:@"tabbar_contacts"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_contacts_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    
    
    
    vc = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString: AppWebWork] withType:BrowserSourceWork];
    vc.title = LocalizedString(@"Discover");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    //    item = [[UITabBarItem alloc]initWithTitle:LocalizedString(@"Me") image:[UIImage imageNamed:@"tabbar_me"] selectedImage:[[UIImage imageNamed:@"tabbar_me_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.navigationBar setShadowImage:colorImage];
    item.title = LocalizedString(@"Discover");
    item.image = [UIImage imageNamed:@"tabbar_discover"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_discover_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
    [self addChildViewController:nav];
 
//    vc = [WFCUContactListViewController new];
//    vc.title = LocalizedString(@"Contact");
//    nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    [nav.navigationBar setShadowImage:colorImage];
//    item = nav.tabBarItem;
//    item.title = LocalizedString(@"Contact");
//    item.image = [UIImage imageNamed:@"tabbar_contacts"];
//    item.selectedImage = [[UIImage imageNamed:@"tabbar_contacts_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
//    [self addChildViewController:nav];
//
    
    
//    vc = [DiscoverViewController new];
//    vc.title = LocalizedString(@"Discover");
//    nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    item = nav.tabBarItem;
//    [nav.navigationBar setShadowImage:colorImage];
//    item.title = LocalizedString(@"Discover");
//    item.image = [UIImage imageNamed:@"tabbar_discover"];
//    item.selectedImage = [[UIImage imageNamed:@"tabbar_discover_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
//    [self addChildViewController:nav];
    
      
    vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.whiteColor;
    vc.title = LocalizedString(@"Me");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setShadowImage:colorImage];
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Me");
    item.image = [UIImage imageNamed:@"tabbar_me"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_me_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kMainColor} forState:UIControlStateSelected];
    
    UILabel * centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    centerLabel.text = @"正在开发中，敬请等待";
    [vc.view addSubview:centerLabel];
    centerLabel.center = vc.view.center;
    
    [self addChildViewController:nav];
    
    
    self.settingNav = nav;
    

#ifdef WFC_MOMENTS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveComments:) name:kReceiveComments object:nil];
#endif
    
}

- (void)onReceiveComments:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadgeNumber];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBadgeNumber];
    
//    UIImage *colorImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] size:CGSizeMake(kScreenWidth, 0.34)];
//    [self.navigationController.navigationBar setShadowImage:colorImage];
  
}

- (void)updateBadgeNumber {
#ifdef WFC_MOMENTS
    [self.tabBar showBadgeOnItemIndex:2 badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif
}

- (void)setNewUser:(BOOL)newUser {
    if (newUser) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"欢迎注册" message:@"请更新您头像和昵称，以便您的朋友能更好地识别！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.selectedViewController = self.settingNav;
            }];
            [alertController addAction:action];
            NSLog(@"hahahah");
            [self.firstNav presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(setupNavBar)]) {
                [[UIApplication sharedApplication].delegate performSelector:@selector(setupNavBar)];
            }
            UIView *superView = self.view.superview;
            [self.view removeFromSuperview];
            [superView addSubview:self.view];
        }
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    WFCUConfigManager * manager = [WFCUConfigManager globalManager];
    if ([item.title isEqualToString:LocalizedString(@"Message")]) {
        manager.isNotFirstTab = NO;
    } else {
        manager.isNotFirstTab = YES;
    }
}

@end
