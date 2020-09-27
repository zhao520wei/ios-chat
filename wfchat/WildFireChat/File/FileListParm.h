//
//  FileListParm.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/27.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileListParm : NSObject

@property(nonatomic, assign) int type;
@property(nonatomic, strong) NSString * content;
@property(nonatomic, assign) int  pageIndex;
@property(nonatomic, assign) int pageSize;

@end

NS_ASSUME_NONNULL_END
