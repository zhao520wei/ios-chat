//
//  MeTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/4.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCMeTableViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "SDWebImage.h"
#import "WFCSettingTableViewController.h"
#import "WFCSecurityTableViewController.h"
#import "WFCMeTableViewHeaderViewCell.h"
#import "UIColor+YH.h"
#import "WFCUConfigManager.h"
#import "WFCUMyProfileTableViewController.h"
#import "WFCUMessageNotificationViewController.h"
#import "XLSlideMenu.h"

@interface WFCMeTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIImageView *portraitView;
@property (nonatomic, strong)NSArray *itemDataSource;
@end

@implementation WFCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
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
        @{@"title":WFCString(@"AccountSafety"),
          @"image":@"safe_setting"},
        @{@"title":WFCString(@"Settings"),
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
        cell.backgroundColor = [WFCUConfigManager globalManager].naviBackgroudColor;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleDefault"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"styleDefault"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
        cell.textLabel.text = self.itemDataSource[indexPath.section - 1][@"title"];
        cell.imageView.image = [UIImage imageNamed:self.itemDataSource[indexPath.section - 1][@"image"]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 154;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        WFCUMyProfileTableViewController *vc = [[WFCUMyProfileTableViewController alloc] init];
        if (self.navigationController) {
             vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.xl_sldeMenu showRootViewControllerAnimated:true];
            UIViewController * ctrl = (UIViewController *)self.xl_sldeMenu.rootViewController;
            [nav.navigationController pushViewController:vc animated:true];
        }
    } else if (indexPath.section == 1) {
        
        WFCUMessageNotificationViewController *mnvc = [[WFCUMessageNotificationViewController alloc] init];
        if (self.navigationController) {
            mnvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mnvc animated:YES];
        } else {
            [self.xl_sldeMenu showRootViewControllerAnimated:true];
            UINavigationController * nav = (UINavigationController *)self.xl_sldeMenu.rootViewController.navigationController;
            [nav pushViewController:mnvc animated:true];
        }

    } else if(indexPath.section == 2) {
        WFCSecurityTableViewController * stvc = [[WFCSecurityTableViewController alloc] init];
        stvc.hidesBottomBarWhenPushed = YES;
        if (self.navigationController) {
            [self.navigationController pushViewController:stvc animated:YES];
        } else {
            [self.xl_sldeMenu showRootViewControllerAnimated:true];
            UINavigationController * nav = (UINavigationController *)self.xl_sldeMenu.rootViewController.navigationController;
            [nav pushViewController:stvc animated:true];
        }
    } else {
        WFCSettingTableViewController *vc = [[WFCSettingTableViewController alloc] init];
               vc.hidesBottomBarWhenPushed = YES;
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.xl_sldeMenu showRootViewControllerAnimated:true];
            UINavigationController * nav = (UINavigationController *)self.xl_sldeMenu.rootViewController.navigationController;
            [nav pushViewController:vc animated:true];
        }
    }
    
  
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
