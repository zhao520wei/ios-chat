//
//  WFCCUnivesalCustomMessageContent.m
//  WFChatClient
//
//  Created by 赵伟 on 2020/8/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCCUnivesalCustomMessageContent.h"

@implementation WFCCUnivesalCustomMessageContent

-(WFCCMessagePayload *)encode{
    WFCCMessagePayload *payload = [super encode];
    payload.contentType = [self.class getContentType];
    payload.searchableContent = self.title;
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    NSMutableArray * buttons = [NSMutableArray array];
    for (ButtonItem * item in self.buttons) {
        NSDictionary * dic = @{@"name":item.name, @"type":@(item.type), @"value":item.value};
        [buttons addObject:dic];
    }
    NSMutableArray * bodys = [NSMutableArray array];
    for (BodyItem * item in self.bodys) {
        NSDictionary * dic = @{@"name":item.name,  @"value":item.value};
        [bodys addObject:dic];
    }
    [dataDict setObject:buttons forKey:@"item"];
    [dataDict setObject:bodys forKey:@"body"];
    
    [dataDict setObject:self.title forKey:@"title"];
    [dataDict setObject:self.targetUrl forKey:@"targetUrl"];
    [dataDict setObject:@(self.status) forKey:@"status"];
    [dataDict setObject:self.tag forKey:@"tag"];
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

-(void)decode:(WFCCMessagePayload *)payload{
    [super decode:payload];
    self.title = payload.searchableContent;
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
    
        NSArray * allKey = [dictionary allKeys];
        if ([allKey containsObject:@"title"]) {
            self.title = dictionary[@"title"];
        }
        if ([allKey containsObject:@"targetUrl"]) {
            self.targetUrl = dictionary[@"targetUrl"] ;
        }
        if ([allKey containsObject:@"tag"]) {
            self.tag = dictionary[@"tag"] ;
        }
        if ([allKey containsObject:@"status"]) {
            self.status = [dictionary[@"status"] intValue];
        }
        if ([allKey containsObject:@"item"]) {
            NSArray * item = dictionary[@"item"];
            [self.buttons removeAllObjects];
            for (NSDictionary * dic in item) {
                ButtonItem * buttonItem = [[ButtonItem alloc] init];
                buttonItem.name =  dic[@"name"];
                buttonItem.type = [dic[@"type"] intValue];
                buttonItem.value = dic[@"value"];
                [self.buttons addObject:buttonItem];
            }
        }
        if ([allKey containsObject:@"body"]) {
            NSArray * item = dictionary[@"body"];
            [self.bodys removeAllObjects];
            for (NSDictionary * dic in item) {
                BodyItem * bodyItem = [[BodyItem alloc] init];
                bodyItem.name =  dic[@"name"];
                bodyItem.value = dic[@"value"];
                [self.bodys addObject:bodyItem];
            }
        }
        
        
    }
}

+(instancetype)contentWithTitle:(NSString *)title withButtons:(NSArray<ButtonItem *> *)buttons withBodys:(NSArray<BodyItem *> *)bodys withStatus:(int)status withTag:(NSString *)tag withTargetUrl:(NSString *)targetUrl {
    WFCCUnivesalCustomMessageContent *content = [[WFCCUnivesalCustomMessageContent alloc] init];
    content.title  = title;
    [content.buttons addObjectsFromArray:buttons];
    [content.bodys addObjectsFromArray:bodys];
    content.status = status;
    content.tag = tag;
    content.targetUrl = targetUrl;
    return content;
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_UNIVERSAL;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    if ([message.content isKindOfClass:[WFCCUnivesalCustomMessageContent class]]) {
        WFCCUnivesalCustomMessageContent * content = (WFCCUnivesalCustomMessageContent *)message.content;
        if (content.tag == nil) {
            return @"[自定义消息]";
        }
        return content.tag;
    } else {
        return @"[自定义消息]";
    }
}

-(NSMutableArray<ButtonItem *> *)buttons{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;;
}
-(NSMutableArray<BodyItem *> *)bodys{
    if (!_bodys) {
        _bodys = [NSMutableArray array];
    }
    return _bodys;
}

@end
