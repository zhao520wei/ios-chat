//
//  WFCFileModel.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFileModel.h"

@implementation WFCFileModel

- (instancetype ) initWithDic:(NSDictionary *) dic {
    WFCFileModel * model = [[WFCFileModel alloc] init];
    if ([dic.allKeys containsObject:@"timestamp"]) {
        model.timestampStr = dic[@"timestamp"];
    }
    [model.files removeAllObjects];
    if ([dic.allKeys containsObject:@"files"]) {
        NSArray * files = dic[@"files"];
        for (NSDictionary *dic in files) {
            SingleFileModel * single = [[SingleFileModel alloc] initWithDic:dic];
            [model.files addObject:single];
        }
    }
    
    return model;
}

-(NSMutableArray<SingleFileModel *> *)files {
    if (!_files) {
        _files = [NSMutableArray array];
    }
    return _files;
}
@end

/*
{
    files =                 (
                            {
            fileTime = "2020-09-23";
            from = "\U7fa4\U804a:\U738b\U56fd\U7ea2\U3001\U6f58\U6d2a\U51b0\U3001\U5f20\U5415";
            name = " \U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
            type = 1;
            url = "http://121.37.200.66:80/fs/4/2020/09/23/09/\U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
        },
                            {
            fileTime = "2020-09-23";
            from = "\U7fa4\U804a:\U738b\U56fd\U7ea2\U3001\U6f58\U6d2a\U51b0\U3001\U5f20\U5415";
            name = " \U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
            type = 1;
            url = "http://121.37.200.66:80/fs/4/2020/09/23/09/\U6700\U8fd13\U4e2a\U95ee\U9898---\U66f4\U65b0.doc";
        }
    );
    timestamp = "2020-09-23";
}
*/
