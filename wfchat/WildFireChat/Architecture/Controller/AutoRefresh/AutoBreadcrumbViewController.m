//
//  AutoBreadcrumbViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AutoBreadcrumbViewController.h"
#import "BreadcrumbHeaderView.h"

@interface AutoBreadcrumbViewController ()
/**
 面包屑
 */
@property (nonatomic, strong) BreadcrumbHeaderView *breadcrumbView;

@property (nonatomic, strong) UIButton *dismissBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, retain) NSMutableArray<SinglePersonNode *> * selectedNodes;

@end

@implementation AutoBreadcrumbViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"组织架构";
    
    if (self.isAbleSelected) {
        [self.view addSubview:self.dismissBtn];
        [self.view addSubview:self.sureBtn];
        
        [self clearAllSelectedNode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.currentNode.subTreeHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12;
}

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleBreadcrumbs treeRefreshPolicy:NodeTreeRefreshPolicyAutomic];
        //cell事件的block回调,只负责将所选择的点传递出来，更新headerview，不需要手动刷新
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
//            if (node.subNodes.count > 0) {
                [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
//            }
        };
    }
    cell.isAbleSelected = self.isAbleSelected;
    [cell reloadTreeViewWithNode:self.currentNode RowAnimation:self.rowAnimation];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.breadcrumbView;
}

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Method Overrides ========
- (void)selectNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation{
    //更新header
    if (node.subNodes.count>0) {
        if ([node isMemberOfClass:[SinglePersonNode class]]) {
            SinglePersonNode *personNode = (SinglePersonNode *)node;
            [self.breadcrumbView addSelectedNode:personNode withTitle:personNode.displayName];
        }else if ([node isMemberOfClass:[OrganizationNode  class]]){
            OrganizationNode *orgNode = (OrganizationNode *)node;
            [self.breadcrumbView addSelectedNode:orgNode withTitle:orgNode.name];
        }else{
            [self.breadcrumbView addSelectedNode:node withTitle:@"倚天科技公司"];
        }
    }
}

#pragma mark ======== Event Response ========

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) sure {
    // self.currentNode 中找出所有选中的Node
    [self preorder:self.currentNode];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) clearAllSelectedNode {
    
}

#pragma mark ======== Private Methods ========

/// 前序遍历
- (void)preorder:(BaseTreeNode *)node {
    if (node.subNodes != nil && node.subNodes.count > 0) {
        return;
    }
    
    if ([node isMemberOfClass:[SinglePersonNode class]]) {
        SinglePersonNode * single = (SinglePersonNode *)node;
        if (single.isSelected) {
            [self.selectedNodes addObject:single];
        }
    }
    
    [self preorder:node.subNodes];
    
}

#pragma mark ======== Setters && Getters ========
- (BreadcrumbHeaderView *)breadcrumbView{
    if (!_breadcrumbView) {
        _breadcrumbView = [[BreadcrumbHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        _breadcrumbView.alwaysBounceVertical = NO;
        _breadcrumbView.bounces = YES;
        _breadcrumbView.showsHorizontalScrollIndicator = YES;
        _breadcrumbView.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0];
        __weak typeof(self)weakSelf = self;
        [_breadcrumbView addSelectedNode:weakSelf.currentNode withTitle:@"倚天科技公司"];
        _breadcrumbView.selectNode = ^(BaseTreeNode *node,UITableViewRowAnimation nodeTreeAnimation) {
            if (node.subNodes.count == 0) {
                NSLog(@"do nothing");
            }else{
                weakSelf.currentNode = node;
                weakSelf.rowAnimation = UITableViewRowAnimationRight;
                [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
                [weakSelf.tableview reloadData];
            }
        };
    }
    return _breadcrumbView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(10,12 , 44, 40);
        _dismissBtn.contentMode = UIViewContentModeLeft;
        [_dismissBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(kScreenWidth - 10 - 44,12 , 44, 40);
        _sureBtn.contentMode = UIViewContentModeLeft;
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

-(NSMutableArray<SinglePersonNode *> *)selectedNodes {
    if (!_selectedNodes) {
        _selectedNodes = [NSMutableArray array];
    }
    return  _selectedNodes;
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


