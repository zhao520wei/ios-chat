//
//  OrganizationNode.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "OrganizationNode.h"

@implementation OrganizationNode

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}


-(NSMutableArray *)subList {
    if (!_subList) {
        _subList = [NSMutableArray array];
    }
    return  _subList;
}

-(NSMutableArray *)userList {
    if ( !_userList) {
        _userList = [NSMutableArray array];
    }
    return _userList;
}

@end
