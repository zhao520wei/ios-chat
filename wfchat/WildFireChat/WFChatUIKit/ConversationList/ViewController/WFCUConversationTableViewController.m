//
//  ConversationTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewController.h"
#import "WFCUConversationTableViewCell.h"
#import "WFCUContactListViewController.h"
#import "WFCUCreateGroupViewController.h"
#import "WFCUFriendRequestViewController.h"
#import "WFCUSearchGroupTableViewCell.h"
#import "WFCUConversationSearchTableViewController.h"
#import "WFCUSearchChannelViewController.h"
#import "WFCUCreateChannelViewController.h"

#import "WFCUMessageListViewController.h"
#import <WFChatClient/WFCChatClient.h>

#import "WFCUUtilities.h"
#import "UITabBar+badge.h"
#import "KxMenu.h"
#import "UIImage+ERCategory.h"
#import "MBProgressHUD.h"

#import "WFCUContactTableViewCell.h"
#import "QrCodeHelper.h"
#import "WFCUConfigManager.h"
#import "UIImage+ERCategory.h"
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "UIView+Toast.h"
#import "WFCUSeletedUserViewController.h"

#import "SDWebImage.h"
#import "AutoBreadcrumbViewController.h"
#import "BrowserViewController.h"
#import "WFCConfig.h"
#import "UIViewController+ZYSliderViewController.h"
#import "ZYSliderViewController.h"


// 消息的列表页

API_AVAILABLE(ios(9.0))
@interface WFCUConversationTableViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray<WFCCConversationInfo *> *conversations;

@property (nonatomic, strong)  UISearchController       *searchController;
@property (nonatomic, strong) NSArray<WFCCConversationSearchInfo *>  *searchConversationList;
@property (nonatomic, strong) NSArray<WFCCUserInfo *>  *searchFriendList;
@property (nonatomic, strong) NSArray<WFCCGroupSearchInfo *>  *searchGroupList;
@property (nonatomic ,assign) BOOL isSearchConversationListExpansion;
@property (nonatomic ,assign) BOOL isSearchFriendListExpansion;
@property (nonatomic ,assign) BOOL isSearchGroupListExpansion;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchViewContainer;

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, strong) UIView *pcSessionView;

@property (nonatomic, strong) UIView * tableHeaderView;
@property (nonatomic, assign) float tableHeaderViewHeight;
@property (nonatomic, strong) UIView * tableFooterView;

@property (nonatomic, strong) UIButton * todoButton;
@property (nonatomic, strong) UIButton * unreadButton;
@property (nonatomic, strong) UIButton * scheduleButton;
@property (nonatomic, strong) UIButton * pcLoginStatuButton;
@property (nonatomic, strong) UIStackView * headerStackView ;

@property (nonatomic, strong) UIButton * headerButton;


@end

