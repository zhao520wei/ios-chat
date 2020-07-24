//
//  UIView+gradient.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/7/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (gradient)

- (void) wfcu_gradientBackgroundColorWithStartColor:(UIColor *)startColor withEndColor:(UIColor *)endColor;

@end

NS_ASSUME_NONNULL_END
