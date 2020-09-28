//
//  WFCTopImageBottomLabelButton.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/28.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFCTopImageBottomLabelButton : UIControl

- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image;

@property (nonatomic, strong) NSString * title;

@property (nonatomic, assign) int buttonTag;

@end

NS_ASSUME_NONNULL_END