@implementation WFCUConversationTableViewController
- (void)initSearchUIAndTableView {
    _searchConversationList = [NSMutableArray array];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    if (@available(iOS 13, *)) {
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
        UIImage* searchBarBg = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width - 8 * 2, 36) cornerRadius:4];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    } else {
        [self.searchController.searchBar setValue:WFCString(@"Cancel") forKey:@"_cancelButtonText"];
       
        UIImage* searchBarBg = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width - 8 * 2, 36) cornerRadius:4];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
        
        UIButton * searchButton = (UIButton *)[self.searchController.searchBar valueForKey:@"_cancelButton"];
        [searchButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

    }
    
    
    if (@available(iOS 9.1, *)) {
        self.searchController.obscuresBackgroundDuringPresentation = NO;
    }
    self.searchController.searchBar.placeholder = WFCString(@"Search");
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

  
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"expansion"];
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchController;
    } else {
        // TODO:
        self.tableView.tableHeaderView = _searchController.searchBar;
    }
    self.definesPresentationContext = YES;
    
    [self initTableHeaderAndFooter];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    if (self.searchController.active) {
        [self.tableView reloadData];
    } else {
        WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
        NSArray *dataSource = self.conversations;
        for (int i = 0; i < dataSource.count; i++) {
            WFCCConversationInfo *conv = dataSource[i];
            if (conv.conversation.type == Single_Type && [conv.conversation.target isEqualToString:userInfo.userId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            } else if ([conv.lastMessage.fromUser isEqualToString:userInfo.userId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    if (self.searchController.active) {
        [self.tableView reloadData];
    } else {
        WFCCGroupInfo *groupInfo = notification.userInfo[@"groupInfo"];
        NSArray *dataSource = self.conversations;
        
        
        for (int i = 0; i < dataSource.count; i++) {
            WFCCConversationInfo *conv = dataSource[i];
            if (conv.conversation.type == Group_Type && [conv.conversation.target isEqualToString:groupInfo.target]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)onChannelInfoUpdated:(NSNotification *)notification {
    if (self.searchController.active) {
        [self.tableView reloadData];
    } else {
        WFCCChannelInfo *channelInfo = notification.userInfo[@"groupInfo"];
        NSArray *dataSource = self.conversations;
        
        
        for (int i = 0; i < dataSource.count; i++) {
            WFCCConversationInfo *conv = dataSource[i];
            if (conv.conversation.type == Channel_Type && [conv.conversation.target isEqualToString:channelInfo.channelId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)onSendingMessageStatusUpdated:(NSNotification *)notification {
    if (self.searchController.active) {
        [self.tableView reloadData];
    } else {
        long messageId = [notification.object longValue];
        NSArray *dataSource = self.conversations;
        
        if (messageId == 0) {
            return;
        }
        
        for (int i = 0; i < dataSource.count; i++) {
            WFCCConversationInfo *conv = dataSource[i];
            if (conv.lastMessage && conv.lastMessage.direction == MessageDirection_Send && conv.lastMessage.messageId == messageId) {
                conv.lastMessage = [[WFCCIMService sharedWFCIMService] getMessage:messageId];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

-(UIButton *)headerButton {
    if (!_headerButton) {
        _headerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    }
    return _headerButton;
}

- (void)onLoginSuccessUpdated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:YES];
          [self.headerButton sd_setImageWithURL:[NSURL URLWithString:me.portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
//        if (!self.headerButton.imageView.image) {
//            [self.headerButton setImage:[UIImage imageNamed:@"PersonalChat"] forState:UIControlStateNormal];
//        }
    });
  
    
    
}

- (void) onUserHeardImageUpdated:(NSNotification *)notification {
    WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:userInfo.userId]) {
        [self.headerButton sd_setImageWithURL:[NSURL URLWithString:userInfo.portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
        NSLog(@"首页更新用户头像 success");
    }else {
        NSLog(@"首页更新用户头像 failed");
    }
}

- (void)onRightBarBtn:(UIBarButtonItem *)sender {
    CGFloat searchExtra = 0;
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
        return;
    }
    KxMenuItem * firstItem = [KxMenuItem menuItem:WFCString(@"StartChat")
                                            image:[UIImage imageNamed:@"menu_start_chat"]
                                           target:self
                                           action:@selector(startChatAction:)];
    firstItem.foreColor = UIColor.whiteColor;
    KxMenuItem * secondItem =  [KxMenuItem menuItem:WFCString(@"ScanQRCode")
                                             image:[UIImage imageNamed:@"menu_scan_qr"]
                                            target:self
                                            action:@selector(scanQrCodeAction:)];
    secondItem.foreColor = UIColor.whiteColor;
    
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width - 56, kStatusBarAndNavigationBarHeight + searchExtra, 48, 5)
                 menuItems:@[
                     firstItem,
//                     [KxMenuItem menuItem:WFCString(@"AddFriend")
//                                    image:[UIImage imageNamed:@"menu_add_friends"]
//                                   target:self
//                                   action:@selector(addFriendsAction:)],
//                     [KxMenuItem menuItem:WFCString(@"SubscribeChannel")
//                                    image:[UIImage imageNamed:@"menu_listen_channel"]
//                                   target:self
//                                   action:@selector(listenChannelAction:)],
                    secondItem,
                 ]];
}

- (void)onLeftBatBtn:(UIBarButtonItem *) sender {
//    [self.xl_sldeMenu showLeftViewControllerAnimated:true];
     [[self sliderViewController] showLeft];
}

- (void)startChatAction:(id)sender {
    /*
    AutoBreadcrumbViewController * selectVC = [[AutoBreadcrumbViewController alloc] init];
    selectVC.isAbleSelected = true;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:selectVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self)ws = self;
    selectVC.selectedNode = ^(NSArray<SinglePersonNode *> *nodes){
        [navi dismissViewControllerAnimated:NO completion:nil];
        NSMutableArray * contacts = [NSMutableArray array];
        for (SinglePersonNode * node in nodes) {
            [contacts addObject:node.uid];
        }
        
        if (contacts.count == 1) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:contacts[0] line:0];
            mvc.hidesBottomBarWhenPushed = YES;
            [ws.navigationController pushViewController:mvc animated:YES];
        } else {
#if !WFCU_GROUP_GRID_PORTRAIT
            WFCUCreateGroupViewController *vc = [[WFCUCreateGroupViewController alloc] init];
            vc.memberIds = [contacts mutableCopy];
            if (![vc.memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
                [vc.memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
            }
            vc.hidesBottomBarWhenPushed = YES;
            [ws.navigationController pushViewController:vc animated:YES];
#else
            [self createGroup:contacts];
#endif
        }
        
    };
    
     [self.navigationController presentViewController:navi animated:YES completion:nil];
    */
    
 
    WFCUSeletedUserViewController *pvc = [[WFCUSeletedUserViewController alloc] init];
    pvc.type = Horizontal;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self)ws = self;
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        [navi dismissViewControllerAnimated:NO completion:nil];
        if (contacts.count == 1) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:contacts[0] line:0];
            mvc.hidesBottomBarWhenPushed = YES;
            [ws.navigationController pushViewController:mvc animated:YES];
        } else {
#if !WFCU_GROUP_GRID_PORTRAIT
            WFCUCreateGroupViewController *vc = [[WFCUCreateGroupViewController alloc] init];
            vc.memberIds = [contacts mutableCopy];
            if (![vc.memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
                [vc.memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
            }
            vc.hidesBottomBarWhenPushed = YES;
            [ws.navigationController pushViewController:vc animated:YES];
#else
            [self createGroup:contacts];
#endif
        }
    };
    
    [self.navigationController presentViewController:navi animated:YES completion:nil];
    
}

#if WFCU_GROUP_GRID_PORTRAIT
- (void)createGroup:(NSArray<NSString *> *)contacts {
    __weak typeof(self) ws = self;
    NSMutableArray<NSString *> *memberIds = [contacts mutableCopy];
    if (![memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
        [memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
    }

    NSString *name;
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[memberIds objectAtIndex:0]  refresh:NO];
    name = userInfo.displayName;
    
    for (int i = 1; i < MIN(8, memberIds.count); i++) {
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[memberIds objectAtIndex:i]  refresh:NO];
        if (userInfo.displayName.length > 0) {
            if (name.length + userInfo.displayName.length + 1 > 16) {
                name = [name stringByAppendingString:WFCString(@"Etc")];
                break;
            }
            name = [name stringByAppendingFormat:@",%@", userInfo.displayName];
        }
    }
    if (name.length == 0) {
        name = WFCString(@"GroupChat");
    }
    
    [[WFCCIMService sharedWFCIMService] createGroup:nil name:name portrait:nil type:GroupType_Restricted members:memberIds notifyLines:@[@(0)] notifyContent:nil success:^(NSString *groupId) {
        NSLog(@"create group success");
        
        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
        mvc.conversation = [[WFCCConversation alloc] init];
        mvc.conversation.type = Group_Type;
        mvc.conversation.target = groupId;
        mvc.conversation.line = 0;
        
        mvc.hidesBottomBarWhenPushed = YES;
        [ws.navigationController pushViewController:mvc animated:YES];
    } error:^(int error_code) {
        NSLog(@"create group failure");
        [ws.view makeToast:WFCString(@"CreateGroupFailure")
                    duration:2
                    position:CSToastPositionCenter];

    }];
}
#endif

- (void)addFriendsAction:(id)sender {
    UIViewController *addFriendVC = [[WFCUFriendRequestViewController alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)listenChannelAction:(id)sender {
    UIViewController *searchChannelVC = [[WFCUSearchChannelViewController alloc] init];
    searchChannelVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchChannelVC animated:YES];
}

- (void)scanQrCodeAction:(id)sender {
    if (gQrCodeDelegate) {
        [gQrCodeDelegate scanQrCode:self.navigationController];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversations = [[NSMutableArray alloc] init];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initSearchUIAndTableView];
    self.definesPresentationContext = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];
    
    
    WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:YES];
    [self.headerButton sd_setImageWithURL:[NSURL URLWithString:me.portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    if (!self.headerButton.imageView.image) {
        [self.headerButton setImage:[UIImage imageNamed:@"PersonalChat"] forState:UIControlStateNormal];
    }
    self.headerButton.layer.cornerRadius  = self.headerButton.frame.size.width/2;
    self.headerButton.layer.masksToBounds = YES;
    [self.headerButton addTarget:self action:@selector(onLeftBatBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIView * leftBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    leftBackgroundView.layer.cornerRadius  = leftBackgroundView.frame.size.width/2;
    leftBackgroundView.layer.masksToBounds = YES;
    [leftBackgroundView addSubview:self.headerButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: leftBackgroundView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearAllUnread:) name:@"kTabBarClearBadgeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelInfoUpdated:) name:kChannelInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendingMessageStatusUpdated:) name:kSendingMessageStatusUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccessUpdated) name:kUserLoginSuccessNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserHeardImageUpdated:) name:kUserInfoUpdated object:nil];
    
    self.firstAppear = YES;
}


- (void)updateConnectionStatus:(ConnectionStatus)status {
    UIView *title;
    if (status != kConnectionStatusConnecting && status != kConnectionStatusReceiving) {
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 40, 0, 80, 44)];
        
        switch (status) {
            case kConnectionStatusLogout:
                navLabel.text = WFCString(@"NotLogin");
                break;
            case kConnectionStatusUnconnected:
                navLabel.text = WFCString(@"NotConnect");
                break;
            case kConnectionStatusConnected:
                navLabel.text = WFCString(@"Message");
                break;
                
            default:
                break;
        }
        
        navLabel.textColor = [WFCUConfigManager globalManager].naviTextColor;
        navLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        
        navLabel.textAlignment = NSTextAlignmentCenter;
        title = navLabel;
    } else {
        UIView *continer = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 60, 0, 120, 44)];
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 80, 40)];
        if (status == kConnectionStatusConnecting) {
            navLabel.text = WFCString(@"Connecting");
        } else {
            navLabel.text = WFCString(@"Synching");
        }
        
        navLabel.textColor = [WFCUConfigManager globalManager].naviTextColor;
        navLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [continer addSubview:navLabel];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.center = CGPointMake(20, 21);
        [indicatorView startAnimating];
        indicatorView.color = [WFCUConfigManager globalManager].naviTextColor;
        [continer addSubview:indicatorView];
        title = continer;
    }
    self.navigationItem.titleView = title;
}

- (void)onConnectionStatusChanged:(NSNotification *)notification {
    ConnectionStatus status = [notification.object intValue];
    [self updateConnectionStatus:status];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    NSArray<WFCCMessage *> *messages = notification.object;
    if ([messages count]) {
        [self refreshList];
        [self refreshLeftButton];
    }
}

- (void)onSettingUpdated:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshList];
        [self refreshLeftButton];
        [self updatePcSession];
    });
}

- (void)onRecallMessages:(NSNotification *)notification {
    [self refreshList];
    [self refreshLeftButton];
}

- (void)onDeleteMessages:(NSNotification *)notification {
    [self refreshList];
    [self refreshLeftButton];
}


- (void)onClearAllUnread:(NSNotification *)notification {
    if ([notification.object intValue] == 0) {
        [[WFCCIMService sharedWFCIMService] clearAllUnreadStatus];
        [self refreshList];
        [self refreshLeftButton];
    }
}

- (void)refreshList {
    self.conversations = [[[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]] mutableCopy];
    
    for (WFCCConversationInfo * info in self.conversations) {
        NSLog(@"----- unreadCount.unread :%d   lastMessage.fromUser :%@   lastMessage.status:%ld", info.unreadCount.unread, info.lastMessage.fromUser,(long)info.lastMessage.status);
    }
    
    [self updateBadgeNumber];
    [self checkTableFooterLabelInfo];
    [self.tableView reloadData];
}

- (void)updateBadgeNumber {
    int count = 0;
    for (WFCCConversationInfo *info in self.conversations) {
        if (!info.isSilent) {
            count += info.unreadCount.unread;
        }
    }
    [self.tabBarController.tabBar showBadgeOnItemIndex:0 badgeValue:count];
}

- (void) initTableHeaderAndFooter {
    
    self.tableHeaderViewHeight = 40.0;
    self.tableHeaderView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.tableHeaderView.backgroundColor = kMainColor;
    double systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (systemVersion < 13.0) {
         self.tableHeaderView.alpha = 0.85;
    } else {
        self.tableHeaderView.alpha  = 1.00;
    }
   
    
  
    self.tableFooterView =  [[UIView alloc ]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.tableFooterView.backgroundColor = [UIColor clearColor];
    
    [self checkTableFooterLabelInfo];
    
    [self initTableHeaderButtons];
    
}

- (void) checkTableFooterLabelInfo {
    if (self.conversations.count > 6) {
        // 这里判断数据源是否超过10个，然后显示这个话
           UILabel * footLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
           footLable.text = @"--- 我是有底线的 ---";
           footLable.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];;
           footLable.textColor = [UIColor colorWithHexString:@"b3b3b3"];
           footLable.textAlignment = NSTextAlignmentCenter;
           [self.tableFooterView addSubview:footLable];
           
           self.tableView.tableFooterView = self.tableFooterView;
    } else {
        self.tableView.tableFooterView = nil;
    }
   
}


- (void) initTableHeaderButtons {
    
    if (@available(iOS 9.0, *)) {
        self.headerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.todoButton, self.unreadButton, self.scheduleButton]];
        self.headerStackView.frame = CGRectMake(30, 0, self.view.bounds.size.width - 60, 40);
        self.headerStackView.alignment = UIStackViewAlignmentFill;
        self.headerStackView.distribution = UIStackViewDistributionEqualSpacing;
        [self.tableHeaderView addSubview:self.headerStackView];
//        [self updatePcSession];
    } else {
        // Fallback on earlier versions
    }
    
    
}

