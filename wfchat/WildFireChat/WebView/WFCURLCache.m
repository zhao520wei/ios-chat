//
//  WFCURLCache.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/7/29.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCURLCache.h"

@implementation WFCURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
   // 可以在此处进行拦截并执行相应的操作
   NSLog(@"url-------%@",request.URL.absoluteString);
   if ([request.URL.absoluteString isEqualToString:@""]) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"text/plain" expectedContentLength:1 textEncodingName:nil];
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:[NSData dataWithBytes:" " length:1]];
        [super storeCachedResponse:cachedResponse forRequest:request];
    }
   return [super cachedResponseForRequest:request];
}

@end
