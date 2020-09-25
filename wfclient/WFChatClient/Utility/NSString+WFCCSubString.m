//
//  NSString+WFCCSubString.m
//  WFChatClient
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "NSString+WFCCSubString.h"
#import "WFCCNetworkService.h"

@implementation NSString (WFCCSubString)

-(NSString *)wfccPrefixFirstRemove{
    WFCCNetworkService * imService = [WFCCNetworkService sharedInstance];
    NSString * host = [imService getHost];
    NSString * replaceStr = [NSString stringWithFormat:@"http://%@:80/", host];
    if ([self hasPrefix:@"/"]) {
        NSString * newUrl = [self substringFromIndex:1];
        return newUrl;
    } else {
        return self;
    }
}

@end
