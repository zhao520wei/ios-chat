//
//  AutoBreadcrumbViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AutoBreadcrumbViewController.h"
#import "BreadcrumbHeaderView.h"
#import "AppService.h"
#import "OrganizationNode.h"

#import "TreeOrganizationDisplayCell.h"

 NSString * kGroupNodeMark = @"---";

@interface AutoBreadcrumbViewController ()
{
    BaseTreeNode *_baseNode;
}



/**
 面包屑
 */
@property (nonatomic, strong) BreadcrumbHeaderView *breadcrumbView;

@property (nonatomic, strong) UIButton *dismissBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, retain) NSMutableArray<SinglePersonNode *> * selectedNodes;

/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;
/**
 当前展示的node
 */
@property (nonatomic, strong) BaseTreeNode *currentNode;
/**
 tableview展开方式
 */
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;


@end

@implementation AutoBreadcrumbViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"组织架构";
    
    if (self.isAbleSelected) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dismissBtn];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sureBtn];
        [self clearAllSelectedNode];
    }
    
    self.rowAnimation = UITableViewRowAnimationNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self loadData];
    
    [self loadRealData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

- (void) loadRealData {
    __weak __typeof(self) weakSelf = self;

    [[AppService sharedAppService] loadCompanyArchitectureDataWithSuccess:^(NSDictionary * _Nonnull tree) {
        [weakSelf.view addSubview:weakSelf.tableview];
        [weakSelf dealwithDictionaryTree:tree];
    } error:^(NSInteger error_code) {
        
    }];
    
    //    [[AppService sharedAppService] getCompanyArchitectureDataWithSuccess:^(NSDictionary * _Nonnull tree) {
    //
    //        BaseTreeNode * baseNode = [weakSelf dealwithDictionaryTree:tree];
    //        _baseNode = baseNode;
    //        weakSelf.currentNode = baseNode;
    //        [weakSelf.view addSubview:weakSelf.tableview];
    //        [weakSelf.tableview reloadData];
    //    } error:^(NSInteger error_code) {
    //
    //    }];
    
}

- (void) dealwithDictionaryTree:(NSDictionary *) tree {
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;//父节点等于自身
    _baseNode = baseNode;
    
    //    NSString * address = [tree objectForKey:@"address"];
    //    NSString * createTime = [tree objectForKey:@"createTime"];
    //    NSString * itemId = [tree objectForKey:@"id"];
    //    NSString * name = [tree objectForKey:@"name"];
    //    NSString * pathIds = [tree objectForKey:@"pathIds"];
    NSMutableArray * subList = [tree mutableArrayValueForKey:@"subList"];
    NSMutableArray * userList = [tree mutableArrayValueForKey:@"userList"];
    
    //    OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
    //    simpleNode.name = name;
    //    simpleNode.address = address;
    //    simpleNode.itemId = itemId;
    //    simpleNode.pathIds = pathIds;
    //    simpleNode.createTime = createTime;
    //    simpleNode.nodeHeight = 50.0;
    
    if (subList != nil && subList.count > 0) {
        NSMutableArray * array = [self dealwithSubTree:subList];
        for (OrganizationNode * node in array) {
            [baseNode addSubNode:node];
        }
    }
    //    [baseNode addSubNode: simpleNode];
    
    if (userList != nil && userList.count > 0) {
        for (NSDictionary * tempDic in userList) {
            SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
            singlePersonNode1.nodeHeight = 50.0;
            singlePersonNode1.displayName = tempDic[@"displayName"];
            singlePersonNode1.address = tempDic[@"address"];
            singlePersonNode1.did = tempDic[@"did"];
            singlePersonNode1.gender = tempDic[@"gender"];
            singlePersonNode1.IDNum = tempDic[@"id"] ;
            singlePersonNode1.mobile = tempDic[@"mobile"];
            singlePersonNode1.password = tempDic[@"password"];
            singlePersonNode1.uid = tempDic[@"uid"];
            singlePersonNode1.name = tempDic[@"name"];
            [baseNode addSubNode:singlePersonNode1];
            
        }
        
    }
//    if (!self.isAbleSelected) {
//        // 添加群组
//        OrganizationNode *groupNode = [[OrganizationNode alloc]init];
//        groupNode.name = @"我的群组";
//        groupNode.address = kGroupNodeMark;
//        groupNode.itemId = @"";
//        groupNode.pathIds = @"";
//        groupNode.createTime = @"";
//        groupNode.nodeHeight = 60.0;
//        [baseNode addSubNode:groupNode];
//
//        NSArray *ids = [[WFCCIMService sharedWFCIMService] getFavGroups];
//
//        for (NSString *groupId in ids) {
//            WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:groupId refresh:NO];
//            if (groupInfo) {
//                groupInfo.target = groupId;
//                SinglePersonNode *singleGroupNode = [[SinglePersonNode alloc]init];
//                singleGroupNode.nodeHeight = 50.0;
//                singleGroupNode.name = groupInfo.name;
//                singleGroupNode.displayName = groupInfo.name;
//                singleGroupNode.uid = groupInfo.target;
//                singleGroupNode.address = kGroupNodeMark;
//                [groupNode addSubNode:singleGroupNode];
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:groupId];
//            }
//        }
//
//    }
    
    
    self.currentNode = baseNode;
    [self.tableview reloadData];
    
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
   
}


