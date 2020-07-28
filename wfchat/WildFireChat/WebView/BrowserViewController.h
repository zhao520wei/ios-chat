//
//  BrowserViewController.h
//  WKWebViewDemo
//
//  Created by 赵伟 on 2020/7/15.
//  Copyright © 2020 赵伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrowserViewController : UIViewController


/**
 要访问的URL地址
 */
@property (nonatomic, strong) NSURL *URL;

/**
 初始化方法
 
 @param URL 要访问的URL地址
 
 @return instancetype
 */
- (instancetype)initWithURL:(NSURL *)URL;

/**
 创建实例对象
 
 @param URL 要访问的URL地址
 
 @return instancetype
 */
+ (instancetype)createInstanceWithURL:(NSURL *)URL;


@end

NS_ASSUME_NONNULL_END
