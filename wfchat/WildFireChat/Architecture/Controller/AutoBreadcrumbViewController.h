//
//  AutoBreadcrumbViewController.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglePersonNode.h"

extern NSString * kGroupNodeMark;

@interface AutoBreadcrumbViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) BOOL isAbleSelected; // 是否是可选择状态

@property (nonatomic, assign) BOOL isSingleSelected; // 是单选还是多选。  单选时没有选择框

@property (nonatomic, copy) void(^selectedNode)(NSArray<SinglePersonNode *> *nodes);



@end