-(UIButton *)todoButton {
    if (!_todoButton) {
        _todoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _todoButton.frame = CGRectMake(0, 0, 50, 40);
        [_todoButton setTitle:@" 待办" forState:UIControlStateNormal];
        [_todoButton setImage:[UIImage imageNamed:@"home_todo"] forState:UIControlStateNormal];
        _todoButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13];
        [_todoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_todoButton addTarget:self action:@selector(todoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _todoButton;
}
- (UIButton *)unreadButton {
    if (!_unreadButton) {
        _unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _unreadButton.frame = CGRectMake(0, 0, 50, 40);
        [_unreadButton setTitle:@" 未读" forState:UIControlStateNormal];
        [_unreadButton setImage:[UIImage imageNamed:@"home_unread"] forState:UIControlStateNormal];
        _unreadButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13] ;
        [_unreadButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_unreadButton addTarget:self action:@selector(unreadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unreadButton;
}
-(UIButton *)scheduleButton{
    if (!_scheduleButton) {
        _scheduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scheduleButton.frame = CGRectMake(0, 0, 50, 40);
        [_scheduleButton setTitle:@" 日程" forState:UIControlStateNormal];
        [_scheduleButton setImage:[UIImage imageNamed:@"home_schedule"] forState:UIControlStateNormal];
        _scheduleButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13];
        [_scheduleButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_scheduleButton addTarget:self action:@selector(scheduleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scheduleButton;
}
-(UIButton *)pcLoginStatuButton {
    if (!_pcLoginStatuButton) {
        _pcLoginStatuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pcLoginStatuButton.frame = CGRectMake(0, 0, 50, 40);
//        [_pcLoginStatuButton setImage:[UIImage imageNamed:@"pc_session"] forState:UIControlStateNormal];
        [_pcLoginStatuButton setTitle:@"PC已登录" forState:UIControlStateNormal];
        _pcLoginStatuButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13] ;
        [_pcLoginStatuButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_pcLoginStatuButton addTarget:self action:@selector(pcLoginStatuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _pcLoginStatuButton;;
}
- (void) todoButtonAction {
    BrowserViewController* ctrl = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString:AppWebTodo] withType:BrowserSourceTodo];
    ctrl.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:ctrl animated:true];
}
- (void) unreadButtonAction {
    BrowserViewController* ctrl = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString:AppWebUnread] withType:BrowserSourceUnread];
    ctrl.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:ctrl animated:true];
}
- (void) scheduleButtonAction {
    BrowserViewController* ctrl = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString:AppWebDate] withType:BrowserSourceDate];
    ctrl.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:ctrl animated:true];
}
- (void) pcLoginStatuButtonAction {
    [self onTapPCBar:nil];
}


