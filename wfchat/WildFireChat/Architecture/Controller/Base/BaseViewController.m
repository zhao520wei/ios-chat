//
//  BaseViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/30.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BaseViewController.h"
#import "AppService.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation BaseViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rowAnimation = UITableViewRowAnimationNone;
    self.view.backgroundColor = [UIColor whiteColor];
   
//    [self.view addSubview:self.dismissBtn];
    
//    [self loadData];
    
    [self loadRealData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentNode?1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.currentNode.currentTreeHeight;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleExpansion];
        //cell事件的block回调
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            [weakSelf selectNode:node nodeTreeAnimation:UITableViewRowAnimationNone];
        };
    }
    [cell reloadTreeViewWithNode:self.currentNode RowAnimation:UITableViewRowAnimationNone];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ======== Private Methods ========


- (void) loadRealData {
    __weak __typeof(self) weakSelf = self;
    [[AppService sharedAppService] getCompanyArchitectureDataWithSuccess:^(NSDictionary * _Nonnull tree) {
        
        BaseTreeNode * baseNode = [weakSelf dealwithDictionaryTree:tree];
        _baseNode = baseNode;
        weakSelf.currentNode = baseNode;
        [weakSelf.view addSubview:weakSelf.tableview];
        [weakSelf.tableview reloadData];
    } error:^(NSInteger error_code) {
        
    }];
    
}


- (BaseTreeNode *) dealwithDictionaryTree:(NSDictionary *) tree {
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;//父节点等于自身
    
    NSString * address = [tree objectForKey:@"address"];
    NSString * createTime = [tree objectForKey:@"createTime"];
    NSString * itemId = [tree objectForKey:@"id"];
    NSString * name = [tree objectForKey:@"name"];
    NSString * pathIds = [tree objectForKey:@"pathIds"];
    NSMutableArray * subList = [tree mutableArrayValueForKey:@"subList"];
    NSMutableArray * userList = [tree mutableArrayValueForKey:@"userList"];
    
    OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
    simpleNode.name = name;
    simpleNode.address = address;
    simpleNode.itemId = itemId;
    simpleNode.pathIds = pathIds;
    simpleNode.createTime = createTime;
    
    [baseNode addSubNode:simpleNode];
   
    if (subList != nil && subList.count > 0) {
        NSMutableArray * array = [self dealwithSubTree:subList];
        simpleNode.userList = array;
        for (OrganizationNode * node in array) {
            [simpleNode addSubNode:node];
        }
    }
    
    if (userList != nil && userList.count > 0) {
        for (NSDictionary * tempDic in userList) {
            SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
            singlePersonNode1.nodeHeight = 50;
            singlePersonNode1.name = tempDic[@"displayName"];
            singlePersonNode1.address = tempDic[@"address"];
            singlePersonNode1.did = tempDic[@"did"];
            singlePersonNode1.gender = tempDic[@"gender"];
            singlePersonNode1.IDNum = tempDic[@"id"] ;
            singlePersonNode1.mobile = tempDic[@"mobile"];
            singlePersonNode1.password = tempDic[@"password"];
            singlePersonNode1.uid = tempDic[@"uid"];
            [baseNode addSubNode:singlePersonNode1];
        }
        
    }
    
    return  baseNode;
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
        simpleNode.subList = temSubList;
        NSMutableArray * users = [NSMutableArray array];
        if (temSubList != nil && temSubList.count > 0) {
            NSMutableArray * tempArray = [self dealwithSubTree:temSubList];
            [users addObjectsFromArray:tempArray];
            for (OrganizationNode * node in tempArray) {
                [simpleNode addSubNode:node];
            }
        }
        if (tempUserList != nil && tempUserList.count > 0) {
            for (NSDictionary * tempDic in tempUserList) {
                SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
                singlePersonNode1.nodeHeight = 50;
                singlePersonNode1.name = tempDic[@"displayName"];
                singlePersonNode1.address = tempDic[@"address"];
                singlePersonNode1.did = tempDic[@"did"];
                singlePersonNode1.gender = tempDic[@"gender"];
                singlePersonNode1.IDNum = tempDic[@"id"] ;
                singlePersonNode1.mobile = tempDic[@"mobile"];
                singlePersonNode1.password = tempDic[@"password"];
                singlePersonNode1.uid = tempDic[@"uid"];
                [simpleNode addSubNode:singlePersonNode1];
            }
        }
        
        simpleNode.userList = [users copy];
        [array addObject: simpleNode];
    }
    
    return  array;
}



- (void)loadData{
    //数据处理
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;//父节点等于自身
    _baseNode = baseNode;
    for (int i = 0; i<10; i++) {
        if (i<8) {
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

- (void)selectNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation{
    self.currentNode = node;
    [self.tableview reloadData];
}

#pragma mark ======== Setters && Getters ========
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(6,12 , 44, 40);
        _dismissBtn.contentMode = UIViewContentModeLeft;
        [_dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
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


