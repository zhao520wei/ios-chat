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
#import "WFCUBrowserViewController.h"
#import "FileListParm.h"
#import "WFCTopImageBottomLabelButton.h"
#import "MBProgressHUD.h"

@interface WFCFileViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate ,UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)NSMutableArray * originalDataArray;

@property (nonatomic, strong) NSMutableArray *searchList;
@property (nonatomic, strong) NSMutableArray *originalSearchArray;

@property(nonatomic, assign)BOOL sorting;
@property(nonatomic, assign)BOOL needSort;
@property(nonatomic, strong) NSString * searchKeyword;

@property (nonatomic, strong) UIStackView *headerStackView;
@property (nonatomic, strong) WFCTopImageBottomLabelButton * wordBtn;
@property (nonatomic, strong) WFCTopImageBottomLabelButton * excelBtn;
@property (nonatomic, strong) WFCTopImageBottomLabelButton * pptBtn;
@property (nonatomic, strong) WFCTopImageBottomLabelButton * pdfBtn;

@end

@implementation WFCFileViewController

-(instancetype)initWithFileType:(WFCCFileType)type {
    self = [super init];
    if (self) {
        self.type = type;
        
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (self.type) {
        case File_all:
            self.title = @"档案";
            break;
        case File_word:
            self.title = @"所有Word文件";
            break;
        case File_excel:
            self.title = @"所有Excel文件";
            break;
        case File_ppt:
            self.title = @"所有PPT文件";
            break;
        case File_pdf:
            self.title = @"所有PDF文件";
            break;
        default:
            break;
    }
    
    
    [self setupTableViewAndSearchView];
    
    [self setupTableViewHeader];
    
    [self tableViewRefreshActionWithRefresh:YES];
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
    switch (self.type) {
        case File_all:
            [self.searchController.searchBar setPlaceholder:@"搜索所有文件"];
            break;
        case File_word:
            [self.searchController.searchBar setPlaceholder:@"搜索word文件"];
            break;
        case File_excel:
            [self.searchController.searchBar setPlaceholder:@"搜索excel文件"];
            break;
        case File_ppt:
            [self.searchController.searchBar setPlaceholder:@"搜索ppt文件"];
            break;
        case File_pdf:
            [self.searchController.searchBar setPlaceholder:@"搜索pdf文件"];
            break;
        default:
            [self.searchController.searchBar setPlaceholder:@"搜索所有文件"];
            break;
    }
    
    
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
    
    if (self.searchController.active || self.type != File_all) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
        self.tableView.tableHeaderView = view;
        return;
    }
    
    self.headerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.wordBtn, self.excelBtn, self.pptBtn, self.pdfBtn]];
    self.headerStackView.frame = CGRectMake(40, 10, self.view.bounds.size.width - 80, 80);
    self.headerStackView.alignment = UIStackViewAlignmentFill;
    self.headerStackView.axis = UILayoutConstraintAxisHorizontal;
    CGFloat space = (self.view.bounds.size.width - 80 - 35 * 4)/ 3;
    self.headerStackView.spacing = space;
    self.headerStackView.distribution = UIStackViewDistributionFillEqually;
    
    
    //    [self.tableHeaderView addSubview:self.headerStackView];
    UIView * tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    [tableHeaderView addSubview:self.headerStackView];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)tableViewRefreshActionWithRefresh:(BOOL)isRefresh {
    // 下拉刷新MJRefreshNormalHeader
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        FileListParm * parm = [[FileListParm alloc] init];
        parm.pageIndex = 1;
        switch (weakSelf.type) {
            case File_all:
                parm.type = 0;
                break;
            case File_word:
                parm.type = 1;
                break;
            case File_excel:
                parm.type = 2;
                break;
            case File_ppt:
                parm.type = 3;
                break;
            case File_pdf:
                parm.type = 4;
                break;
            default:
                 parm.type = 0;
                break;
        }
        if (weakSelf.searchController.active) {
            parm.content = weakSelf.searchKeyword;
        } else {
            parm.content = @"";
        }
        [[AppService sharedAppService] loadFileListWithType:parm withSuccess:^(NSDictionary * _Nonnull tree) {
            // 结束刷新
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.originalDataArray removeAllObjects];
            [weakSelf.originalSearchArray removeAllObjects];
            if (weakSelf.searchController.active) {
                [weakSelf handleSearchFileList:tree];
            } else {
                [weakSelf handleFileList:tree];
            }
            
        } error:^(NSInteger error_code) {
            // 结束刷新
            [weakSelf.tableView.mj_header endRefreshing];
        }];
        
        if (!self.searchController.isActive && self.type == File_all) {
            [[AppService sharedAppService] loadFileGroupInfoWithContent:@"" withSuccess:^(NSArray * _Nonnull tree) {
                [weakSelf handleFileGroupInfo:tree];
            } error:^(NSInteger error_code) {
                
            }];
        }
        
        
    }];
    
    // 马上进入刷新状态
    if (!self.searchController.active && isRefresh) {
        [self.tableView.mj_header beginRefreshing];
    }
    
    
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        
        FileListParm * parm = [[FileListParm alloc] init];
        int length = 0;
        switch (weakSelf.type) {
            case File_all:
                parm.type = 0;
                break;
            case File_word:
                parm.type = 1;
                break;
            case File_excel:
                parm.type = 2;
                break;
            case File_ppt:
                parm.type = 3;
                break;
            case File_pdf:
                parm.type = 4;
                break;
            default:
                 parm.type = 0;
                break;
        }
        
        if (weakSelf.searchController.active) {
            for (WFCFileModel * model  in weakSelf.searchList) {
                length += model.files.count;
            }
            parm.pageIndex = length/20 + 1;
            parm.content = weakSelf.searchKeyword;
        } else {
            for (WFCFileModel * model  in weakSelf.dataArray) {
                length += model.files.count;
            }
            parm.pageIndex = length/20 + 1;
            parm.content = @"";
            // 判断是否已经最后一页了
            if (length % 20 != 0) { // 会出现最后一页正好是20的尾端情况
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
        }
       
        [[AppService sharedAppService] loadFileListWithType:parm withSuccess:^(NSDictionary * _Nonnull tree) {
            // 结束刷新
            [weakSelf.tableView.mj_footer endRefreshing];
            if (weakSelf.searchController.active) {
                [weakSelf handleSearchFileList:tree];
            } else {
                [weakSelf handleFileList:tree];
            }
        } error:^(NSInteger error_code) {
            // 结束刷新
            [weakSelf.tableView.mj_header endRefreshing];
        }];
        
    }];
    
}

