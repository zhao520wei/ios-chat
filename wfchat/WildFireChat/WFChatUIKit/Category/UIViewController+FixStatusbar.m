//
//  UIViewController+FixStatusbar.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/8/31.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "UIViewController+FixStatusbar.h"
#import <objc/runtime.h>



@implementation UIViewController (FixStatusbar)


//+ (void)initialize
//{
//    if (@available(iOS 13.0, *)) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            method_exchangeImplementations(class_getInstanceMethod(self.class, @selector(viewWillAppear:)),
//                                           class_getInstanceMethod(self.class, @selector(MDFix_navigationBarFrame_viewDidAppear:)));
//
//        });
//    }
//}
//
//- (void)MDFix_navigationBarFrame_viewDidAppear:(BOOL)animated {
//    [self MDFix_navigationBarFrame_viewDidAppear:animated];
//    [self.navigationController.view setNeedsLayout];
//}



@end
