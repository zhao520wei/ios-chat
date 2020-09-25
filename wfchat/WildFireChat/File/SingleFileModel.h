//
//  SingleFileModel.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingleFileModel : NSObject
@property (nonatomic, strong) NSString * fileTime;
@property (nonatomic, strong) NSString * from;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, assign) int  type;

-(instancetype)initWithDic:(NSDictionary *) dic;

@end

NS_ASSUME_NONNULL_END


