//
//  OrganizationNode.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BaseTreeNode.h"

@interface OrganizationNode : BaseTreeNode
/**
 左侧标题
 */
@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *pathIds;
@property (nonatomic, copy) NSString * createTime;

@end
//Organization;