- (NSMutableArray *) dealwithSubTree:(NSArray *)subList {
    
    NSMutableArray * array = [NSMutableArray array];
    
    for (int i= 0; i < subList.count; i++) {
        NSDictionary * tree = subList[i];
        NSString * address = tree[@"address"];
        NSString * createTime = tree[@"createTime"];
        NSString * itemId = tree[@"id"];
        NSString * name = tree[@"name"];
        NSString * pathIds = tree[@"pathIds"];
        NSMutableArray * temSubList = [tree mutableArrayValueForKey:@"subList"];
        NSMutableArray * tempUserList = [tree mutableArrayValueForKey:@"userList"];
        OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
        simpleNode.name = name;
        simpleNode.address = address;
        simpleNode.itemId = itemId;
        simpleNode.pathIds = pathIds;
        simpleNode.createTime = createTime;
        simpleNode.nodeHeight = 50.0;
        
        if (temSubList != nil && temSubList.count > 0) {
            NSMutableArray * tempArray = [self dealwithSubTree:temSubList];
            for (OrganizationNode * node in tempArray) {
                [simpleNode addSubNode:node];
            }
        }
        if (tempUserList != nil && tempUserList.count > 0) {
            for (NSDictionary * tempDic in tempUserList) {
                SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
                singlePersonNode1.nodeHeight = 50;
                singlePersonNode1.displayName = tempDic[@"displayName"];
                singlePersonNode1.address = tempDic[@"address"];
                singlePersonNode1.did = tempDic[@"did"];
                singlePersonNode1.gender = tempDic[@"gender"];
                singlePersonNode1.IDNum = tempDic[@"id"] ;
                singlePersonNode1.mobile = tempDic[@"mobile"];
                singlePersonNode1.password = tempDic[@"password"];
                singlePersonNode1.uid = tempDic[@"uid"];
                singlePersonNode1.name = tempDic[@"name"];
                singlePersonNode1.nodeHeight = 50.0;
                [simpleNode addSubNode:singlePersonNode1];
            }
        }
        
        [array addObject: simpleNode];
    }
    
    return  array;
}


