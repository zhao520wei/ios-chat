//
//  WFCFileViewController.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFileViewController.h"
#import "WFCUConfigManager.h"
#import "UIImage+ERCategory.h"
#import "UIColor+YH.h"
#import "UIButton+ZWImagePosition.h"
#import "MJRefresh.h"
#import "AppService.h"
#import "WFCFileModel.h"
#import "WFCFileCell.h"

@interface WFCFileViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate ,UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *searchList;

@property(nonatomic, assign)BOOL sorting;
@property(nonatomic, assign)BOOL needSort;

@property (nonatomic, strong) UIStackView *headerStackView;
@property (nonatomic, strong) UIButton * wordBtn;
@property (nonatomic, strong) UIButton * excelBtn;
@property (nonatomic, strong) UIButton * pptBtn;
@property (nonatomic, strong) UIButton * pdfBtn;
@end

@implementation WFCFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"档案";
    
    [self setupTableViewAndSearchView];
    
    [self setupTableViewHeader];
    
    [self tableViewRefreshAction];
}

- (void)setupTableViewAndSearchView {
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"expansion"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    if (@available(iOS 13, *)) {
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
        self.searchController.searchBar.searchTextField.backgroundColor = [WFCUConfigManager globalManager].naviBackgroudColor;
        UIImage* searchBarBg = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width - 8 * 2, 36) cornerRadius:4];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    } else {
        [self.searchController.searchBar setValue:WFCString(@"Cancel") forKey:@"_cancelButtonText"];
        UIImage* searchBarBg = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width - 8 * 2, 36) cornerRadius:4];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
        self.searchController.searchBar.delegate = self;
    }
    
    if (@available(iOS 9.1, *)) {
        self.searchController.obscuresBackgroundDuringPresentation = NO;
    }
    
    [self.searchController.searchBar setPlaceholder:@"搜索文件"];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchController;
        _searchController.hidesNavigationBarDuringPresentation = YES;
    } else {
        self.tableView.tableHeaderView = _searchController.searchBar;
    }
    self.definesPresentationContext = YES;
    
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x4e4e4e"];
    [self.view addSubview:self.tableView];
    
    [self.tableView reloadData];
}

- (void)setupTableViewHeader {
    UIColor * textColor = [WFCUConfigManager globalManager].textColor;
    
    self.wordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.wordBtn setImage:[UIImage imageNamed:@"file_word"] forState:UIControlStateNormal];
    [self.wordBtn setTitle:@"0" forState:UIControlStateNormal];
    self.wordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.wordBtn setImagePosition:ImagePositionTop spacing:5];
    [self.wordBtn setTitleColor:textColor forState:UIControlStateNormal];
    self.wordBtn.frame = CGRectMake(0, 0, 70, 70);
    
    self.excelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.excelBtn setImage:[UIImage imageNamed:@"file_excel"] forState:UIControlStateNormal];
    [self.excelBtn setTitle:@"0" forState:UIControlStateNormal];
    self.excelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.excelBtn setImagePosition:ImagePositionTop spacing:5];
    [self.excelBtn setTitleColor:textColor forState:UIControlStateNormal];
    self.excelBtn.frame = CGRectMake(0, 0, 70, 70);
    
    self.pptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pptBtn setImage:[UIImage imageNamed:@"file_ppt"] forState:UIControlStateNormal];
    [self.pptBtn setTitle:@"0" forState:UIControlStateNormal];
    self.pptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.pptBtn setImagePosition:ImagePositionTop spacing:5];
    [self.pptBtn setTitleColor:textColor forState:UIControlStateNormal];
    self.pptBtn.frame = CGRectMake(0, 0, 70, 70);
    
    self.pdfBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pdfBtn setImage:[UIImage imageNamed:@"file_pdf"] forState:UIControlStateNormal];
    [self.pdfBtn setTitle:@"0" forState:UIControlStateNormal];
    self.pdfBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.pdfBtn setImagePosition:ImagePositionTop spacing:5];
    [self.pdfBtn setTitleColor:textColor forState:UIControlStateNormal];
    self.pdfBtn.frame = CGRectMake(0, 0, 70, 70);
    
    
    self.headerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.wordBtn, self.excelBtn, self.pptBtn, self.pdfBtn]];
    self.headerStackView.frame = CGRectMake(40, 15, self.view.bounds.size.width - 80, 70);
    self.headerStackView.alignment = UIStackViewAlignmentFill;
    self.headerStackView.distribution = UIStackViewDistributionEqualSpacing;
