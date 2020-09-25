//
//  WFCFileModel.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCFileModel : NSObject

@property (nonatomic, strong) NSMutableArray<SingleFileModel *> * files;

@property (nonatomic, strong) NSString * timestampStr;

- (instancetype ) initWithDic:(NSDictionary *)dic ;

@end

NS_ASSUME_NONNULL_END

