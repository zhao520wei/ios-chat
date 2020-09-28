//
//  WFCFileViewController.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WFCCFileType) {
    File_word,
    File_excel,
    File_ppt,
    File_pdf,
    File_all,
} ;

NS_ASSUME_NONNULL_BEGIN

@interface WFCFileViewController : UIViewController

@property (nonatomic, assign) WFCCFileType type;

-(instancetype)initWithFileType:(WFCCFileType)type;

@end

NS_ASSUME_NONNULL_END
