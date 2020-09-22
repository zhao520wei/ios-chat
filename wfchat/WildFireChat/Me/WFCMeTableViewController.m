//
//  MeTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/4.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCMeTableViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "UIImageView+WebCache.h"
#import "WFCSettingTableViewController.h"
#import "WFCSecurityTableViewController.h"
#import "WFCMeTableViewHeaderViewCell.h"
#import "UIColor+YH.h"
#import "WFCUConfigManager.h"
#import "WFCUMyProfileTableViewController.h"
#import "WFCUMessageNotificationViewController.h"
#import "ZYSliderViewController.h"
#import "UIViewController+ZYSliderViewController.h"
#import "WFCBaseTabBarController.h"
#import "MeTableViewCell.h"
#import "WFCUBrowserViewController.h"
#import "WFCConfig.h"
#import "MBProgressHUD.h"
#import "WFCAboutUsViewController.h"

@interface WFCMeTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIImageView *portraitView;
@property (nonatomic, strong)NSArray *itemDataSource;
@end

@implementation WFCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImgView = [[UIImageView alloc] init];
    backImgView.image = [UIImage imageNamed:@"login_background"];
    backImgView.frame = self.view.bounds;
    backImgView.userInteractionEnabled = YES;
    [self.view addSubview:backImgView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = nil;
    [self.tableView reloadData];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    [self.view addSubview:self.tableView];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kUserInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([[WFCCNetworkService sharedInstance].userId isEqualToString:note.object]) {
            [ws.tableView reloadData];
        }
    }];
    
    self.itemDataSource = @[
        @{@"title":WFCString(@"MessageNotification"),
          @"image":@"notification_setting"},
        @{@"title":@"关于我们",
          @"image":@"safe_setting"},
        @{@"title":@"退出登录",
          @"image":@"MoreSetting"}
    ];
    

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    } else {
        return 9;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 9)];
        view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
        return view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        WFCMeTableViewHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        if (cell == nil) {
            cell = [[WFCMeTableViewHeaderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:YES];
        cell.userInfo = me;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        MeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleDefault"];
        if (cell == nil) {
            cell = [[MeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"styleDefault"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
        cell.centerLable.text = self.itemDataSource[indexPath.section - 1][@"title"];
        
//        cell.imageView.image = [UIImage imageNamed:self.itemDataSource[indexPath.section - 1][@"image"]];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 150;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
     
    
    if (indexPath.section == 0) {
        [[self sliderViewController] hideLeft];
        WFCUMyProfileTableViewController *vc = [[WFCUMyProfileTableViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
         
            [[self sliderViewController].sliderNavigationController pushViewController:vc animated:true];
        }
    } else if (indexPath.section == 1) {
        [[self sliderViewController] hideLeft];
        WFCUMessageNotificationViewController *mnvc = [[WFCUMessageNotificationViewController alloc] init];
        mnvc.hidesBottomBarWhenPushed = YES;
        if (self.navigationController) {
            [self.navigationController pushViewController:mnvc animated:YES];
        } else {
            [[self sliderViewController].sliderNavigationController pushViewController:mnvc animated:true];
        }
        
    } else if(indexPath.section == 2) {
//        WFCUBrowserViewController * stvc = [[WFCUBrowserViewController alloc] init];
//        stvc.url = USER_PRIVACY_URL;
//
//        stvc.hidesBottomBarWhenPushed = YES;
//        if (self.navigationController) {
//            [self.navigationController pushViewController:stvc animated:YES];
//        } else {
//            [[self sliderViewController] hideLeft];
//            [[self sliderViewController].sliderNavigationController pushViewController:stvc animated:true];
//        }
       
        [[self sliderViewController] hideLeft];
        WFCAboutUsViewController * aboutUsVC = [[WFCAboutUsViewController alloc] init];
        aboutUsVC.hidesBottomBarWhenPushed = YES;
        [[self sliderViewController].sliderNavigationController pushViewController:aboutUsVC animated:true];
        
    } else {
//        WFCSettingTableViewController *vc = [[WFCSettingTableViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        if (self.navigationController) {
//            [self.navigationController pushViewController:vc animated:YES];
//        } else {
//            //            [self.xl_sldeMenu showRootViewControllerAnimated:true];
//            //            WFCBaseTabBarController * ctrl = (WFCBaseTabBarController *)self.xl_sldeMenu.rootViewController;
//            [[self sliderViewController] hideLeft];
//            [[self sliderViewController].sliderNavigationController pushViewController:vc animated:true];
//        }
       
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedToken];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedUserId];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedWebToken];
        //退出后就不需要推送了，第一个参数为YES
        //如果希望再次登录时能够保留历史记录，第二个参数为NO。如果需要清除掉本地历史记录第二个参数用YES
         [[self sliderViewController] hideLeft];
        
        [[WFCCNetworkService sharedInstance] disconnect:YES clearSession:NO];
    }
    
    
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