- (void) switchTableHeaderRefresh {
    if (self.searchController.active) {
//        [self.tableView.mj_header removeFromSuperview];
    } else {
        [self tableViewRefreshActionWithRefresh:NO];
    }
}

- (void)buttonActions:(WFCTopImageBottomLabelButton *)button {
    WFCCFileType type;
    switch (button.buttonTag) {
        case 1:
            type = File_word;
            break;
        case 2:
            type = File_excel;
            break;
        case 3:
            type = File_ppt;
            break;
        case 4:
            type = File_pdf;
            break;
        default:
            type = File_all;
            break;
    }
    
    WFCFileViewController * fileVC = [[WFCFileViewController alloc] initWithFileType:type];
    fileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fileVC animated:YES];
}

#pragma mark - Network

- (void) handleFileList:(NSDictionary *)result {
    NSArray * fileList = result[@"fileList"];
//    NSDictionary * pagination = result[@"pagination"];
    [self.dataArray removeAllObjects];
    
    for (NSDictionary * dic in fileList) {
        SingleFileModel * model = [[SingleFileModel alloc] initWithDic:dic];
        [self.originalDataArray addObject:model];
    }
    
    
    NSMutableArray *timeArr = [NSMutableArray array];
    //首先把原数组中数据的日期取出来放入timeArr
    [self.originalDataArray enumerateObjectsUsingBlock:^(SingleFileModel *model, NSUInteger idx, BOOL *stop) {
        //这里只是根据日期判断，所以去掉时间字符串
        [timeArr addObject:model.timeStr];
    }];
    //日期去重
    NSSet *set = [NSSet setWithArray:timeArr];
    NSArray *userArray = [set allObjects];
    
    //重新降序排序
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];//yes升序排列，no,降序排列
    NSArray *descendingDateArr = [userArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, nil]];
    
    // 此时得到的descendingDateArr就是按照时间降序排好的日期数组
    __weak __typeof(self) weakSelf = self;
    //根据日期数组的个数，生成对应数量的外层model，外层model的detailModelArr置为空数组，放置子model（每一行显示的数据model）
    [descendingDateArr enumerateObjectsUsingBlock:^(NSString * timeStr, NSUInteger idx, BOOL * _Nonnull stop) {
        WFCFileModel *om = [[WFCFileModel alloc]init];
        om.timestampStr = timeStr;
        [om.files removeAllObjects];
        [weakSelf.dataArray addObject:om];
    }];
    
    //遍历未经处理的数组，取其中每个数据的日期，看与降序排列的日期数组相比，若日期匹配就把这个数据装到对应的外层model中
    
    [self.originalDataArray enumerateObjectsUsingBlock:^(SingleFileModel *singleFileModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSString *str in descendingDateArr) {
            if([str isEqualToString:singleFileModel.timeStr]) {
                WFCFileModel *om = [weakSelf.dataArray objectAtIndex:[descendingDateArr indexOfObject:str]];
                [om.files addObject:singleFileModel];
            }
        }
    }];
    
    if (fileList.count < 20) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    [self.tableView reloadData];
    if (self.dataArray.count == 0) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"没有历史文件数据";
        [hud hideAnimated:YES afterDelay:1.f];
    }
}