//    [self.tableHeaderView addSubview:self.headerStackView];
    UIView * tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    [tableHeaderView addSubview:self.headerStackView];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)tableViewRefreshAction {
    // 下拉刷新
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    
        [[AppService sharedAppService] loadFileListWithType:0 withSuccess:^(NSDictionary * _Nonnull tree) {
            // 结束刷新
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf handleFileList:tree];
        } error:^(NSInteger error_code) {
            // 结束刷新
            [weakSelf.tableView.mj_header endRefreshing];
        }];
        
        [[AppService sharedAppService] loadFileGroupInfoWithContent:@"" withSuccess:^(NSArray * _Nonnull tree) {
            [weakSelf handleFileGroupInfo:tree];
        } error:^(NSInteger error_code) {
            
        }];
    
    }];
    
//    // 设置自动切换透明度(在导航栏下面自动隐藏)
//    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [weakSelf.tableView.mj_footer endRefreshing];
        });
    }];
}

- (void) handleFileList:(NSDictionary *)result {
    NSArray * fileList = result[@"fileList"];
    NSDictionary * pagination = result[@"pagination"];
    [self.dataArray removeAllObjects];
    for (NSDictionary * dic in fileList) {
        WFCFileModel * model = [[WFCFileModel alloc] initWithDic:dic];
        [self.dataArray addObject:model];
    }
    
    [self.tableView reloadData];
}

- (void) handleFileGroupInfo:(NSArray *)list {
    
    for (NSDictionary * dic in list) {
        int type = [dic[@"type"] intValue];
        int num = [dic[@"num"] intValue];
        NSString *numStr = [NSString stringWithFormat:@"%d",num] ;
        switch (type) {
            case 1:
                [self.wordBtn setTitle:numStr forState:UIControlStateNormal];
                break;
            case 2:
                [self.excelBtn setTitle:numStr forState:UIControlStateNormal];
                break;
            case 3:
                [self.pptBtn setTitle:numStr forState:UIControlStateNormal];
                break;
            case 4:
                [self.pdfBtn setTitle:numStr forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    
}


- (void)setNeedSort:(BOOL)needSort {
    _needSort = needSort;
    if (needSort && !self.sorting) {
        _needSort = NO;
        if (self.searchController.active) {
//            [self sortAndRefreshWithList:self.searchList];
        } else {
//            [self sortAndRefreshWithList:self.dataArray];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WFCFileModel * fileModel = self.dataArray[section];
    return fileModel.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCFileCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    if (!cell) {
        cell = [[WFCFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileCell"];
    }
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 20)];
    WFCFileModel * model = self.dataArray[section];
    label.text = model.timestampStr;
    label.font = [UIFont systemFontOfSize:15];
    [sectionHeader addSubview:label];
    sectionHeader.backgroundColor = [UIColor whiteColor];
    return  sectionHeader;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - UISearchControllerDelegate
- (void)didPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.needSort = YES;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        NSString *searchString = [self.searchController.searchBar text];
        if (self.searchList!= nil) {
            [self.searchList removeAllObjects];
            for (WFCCUserInfo *friend in self.dataArray) {
                if ([friend.displayName.lowercaseString containsString:searchString.lowercaseString] || [friend.friendAlias.lowercaseString containsString:searchString.lowercaseString]) {
                    [self.searchList addObject:friend];
                }
            }
        }
        self.needSort = YES;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    for (id cencelButton in [searchBar.subviews[0] subviews])
    {
        if([cencelButton isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cencelButton;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - get/set

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(NSMutableArray *)searchList{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