- (void) exchangeTableHeaderAndFooter:(BOOL)isShowSearch {
    if (isShowSearch) {
        self.tableView.tableHeaderView = nil;
        self.tableView.tableFooterView = nil;
    } else {
        self.tableView.tableFooterView = self.tableFooterView;
        self.tableHeaderViewHeight = 40;
        [self updatePcSession];
    }
}

- (void)updatePcSession {
    NSArray<WFCCPCOnlineInfo *> *onlines = [[WFCCIMService sharedWFCIMService] getPCOnlineInfos];
    
    if (onlines.count) {
        [self.headerStackView addArrangedSubview:self.pcLoginStatuButton];
    } else {
        [self.headerStackView removeArrangedSubview:self.pcLoginStatuButton];
        [self.pcLoginStatuButton removeFromSuperview];
    }
    

}

- (void) testStackView:(BOOL)isExchange {
    if (isExchange) {
        [self.headerStackView addArrangedSubview:self.pcLoginStatuButton];
       
    } else {
        [self.headerStackView removeArrangedSubview:self.pcLoginStatuButton];
        [self.pcLoginStatuButton removeFromSuperview];
       
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self refreshLeftButton];
    
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        //iOS10,导航栏的私有接口为_UIBarBackground
        if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            [view.subviews firstObject].hidden = YES;
        }
    }];
    
    if (self.firstAppear) {
        self.firstAppear = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusChanged:) name:kConnectionStatusChanged object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteMessages:) name:kDeleteMessages object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingUpdated:) name:kSettingUpdated object:nil];
    }
    
    [self updateConnectionStatus:[WFCCNetworkService sharedInstance].currentConnectionStatus];
    [self refreshList];
    [self refreshLeftButton];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.searchController.isActive) {
        self.tabBarController.tabBar.hidden = YES;
    }
}
- (void)refreshLeftButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
        NSUInteger count = unreadCount.unread;
        
        NSString *title = nil;
        if (count > 0 && count < 1000) {
            title = [NSString stringWithFormat:WFCString(@"BackNumber"), count];
        } else if (count >= 1000) {
            title = WFCString(@"BackMore");
        } else {
            title = WFCString(@"Back");
        }
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
        item.title = title;
        
        self.navigationItem.backBarButtonItem = item;
    });
}