- (void) handleSearchFileList:(NSDictionary *)result {
    NSArray * fileList = result[@"fileList"];
//    NSDictionary * pagination = result[@"pagination"];
    [self.searchList removeAllObjects];
    
    for (NSDictionary * dic in fileList) {
        SingleFileModel * model = [[SingleFileModel alloc] initWithDic:dic];
        [self.originalSearchArray addObject:model];
    }
    
    
    NSMutableArray *timeArr = [NSMutableArray array];
    //首先把原数组中数据的日期取出来放入timeArr
    [self.originalSearchArray enumerateObjectsUsingBlock:^(SingleFileModel *model, NSUInteger idx, BOOL *stop) {
        //这里只是根据日期判断，所以去掉时间字符串
        [timeArr addObject:model.timeStr];
    }];
    //日期去重
    NSSet *set = [NSSet setWithArray:timeArr];
    NSArray *userArray = [set allObjects];
    
    //重新降序排序
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];//yes升序排列，no,降序排列
    NSArray *descendingDateArr = [userArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, nil]];
    
    // 此时得到的descendingDateArr就是按照时间降序排好的日期数组
    __weak __typeof(self) weakSelf = self;
    //根据日期数组的个数，生成对应数量的外层model，外层model的detailModelArr置为空数组，放置子model（每一行显示的数据model）
    [descendingDateArr enumerateObjectsUsingBlock:^(NSString * timeStr, NSUInteger idx, BOOL * _Nonnull stop) {
        WFCFileModel *om = [[WFCFileModel alloc]init];
        om.timestampStr = timeStr;
        [om.files removeAllObjects];
        [weakSelf.searchList addObject:om];
    }];
    
    //遍历未经处理的数组，取其中每个数据的日期，看与降序排列的日期数组相比，若日期匹配就把这个数据装到对应的外层model中
    [self.originalSearchArray enumerateObjectsUsingBlock:^(SingleFileModel *singleFileModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSString *str in descendingDateArr) {
            if([str isEqualToString:singleFileModel.timeStr]) {
                WFCFileModel *om = [weakSelf.searchList objectAtIndex:[descendingDateArr indexOfObject:str]];
                [om.files addObject:singleFileModel];
            }
        }
    }];
    
    if (fileList.count < 20) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    [self.tableView reloadData];
    if (self.searchList.count == 0) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"没有找到对应的搜索结果";
        [hud hideAnimated:YES afterDelay:2.f];
    }
}

