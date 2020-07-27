//
//  WFCCLeaveMessageContent.m
//  WFChatClient
//
//  Created by 赵伟 on 2020/7/14.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCCLeaveMessageContent.h"
//#import "WFCCIMService.h"
//#import "Common.h"

@implementation WFCCLeaveMessageContent

-(WFCCMessagePayload *)encode{
    WFCCMessagePayload *payload = [super encode];
    payload.contentType = [self.class getContentType];
    payload.searchableContent = self.reason;
//    payload.binaryContent = UIImageJPEGRepresentation(self.thumbnail, 0.67);
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@(self.startTime) forKey:@"startTime"];
    [dataDict setObject:@(self.endTime) forKey:@"endTime"];
    [dataDict setObject:self.title forKey:@"title"];
    [dataDict setObject:self.targetUrl forKey:@"targetUrl"];
    [dataDict setObject:@(self.status) forKey:@"status"];
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

-(void)decode:(WFCCMessagePayload *)payload{
    [super decode:payload];
    self.reason = payload.searchableContent;
//    self.thumbnail = [UIImage imageWithData:payload.binaryContent];
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        int64_t startTime = [dictionary[@"startTime"] longLongValue];
        int64_t endTime = [dictionary[@"endTime"] longLongValue];
        self.startTime = startTime;
        self.endTime = endTime;
        NSArray * allKey = [dictionary allKeys];
        if ([allKey containsObject:@"title"]) {
            self.title = dictionary[@"title"];
        }
        if ([allKey containsObject:@"targetUrl"]) {
            self.targetUrl = dictionary[@"targetUrl"] ;
        }
        if ([allKey containsObject:@"status"]) {
            self.status = [dictionary[@"status"] intValue];
        }
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_LEAVE;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (instancetype)contentWithTitle:(NSString *)title
                          reason:(NSString *)reason
                       startTime:(int64_t)startTime
                         entTime:(int64_t)endTime
                          status:(int) status
                       targetUrl:(NSString *)targetUrl{
    WFCCLeaveMessageContent *content = [[WFCCLeaveMessageContent alloc] init];
    content.reason = reason;
    content.startTime = startTime;
    content.endTime = endTime;
    content.status = status;
    content.title = title;
    content.targetUrl = targetUrl;
    return content;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return @"[请假]";
}

@end
