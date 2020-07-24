//
//  UIView+gradient.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/7/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "UIView+gradient.h"
#import "UIColor+YH.h"

@implementation UIView (gradient)

- (void) wfcu_gradientBackgroundColorWithStartColor:(UIColor *)startColor withEndColor:(UIColor *)endColor {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)startColor.CGColor,(id)endColor.CGColor];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.locations = @[@(0.0f), @(1.0f)];
    
    if ([self.class isKindOfClass:[UIButton class] ]) {
       UIButton * newSelf = (UIButton *)self;
        
    } else {
        
        [self.layer addSublayer:gradient];
    }
    
    
}

@end