- (UIView *)pcSessionView {
    if (!_pcSessionView) {
        BOOL darkMode = NO;
        if (@available(iOS 13.0, *)) {
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                darkMode = YES;
            }
        }
        UIColor *bgColor;
        if (darkMode) {
            bgColor = [WFCUConfigManager globalManager].backgroudColor;
        } else {
            bgColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        }
        
        _pcSessionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        [_pcSessionView setBackgroundColor:bgColor];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 4, 32, 32)];
        iv.image = [UIImage imageNamed:@"pc_session"];
        [_pcSessionView addSubview:iv];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(68, 10, 100, 20)];
        label.text = WFCString(@"PCLogined");
        [_pcSessionView addSubview:label];
        _pcSessionView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPCBar:)];
        [_pcSessionView addGestureRecognizer:tap];
    }
    return _pcSessionView;
}

- (void)onTapPCBar:(id)sender {
    NSArray<WFCCPCOnlineInfo *> *onlines = [[WFCCIMService sharedWFCIMService] getPCOnlineInfos];
    if ([[WFCUConfigManager globalManager].appServiceProvider respondsToSelector:@selector(showPCSessionViewController:pcClient:)]) {
        [[WFCUConfigManager globalManager].appServiceProvider showPCSessionViewController:self pcClient:[onlines objectAtIndex:0]];
    }
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sec = 0;
    if (self.searchFriendList.count) {
        sec++;
    }
    
    if (self.searchGroupList.count) {
        sec++;
    }
    
    if (self.searchConversationList.count) {
        sec++;
    }
    
    if (sec == 0) {
        sec = 1;
    }
    return sec;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        int sec = 0;
        if (self.searchFriendList.count) {
            sec++;
            if (section == sec-1) {
                if (self.isSearchFriendListExpansion) {
                    return self.searchFriendList.count;
                } else {
                    if (self.searchFriendList.count > 2) {
                        return 3;
                    } else {
                        return self.searchFriendList.count;
                    }
                }
            }
        }
        
        if (self.searchGroupList.count) {
            sec++;
            if (section == sec-1) {
                if (self.isSearchGroupListExpansion) {
                    return self.searchGroupList.count;
                } else {
                    if (self.searchGroupList.count > 2) {
                        return 3;
                    } else {
                        return self.searchGroupList.count;
                    }
                }
            }
        }
        
        if (self.searchConversationList.count) {
            sec++;
            if (sec-1 == section) {
                
                if (self.isSearchConversationListExpansion) {
                    return self.searchConversationList.count;
                } else {
                    if (self.searchConversationList.count > 2) {
                        return 3;
                    } else {
                        return self.searchConversationList.count;
                    }
                }
            }
        }
        
        return 0;
    } else {
        return self.conversations.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        int sec = 0;
        if (self.searchFriendList.count) {
            sec++;
            if (indexPath.section == sec-1) {
                if (self.isSearchFriendListExpansion) {
                    WFCUContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
                    if (cell == nil) {
                        cell = [[WFCUContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendCell"];
                    }
                    cell.big = NO;
                    cell.isInSearch = YES;
                    cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                    cell.userId = self.searchFriendList[indexPath.row].userId;
                    return cell;
                } else {
                    if (indexPath.row == 2) {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expansion" forIndexPath:indexPath];
                        cell.textLabel.textColor = [UIColor colorWithHexString:@"5b6e8e"];
                        cell.textLabel.text = [NSString stringWithFormat:@"点击展开剩余%lu项", self.searchFriendList.count - 2];
                        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
                        return cell;
                    } else {
                        WFCUContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
                        if (cell == nil) {
                            cell = [[WFCUContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendCell"];
                        }
                        cell.big = NO;
                        cell.isInSearch = YES;
                        if (indexPath.row == 1) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                            
                        } else {
                            cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                            
                        }
                        cell.userId = self.searchFriendList[indexPath.row].userId;
                        return cell;
                    }
                }
                
            }
        }
        if (self.searchGroupList.count) {
            sec++;
            if (indexPath.section == sec-1) {
                
                if (self.isSearchGroupListExpansion) {
                    WFCUSearchGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
                    if (cell == nil) {
                        cell = [[WFCUSearchGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCell"];
                    }
                    cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                    
                    cell.groupSearchInfo = self.searchGroupList[indexPath.row];
                    return cell;
                } else {
                    if (indexPath.row == 2) {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expansion" forIndexPath:indexPath];
                        cell.textLabel.textColor = [UIColor colorWithHexString:@"5b6e8e"];
                        cell.textLabel.text = [NSString stringWithFormat:@"点击展开剩余%lu项", self.searchGroupList.count - 2];
                        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
                        return cell;
                    } else {
                        WFCUSearchGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
                        if (cell == nil) {
                            cell = [[WFCUSearchGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCell"];
                        }
                        if (indexPath.row == 1) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                            
                        } else {
                            cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                            
                        }
                        cell.groupSearchInfo = self.searchGroupList[indexPath.row];
                        return cell;
                    }
                }
                
            }
        }
        if (self.searchConversationList.count) {
            sec++;
            if (sec-1 == indexPath.section) {
                if (self.isSearchConversationListExpansion) {
                    WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchConversationCell"];
                    if (cell == nil) {
                        cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchConversationCell"];
                    }
                    cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                    cell.big = NO;
                    
                    cell.searchInfo = self.searchConversationList[indexPath.row];
                    return cell;
                } else {
                    if (indexPath.row == 2) {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expansion" forIndexPath:indexPath];
                        cell.textLabel.textColor = [UIColor colorWithHexString:@"5b6e8e"];
                        cell.textLabel.text = [NSString stringWithFormat:@"点击展开剩余%lu项", self.searchConversationList.count - 2];
                        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
                        return cell;
                    } else {
                        WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchConversationCell"];
                        if (cell == nil) {
                            cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchConversationCell"];
                        }
                        if (indexPath.row == 1) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                            
                        } else {
                            cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 0);
                            
                        }                           cell.big = NO;
                        
                        cell.searchInfo = self.searchConversationList[indexPath.row];
                        return cell;
                    }
                }
                
            }
        }
        
        return nil;
    } else {
        WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell"];
        if (cell == nil) {
            cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationCell"];
        }
        cell.big = YES;
        cell.separatorInset = UIEdgeInsetsMake(0, 76, 0, 0);
        cell.info = self.conversations[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        int sec = 0;
        if (self.searchFriendList.count) {
            sec++;
            if (indexPath.section == sec-1) {
                if (self.isSearchFriendListExpansion) {
                    return 60;
                } else {
                    if (indexPath.row == 2) {
                        return 40;
                    } else {
                        return 60;
                    }
                }
            }
        }
        
        if (self.searchGroupList.count) {
            sec++;
            if (indexPath.section  == sec-1) {
                if (self.isSearchGroupListExpansion) {
                    return 60;
                } else {
                    if (indexPath.row == 2) {
                        return 40;
                    } else {
                        return 60;
                    }
                }
            }
        }
        
        if (self.searchConversationList.count) {
            sec++;
            if (sec-1 == indexPath.section ) {
                
                if (self.isSearchConversationListExpansion) {
                    return 60;
                } else {
                    if (indexPath.row == 2) {
                        return 40;
                    } else {
                        return 60;
                    }
                }
            }
        }
        return 60;
    } else {
        return 72;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        self.tableHeaderViewHeight = 0.0;
        if (self.searchConversationList.count + self.searchGroupList.count + self.searchFriendList.count > 0) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 32)];
            header.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.tableView.frame.size.width, 32)];
            
            label.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
            label.textColor = [UIColor colorWithHexString:@"0x828282"];
            label.textAlignment = NSTextAlignmentLeft;
            
            int sec = 0;
            if (self.searchFriendList.count) {
                sec++;
                if (section == sec-1) {
                    label.text = WFCString(@"Contact");
                }
            }
            
            if (self.searchGroupList.count) {
                sec++;
                if (section == sec-1) {
                    label.text = WFCString(@"Group");
                }
            }
            
            if (self.searchConversationList.count) {
                sec++;
                if (sec-1 == section) {
                    label.text = WFCString(@"Message");
                }
            }
            
            [header addSubview:label];
            return header;
        } else {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
            return header;
        }
    } else {
        self.tableHeaderViewHeight = 40.0;
        return self.tableHeaderView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return 32;
    }
    return self.tableHeaderViewHeight;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (self.searchController.active) {
        return NO;
    }
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) ws = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:ws.conversations[indexPath.row].conversation];
        [[WFCCIMService sharedWFCIMService] removeConversation:ws.conversations[indexPath.row].conversation clearMessage:YES];
        [ws.conversations removeObjectAtIndex:indexPath.row];
        [ws updateBadgeNumber];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UITableViewRowAction *setTop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Pinned") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:YES success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
            hud.label.text = [NSString stringWithFormat:@"%@ error_code:%d", WFCString(@"UpdateFailure"), error_code];
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
    }];
    
    UITableViewRowAction *setUntop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Unpinned") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:NO success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
            hud.label.text = WFCString(@"UpdateFailure");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
        
        [self refreshList];
    }];
    UITableViewRowAction *unRead = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标为未读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WFCCConversationInfo * conversationInfo =  ws.conversations[indexPath.row];
        conversationInfo.unreadCount.unread = 1;
        WFCCMessage * lastMessage = conversationInfo.lastMessage;
        NSLog(@"更新后 updateLastMessage %ld",(long)lastMessage.status);
        long lastMessageId =  lastMessage.messageId;
        lastMessage.status = Message_Status_Unread;
       
        bool updateLastMessage = [[WFCCIMService sharedWFCIMService] updateMessage:lastMessageId status:Message_Status_Unread];
         [[WFCCIMService sharedWFCIMService] updateMessage:lastMessageId content:lastMessage.content];
        NSLog(@"更新后 updateLastMessage %d",updateLastMessage);
    
        [self refreshList];
        
    }];
    UITableViewRowAction *readed = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标为已读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [[WFCCIMService sharedWFCIMService] clearUnreadStatus:ws.conversations[indexPath.row].conversation];
           [self refreshList];
       }];
    
    
    setTop.backgroundColor = kMainColor;
    setUntop.backgroundColor = [UIColor redColor];
    NSMutableArray *actions = [NSMutableArray array];
    if (self.conversations[indexPath.row].isTop) {
        [actions addObject:delete];
        [actions addObject:setUntop];
    } else {
        [actions addObject:delete];
        [actions addObject:setTop];
    }
    // 需要判断是否消息免打扰
    if (!self.conversations[indexPath.row].isSilent) {
        if (self.conversations[indexPath.row].unreadCount.unread > 0 ) {
            [actions addObject:readed];
        } else {
            [actions addObject:unRead];
        }
    }
    
    return [actions copy];
};

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        int sec = 0;
        if (self.searchFriendList.count) {
            sec++;
            if (indexPath.section == sec-1) {
                if (!self.isSearchFriendListExpansion && indexPath.row == 2) {
                    self.isSearchFriendListExpansion = YES;
                    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
                    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                    WFCCUserInfo *info = self.searchFriendList[indexPath.row];
                    mvc.conversation = [[WFCCConversation alloc] init];
                    mvc.conversation.type = Single_Type;
                    mvc.conversation.target = info.userId;
                    mvc.conversation.line = 0;
                    
                    mvc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:mvc animated:YES];
                }

            }
        }
        
        if (self.searchGroupList.count) {
            sec++;

            if (indexPath.section == sec-1) {
                if (!self.isSearchGroupListExpansion && indexPath.row == 2) {
                    self.isSearchGroupListExpansion = YES;
                      NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
                      [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                    WFCCGroupSearchInfo *info = self.searchGroupList[indexPath.row];
                    mvc.conversation = [[WFCCConversation alloc] init];
                    mvc.conversation.type = Group_Type;
                    mvc.conversation.target = info.groupInfo.target;
                    mvc.conversation.line = 0;
                    
                    mvc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:mvc animated:YES];
                }

            }
        }
        
        if (self.searchConversationList.count) {
            sec++;


            if (sec-1 == indexPath.section) {
                if (!self.isSearchConversationListExpansion && indexPath.row == 2) {
                    self.isSearchConversationListExpansion = YES;
                    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
                    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    WFCCConversationSearchInfo *info = self.searchConversationList[indexPath.row];
                         if (info.marchedCount == 1) {
                             WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                             
                             mvc.conversation = info.conversation;
                             mvc.highlightMessageId = info.marchedMessage.messageId;
                             mvc.highlightText = info.keyword;
                             mvc.hidesBottomBarWhenPushed = YES;
                             [self.navigationController pushViewController:mvc animated:YES];
                         } else {
                             WFCUConversationSearchTableViewController *mvc = [[WFCUConversationSearchTableViewController alloc] init];
                             mvc.conversation = info.conversation;
                             mvc.keyword = info.keyword;
                             mvc.hidesBottomBarWhenPushed = YES;
                             [self.navigationController pushViewController:mvc animated:YES];
                         }
                }
     
            }
        }
    } else {
        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
        WFCCConversationInfo *info = self.conversations[indexPath.row];
        mvc.conversation = info.conversation;
        mvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _searchController = nil;
    _searchConversationList       = nil;
}

#pragma mark - UISearchControllerDelegate
- (void)didPresentSearchController:(UISearchController *)searchController {
    self.searchController.view.frame = self.view.bounds;
    self.isSearchFriendListExpansion = NO;
    self.isSearchConversationListExpansion = NO;
    self.isSearchGroupListExpansion = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self exchangeTableHeaderAndFooter:true];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self exchangeTableHeaderAndFooter:false];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    if (searchString.length) {
        self.searchConversationList = [[WFCCIMService sharedWFCIMService] searchConversation:searchString inConversation:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
        self.searchFriendList = [[WFCCIMService sharedWFCIMService] searchFriends:searchString];
        self.searchGroupList = [[WFCCIMService sharedWFCIMService] searchGroups:searchString];
    } else {
        self.searchConversationList = nil;
        self.searchFriendList = nil;
        self.searchGroupList = nil;
    }
    
    [self.tableView reloadData];
}


@end