- (void) handleFileGroupInfo:(NSArray *)list {
    
    for (NSDictionary * dic in list) {
        int type = [dic[@"type"] intValue];
        int num = [dic[@"num"] intValue];
        NSString *numStr = [NSString stringWithFormat:@"%d",num] ;
        switch (type) {
            case 1:
                self.wordBtn.title = numStr;
                break;
            case 2:
                self.excelBtn.title = numStr;
                break;
            case 3:
                self.pptBtn.title = numStr;
                break;
            case 4:
                self.pdfBtn.title = numStr;
                break;
            default:
                break;
        }
    }
    [self.headerStackView setNeedsDisplay];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        WFCFileModel * fileModel = self.searchList[section];
        return fileModel.files.count;
    } else {
        WFCFileModel * fileModel = self.dataArray[section];
        return fileModel.files.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCFileCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    if (!cell) {
        cell = [[WFCFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileCell"];
    }
    if (self.searchController.active) {
        if (self.searchList.count == 0) {
            return cell;
        }
        WFCFileModel * fileSectionModel = self.searchList[indexPath.section];
        SingleFileModel * singleFileModel = fileSectionModel.files[indexPath.row];
        cell.model = singleFileModel;
    } else {
        WFCFileModel * fileSectionModel = self.dataArray[indexPath.section];
        SingleFileModel * singleFileModel = fileSectionModel.files[indexPath.row];
        cell.model = singleFileModel;
    }
    
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.active) {
        return self.searchList.count;
    } else {
        return self.dataArray.count;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, kScreenWidth-30, 20)];
    if (self.searchController.active && self.searchList.count > 0) {
        WFCFileModel * model = self.searchList[section];
        label.text = model.timestampStr;
    } else {
        WFCFileModel * model = self.dataArray[section];
        label.text = model.timestampStr;
    }
    label.font = [UIFont systemFontOfSize:15];
    [sectionHeader addSubview:label];
    sectionHeader.backgroundColor = [UIColor whiteColor];
    return  sectionHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footer.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return footer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
    if (self.searchController.active) {
        WFCFileModel * fileSectionModel = self.searchList[indexPath.section];
        SingleFileModel * singleFileModel = fileSectionModel.files[indexPath.row];
        bvc.url = singleFileModel.url;
        bvc.title = singleFileModel.name;
    } else {
        WFCFileModel * fileSectionModel = self.dataArray[indexPath.section];
        SingleFileModel * singleFileModel = fileSectionModel.files[indexPath.row];
        bvc.url = singleFileModel.url;
        bvc.title = singleFileModel.name;
    }
    bvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:bvc animated:YES];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
   
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if (self.type == File_all) {
        self.tabBarController.tabBar.hidden = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    [self setupTableViewHeader];
    [self switchTableHeaderRefresh];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if (self.type == File_all) {
        self.tabBarController.tabBar.hidden = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
}


- (void)didDismissSearchController:(UISearchController *)searchController {
    self.needSort = NO;
    self.searchKeyword = nil;
    [self.searchList removeAllObjects];
    [self setupTableViewHeader];
    [self switchTableHeaderRefresh];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        self.needSort = YES;
        NSString *searchString = [searchController.searchBar text];
        if (self.searchList!= nil) {
            [self.searchList removeAllObjects];
            self.searchKeyword = searchString;
            if (searchString.length > 0) {
                NSLog(@"----- %@", searchString);
                [searchController.searchBar resignFirstResponder];
                [self.tableView.mj_header beginRefreshing];
            }
            
        }
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

-(NSMutableArray *)originalDataArray{
    if (!_originalDataArray) {
        _originalDataArray = [NSMutableArray array];
    }
    return _originalDataArray;
}

-(NSMutableArray *)searchList{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}
-(NSMutableArray *)originalSearchArray{
    if (!_originalSearchArray) {
        _originalSearchArray = [NSMutableArray array];
    }
    return _originalSearchArray;
}

-(void)setNeedSort:(BOOL)needSort {
    _needSort = needSort;
    if (needSort && self.searchController.active) {
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

-(WFCTopImageBottomLabelButton *)wordBtn{
    if (!_wordBtn) {
        _wordBtn = [[WFCTopImageBottomLabelButton alloc]initWithFrame:CGRectMake(0, 0, 35, 70) withImage:[UIImage imageNamed:@"file_word"]];
        _wordBtn.buttonTag = 1;
        [_wordBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wordBtn;
}
-(WFCTopImageBottomLabelButton *)excelBtn {
    if (!_excelBtn) {
        _excelBtn = [[WFCTopImageBottomLabelButton alloc]initWithFrame:CGRectMake(0, 0, 35, 70) withImage:[UIImage imageNamed:@"file_excel"]];
        _excelBtn.buttonTag = 2;
        [_excelBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _excelBtn;
}
-(WFCTopImageBottomLabelButton *)pptBtn{
    if (!_pptBtn) {
        _pptBtn = [[WFCTopImageBottomLabelButton alloc]initWithFrame:CGRectMake(0, 0, 35, 70) withImage:[UIImage imageNamed:@"file_ppt"]];
        _pptBtn.buttonTag = 3;
        [_pptBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pptBtn;
}
-(WFCTopImageBottomLabelButton *)pdfBtn {
    if (!_pdfBtn) {
        _pdfBtn = [[WFCTopImageBottomLabelButton alloc]initWithFrame:CGRectMake(0, 0, 35, 70) withImage:[UIImage imageNamed:@"file_pdf"]];
        _pdfBtn.buttonTag = 4;
        [_pdfBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pdfBtn;
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



