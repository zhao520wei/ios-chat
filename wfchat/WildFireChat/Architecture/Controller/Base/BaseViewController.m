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



@end

@implementation BaseViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentNode? 1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.currentNode.nodeHeight;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleBreadcrumbs];
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

#pragma mark ======== Private Methods ========


- (void) loadRealData {
    __weak __typeof(self) weakSelf = self;
    [self.view addSubview:self.tableview];
    [[AppService sharedAppService] loadCompanyArchitectureDataWithSuccess:^(NSDictionary * _Nonnull tree) {
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
    
    self.currentNode = baseNode;
    [self.tableview reloadData];
    
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


