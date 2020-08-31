//
//  WFCUniversalCustomCell.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/8/24.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCUniversalCustomCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "AttributedLabel.h"
#import "WFCUUtilities.h"
#import "UIView+Screenshot.h"
#import "BrowserViewController.h"
#import "MultiParamButton.h"

@interface WFCUniversalCustomCell ()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *contentLabel;

//@property (nonatomic, strong)UILabel * bottomLabel;

@property (nonatomic, strong) UIView * bottomView;

@property(nonatomic, strong) UIView * firstLine;

@property(nonatomic, strong) UIView * secondLine;

@end


@implementation WFCUniversalCustomCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCUnivesalCustomMessageContent *universalContent = (WFCCUnivesalCustomMessageContent *)msgModel.message.content;
    
    CGFloat buttonHeight = universalContent.buttons.count > 0 ? 30.0: 0.0;
    
    // 这个文字的高度还是有问题，不能定死 需要计算而得到
    NSMutableString * contentStr = [NSMutableString string];
    for (BodyItem *item in universalContent.bodys) {
        NSString * newStr = [NSString stringWithFormat:@"%@: %@\n",item.name, item.value];
        [contentStr appendString:newStr];
    }
    
    CGSize bodyTextsize = [WFCUUtilities getTextDrawingSize:contentStr font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(width, 8000)];
    
    CGSize titleTextsize = [WFCUUtilities getTextDrawingSize:universalContent.title font:[UIFont systemFontOfSize:16] constrainedSize:CGSizeMake(width, 8000)];
    
    CGFloat heigth = 10 + titleTextsize.height + buttonHeight + bodyTextsize.height ;
    
    CGSize size = CGSizeMake(200, heigth);
    
    if (size.height > width || size.width > width) {
        float scale =  1;//MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    [self clearOldData];
    
    WFCCUnivesalCustomMessageContent *universalContent = (WFCCUnivesalCustomMessageContent *)model.message.content;
    self.titleLabel.text = [NSString stringWithFormat:@"%@",universalContent.title];
    NSMutableString * contentStr = [NSMutableString string];
   
    for (int i = 0; i < universalContent.bodys.count; i++) {
        BodyItem *item = universalContent.bodys[i];
        if (i == universalContent.bodys.count - 1) {
            NSString * newStr = [NSString stringWithFormat:@"%@: %@",item.name, item.value];
            [contentStr appendString:newStr];
        } else {
            NSString * newStr = [NSString stringWithFormat:@"%@: %@\n",item.name, item.value];
            [contentStr appendString:newStr];
        }
    }
    
    self.contentLabel.text = contentStr;
    [self.contentLabel setText:contentStr lineSpacing:10.0];
    
     NSMutableString * buttonStr = [NSMutableString string];
    for (ButtonItem * item in universalContent.buttons) {
        NSString * newStr = [NSString stringWithFormat:@"%@  ",item.name];
        [buttonStr appendString:newStr];
    }
//    if (model.message.direction == MessageDirection_Send) {
//        self.bottomLabel.textAlignment = NSTextAlignmentRight;
//    } else {
//        self.bottomLabel.textAlignment = NSTextAlignmentLeft;
//    }
//
//
//    self.bottomLabel.text = buttonStr;
    
    [self.contentLabel setUserInteractionEnabled:NO];
    
    CGFloat buttonX = 0.0;
    for (int i= 0; i < universalContent.buttons.count; i++) {
        ButtonItem * item = universalContent.buttons[i];
        MultiParamButton * button = [MultiParamButton buttonWithType:UIButtonTypeCustom];
        [button setTintColor:kMainColor];
        [button setTitle:item.name forState:UIControlStateNormal];
        [button setBackgroundColor:kMainColor];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        CGSize size = [WFCUUtilities getTextDrawingSize:item.name font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(100, 100)];
        int buttonWidth  = size.width;
        button.frame = CGRectMake(buttonX , 0, buttonWidth , 20);
        buttonX += size.width;
        buttonX += 10;
        button.status = item.type;
        button.url = item.value;
        button.layer.cornerRadius = 5;
        [button addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:button];
    }
    
    
    
    CGSize titleTextsize = [WFCUUtilities getTextDrawingSize:universalContent.title font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(200, 8000)];
   
    self.titleLabel.frame = CGRectMake(10, 0, self.bubbleView.frame.size.width-20, titleTextsize.height);
    self.firstLine.frame = CGRectMake(10, titleTextsize.height + 3, self.bubbleView.frame.size.width-30, 1);
    
   

    if (universalContent.buttons.count > 0) {
        self.secondLine.hidden = false;
         self.contentLabel.frame = CGRectMake(10, titleTextsize.height + 5, self.bubbleView.frame.size.width-30, self.bubbleView.frame.size.height - 35 - titleTextsize.height);
    } else {
        self.secondLine.hidden = true;
         self.contentLabel.frame = CGRectMake(10, titleTextsize.height + 5, self.bubbleView.frame.size.width-30, self.bubbleView.frame.size.height - titleTextsize.height);
    }
   
    [self layoutSubviews];
}

-(void) clearOldData{
    self.titleLabel.text = nil;
    self.contentLabel.text = nil;
    for (UIView * view in self.bottomView.subviews) {
        [view removeFromSuperview];
    }
}

-(void) buttonActions:(MultiParamButton *)btn {
    if (btn.url != nil && btn.url.length > 5) {
        BrowserViewController * browser = [[BrowserViewController alloc] init];
        browser.URL = [NSURL URLWithString:btn.url];
        [[self currentController].navigationController pushViewController:browser animated:YES];
    }
    
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bubbleView.frame.size.width-20, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        [self.bubbleView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30 + 5, self.bubbleView.frame.size.width-20, self.bubbleView.frame.size.height - 60)];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.numberOfLines = 0;
        [self.bubbleView addSubview:_contentLabel];
    }
    return _contentLabel;
}

//-(UILabel *)bottomLabel{
//    if (!_bottomLabel) {
//        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.bubbleView.frame.size.height - 25, self.bubbleView.frame.size.width- 20, 25)];
//        _bottomLabel.font = [UIFont systemFontOfSize:15];
//
//        _bottomLabel.backgroundColor = [UIColor clearColor];
//        _bottomLabel.numberOfLines = 1;
//        _bottomLabel.textColor  = kMainColor;
//        [self.bubbleView addSubview:_bottomLabel];
//    }
//    return _bottomLabel;;
//}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10, self.bubbleView.frame.size.height - 25, self.bubbleView.frame.size.width- 20, 25)];
        [self.bubbleView addSubview:_bottomView];
    }
    return  _bottomView;
}

-(UIView *)firstLine{
    if (!_firstLine) {
        _firstLine = [[UIView alloc] init];
        _firstLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.bubbleView addSubview:_firstLine];
    }
    return _firstLine;
}

-(UIView *)secondLine{
    if (!_secondLine) {
        _secondLine = [[UIView alloc] initWithFrame:CGRectMake(10, self.bubbleView.frame.size.height - 32, self.bubbleView.frame.size.width- 30, 1)];
        _secondLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.bubbleView addSubview:_secondLine];
    }
    return  _secondLine;
}

@end
