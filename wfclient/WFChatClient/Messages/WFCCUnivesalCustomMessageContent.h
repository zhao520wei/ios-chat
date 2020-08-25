//
//  WFCCUnivesalCustomMessageContent.h
//  WFChatClient
//
//  Created by 赵伟 on 2020/8/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <WFChatClient/WFCChatClient.h>
#import "ButtonItem.h"
#import "BodyItem.h"

NS_ASSUME_NONNULL_BEGIN


@interface WFCCUnivesalCustomMessageContent : WFCCMessageContent


+ (instancetype)contentWithTitle:(NSString *)title withButtons:(NSArray<ButtonItem *> *) buttons   withBodys:(NSArray<BodyItem *> *)bodys withStatus:(int)status withTag:(NSString *)tag withTargetUrl:(NSString *)targetUrl;


@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSMutableArray<ButtonItem *> *buttons;

@property (nonatomic, strong) NSMutableArray<BodyItem *> *bodys;


/// 目前所处的状态， 1 已提交 提交成功，2  1号人已审批 等待下级审批  = 2号人已审批等待下级审批    3  被驳回  4 已完成
@property (nonatomic, assign) int status;

@property (nonatomic, copy) NSString * tag;
/// 调整URL
@property(nonatomic, copy) NSString * targetUrl;

@end

NS_ASSUME_NONNULL_END
