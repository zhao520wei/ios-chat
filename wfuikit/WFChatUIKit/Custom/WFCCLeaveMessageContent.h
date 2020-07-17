//
//  WFCCApproveMessageContent.h
//  WFChatClient
//
//  Created by 赵伟 on 2020/7/14.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <WFChatClient/WFCChatClient.h>


NS_ASSUME_NONNULL_BEGIN


/// 请假审批消息
@interface WFCCLeaveMessageContent : WFCCMessageContent



/// 构造消息
/// @param reason 请假事由
/// @param startTime 开始时间
/// @param endTime 结束时间
/// @param status  当前状态
+ (instancetype)contentWith:(NSString *)reason
                  startTime:(int64_t)startTime
                    entTime:(int64_t)endTime
                     status:(int) status;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, assign) int64_t startTime;

@property (nonatomic, assign) int64_t endTime;

@property (nonatomic, copy) NSString * reason;

/// 目前所处的状态， 1 已提交 提交成功，2  1号人已审批 等待下级审批  = 2号人已审批等待下级审批    3  被驳回  4 已完成
@property (nonatomic, assign) int status;

/// 调整URL
@property(nonatomic, copy) NSString * targetUrl;


@end

NS_ASSUME_NONNULL_END
