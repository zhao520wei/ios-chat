//
//  SinglePersonNode.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTreeNode.h"
@interface SinglePersonNode : BaseTreeNode
/**
 姓名
 */
@property (nonatomic, copy) NSString * displayName;

@property (nonatomic, copy) NSString * IDNum;

@property (nonatomic, copy) NSString * did;

@property (nonatomic, copy) NSString * gender;

@property (nonatomic, copy) NSString * mobile;

@property (nonatomic, copy) NSString * name;

@property (nonatomic, copy) NSString * password;

@property (nonatomic, copy) NSString * uid;

@property (nonatomic, copy) NSString * address;

@property (nonatomic, copy) NSString * portrait;

/**
 是否选中
 */
@property (nonatomic, assign,getter=isSelected) BOOL selected;

@end
