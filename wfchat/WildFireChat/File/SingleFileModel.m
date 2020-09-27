//
//  SingleFileModel.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "SingleFileModel.h"

@implementation SingleFileModel

-(instancetype)initWithDic:(NSDictionary *) dic{
    SingleFileModel * model = [[SingleFileModel alloc] init];
    if ([dic.allKeys containsObject:@"fileTime"]) {
        model.fileTime = [dic[@"fileTime"] longLongValue];
    }
    if ([dic.allKeys containsObject:@"from"]) {
        model.from = dic[@"from"];
    }
    if ([dic.allKeys containsObject:@"name"]) {
        model.name = dic[@"name"];
    }
    if ([dic.allKeys containsObject:@"url"]) {
        model.url = dic[@"url"];
    }
    if ([dic.allKeys containsObject:@"type"]) {
        model.type = [dic[@"type"] intValue];
    }
    [model timeStr];
    
    return model;
}



-(NSString *)timeStr {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    long time = _fileTime/1000;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    return [formatter stringFromDate:date];
}

@end

/*
fileTime = "2020-09-23";
from = "\U7fa4\U804a:\U738b\U56fd\U7ea2\U3001\U6f58\U6d2a\U51b0\U3001\U5f20\U5415";
name = " \U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
type = 1;
url = "http://121.37.200.66:80/fs/4/2020/09/23/09/\U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
*/
