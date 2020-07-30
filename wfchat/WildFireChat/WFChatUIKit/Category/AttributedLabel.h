//
//  UILabel+LinkUrl.h
//  WildFireChat
//
//  Created by heavyrain.lee on 2018/5/15.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttributedLabelDelegate <NSObject>
@optional
- (void)didSelectUrl:(NSString *)urlString;
- (void)didSelectPhoneNumber:(NSString *)phoneNumberString;
@end

@interface AttributedLabel : UILabel
@property(nonatomic, weak)id<AttributedLabelDelegate> attributedLabelDelegate;
- (void)setText:(NSString *)text;
@end


@interface UILabel (String)
/**
 设置文本,并指定行间距

 @param text 文本内容
 @param lineSpacing 行间距
 */
-(void)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing;
@end