- (void)loadData{
    //数据处理
    [self.view addSubview:self.tableview];
    
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;//父节点等于自身
    _baseNode = baseNode;
    for (int i = 0; i<5; i++) {
        if (i<3) {
            OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
            simpleNode.name = [NSString stringWithFormat:@"部门%d",i];
            simpleNode.nodeHeight = 50;
            for (int j = 0; j<5; j++) {
                OrganizationNode *personNode = [[OrganizationNode alloc]init];
                personNode.nodeHeight = 50;
                personNode.name = [NSString stringWithFormat:@"%@的分部门%d",simpleNode.name,j];
                for (int k = 0; k<6; k++) {
                    OrganizationNode *personNode0 = [[OrganizationNode alloc]init];
                    personNode0.name = [NSString stringWithFormat:@"分部门%d的人员%d",j,k];
                    personNode0.nodeHeight = 50;
                    for (int m = 0; m<7; m++) {
                        SinglePersonNode *personNode1 = [[SinglePersonNode alloc]init];
                        personNode1.nodeHeight = 50;
                        personNode1.name = [NSString stringWithFormat:@"%@-张三%d",personNode.name,m];
                        personNode1.IDNum =@"1003022";
                        personNode1.displayName =@"资金部";
                        [personNode0 addSubNode:personNode1];
                    }
                    [personNode addSubNode:personNode0];
                }
                [simpleNode addSubNode:personNode];
            }
            [baseNode addSubNode:simpleNode];
        }else{
            SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
            singlePersonNode1.nodeHeight = 45;
            singlePersonNode1.name = [NSString stringWithFormat:@"张三%d",i];
            singlePersonNode1.IDNum =@"1003022";
            [baseNode addSubNode:singlePersonNode1];
        }
    }
    self.currentNode = baseNode;
    [self.tableview reloadData];
}

#pragma mark ======== System Delegate ========

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 这个应该是单颗树下最多数量 * 50
    return  kScreenHeight - kTabBarHeight ; //self.currentNode.subTreeHeight
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentNode? 1:0;
}


#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleBreadcrumbs treeRefreshPolicy:NodeTreeRefreshPolicyAutomic];
        cell.isSingleSelected = self.isSingleSelected;
        //cell事件的block回调,只负责将所选择的点传递出来，更新headerview，不需要手动刷新
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            
            if (self.isSingleSelected) {
                if ([node isMemberOfClass:[SinglePersonNode class]]) {
                    SinglePersonNode * single = (SinglePersonNode *)node;
                    weakSelf.selectedNode(@[single]);
                    [weakSelf dismiss];
                } else {
                    [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
                }
            } else {
              [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
            }
            
            //            if (node.subNodes.count > 0) {
            //[weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
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
    if (self.isSingleSelected) {
         [self.navigationController popViewControllerAnimated:true];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) sure {
    // self.currentNode 中找出所有选中的Node
    [self preorder:self.currentNode];
    
    if (self.selectedNode) {
        self.selectedNode([self.selectedNodes copy]);
    }
    
    if (self.isSingleSelected) {
        [self.navigationController popViewControllerAnimated:true];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void) clearAllSelectedNode {
    
}

#pragma mark ======== Private Methods ========

/// 前序遍历
- (void)preorder:(BaseTreeNode *)node {
    
    if ([node isMemberOfClass:[SinglePersonNode class]]) {
        SinglePersonNode * single = (SinglePersonNode *)node;
        if (single.selected) {
            [self.selectedNodes addObject:single];
        }
    }
    if (node.subNodes == nil || node.subNodes.count == 0) {
        return;
    }
    for (BaseTreeNode *tempNode in node.subNodes) {
        [self preorder:tempNode];
    }
    
    
}

#pragma mark ======== Setters && Getters ========
- (BreadcrumbHeaderView *)breadcrumbView{
    if (!_breadcrumbView) {
        _breadcrumbView = [[BreadcrumbHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        _breadcrumbView.alwaysBounceVertical = NO;
        _breadcrumbView.bounces = YES;
        _breadcrumbView.showsHorizontalScrollIndicator = YES;
        _breadcrumbView.backgroundColor = [UIColor groupTableViewBackgroundColor];
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

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - kTabBarHeight - 64) style:UITableViewStylePlain];
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
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


