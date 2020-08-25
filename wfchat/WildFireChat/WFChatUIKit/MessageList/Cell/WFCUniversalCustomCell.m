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

@interface WFCUniversalCustomCell ()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *contentLabel;

@property (nonatomic, strong)UILabel * bottomLabel;

@end


@implementation WFCUniversalCustomCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCUnivesalCustomMessageContent *universalContent = (WFCCUnivesalCustomMessageContent *)msgModel.message.content;
    
    CGFloat buttonHeight = universalContent.buttons.count > 0 ? 30.0: 0.0;
    
    CGFloat heigth = 30 + buttonHeight + universalContent.bodys.count * 25;
    
    CGSize size = CGSizeMake(200, heigth);
    
    if (size.height > width || size.width > width) {
        float scale =  1;//MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCUnivesalCustomMessageContent *universalContent = (WFCCUnivesalCustomMessageContent *)model.message.content;
    self.titleLabel.text = [NSString stringWithFormat:@"   %@",universalContent.title];
    NSMutableString * contentStr = [NSMutableString string];
    for (BodyItem *item in universalContent.bodys) {
        NSString * newStr = [NSString stringWithFormat:@"%@: %@\n",item.name, item.value];
        [contentStr appendString:newStr];
    }
    self.contentLabel.text = contentStr;
    [self.contentLabel setText:contentStr lineSpacing:5.0];
    
     NSMutableString * buttonStr = [NSMutableString string];
    for (ButtonItem * item in universalContent.buttons) {
        NSString * newStr = [NSString stringWithFormat:@"%@  ",item.name];
        [buttonStr appendString:newStr];
    }
    self.bottomLabel.text = buttonStr;
    [self layoutSubviews];
}



- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bubbleView.frame.size.width, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        [self.bubbleView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30 + 5, self.bubbleView.frame.size.width, self.bubbleView.frame.size.height - 60)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.numberOfLines = 0;
        [self.bubbleView addSubview:_contentLabel];
    }
    return _contentLabel;
}

-(UILabel *)bottomLabel{
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bubbleView.frame.size.height - 25, self.bubbleView.frame.size.width, 25)];
        _bottomLabel.font = [UIFont systemFontOfSize:15];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textColor  = kMainColor;
        [self.bubbleView addSubview:_bottomLabel];
    }
    return _bottomLabel;;
}


@end
