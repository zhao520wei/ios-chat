//
//  ButtonItem.h
//  WFChatClient
//
//  Created by 赵伟 on 2020/8/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ButtonItem : NSObject
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString * _Nullable value;
@end

NS_ASSUME_NONNULL_END
