//
//  WFCULeaveCell.m
//  WFChatUIKit
//
//  Created by 赵伟 on 2020/7/14.
//  Copyright © 2020 Tom Lee. All rights reserved.
//

#import "WFCULeaveCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "AttributedLabel.h"

@interface WFCULeaveCell ()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *contentLabel;

@property (nonatomic, strong)UILabel * bottomLabel;

@end

@implementation WFCULeaveCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCLeaveMessageContent *imgContent = (WFCCLeaveMessageContent *)msgModel.message.content;
    
    CGSize size = CGSizeMake(200, 130);
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCLeaveMessageContent *leaveContent = (WFCCLeaveMessageContent *)model.message.content;
    self.titleLabel.text = [NSString stringWithFormat:@"   %@",leaveContent.title];
    
    NSString * contentStr = [NSString stringWithFormat:@"   请假事由: %@\n   开始时间： %lld\n   结束时间: %lld",leaveContent.reason,leaveContent.startTime,leaveContent.endTime];
    [self.contentLabel setText:contentStr lineSpacing:5.0];

    self.bottomLabel.text = @"   查看详情";
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
