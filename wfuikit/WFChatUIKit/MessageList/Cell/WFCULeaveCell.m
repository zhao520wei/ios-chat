//
//  WFCULeaveCell.m
//  WFChatUIKit
//
//  Created by 赵伟 on 2020/7/14.
//  Copyright © 2020 Tom Lee. All rights reserved.
//

#import "WFCULeaveCell.h"
#import "WFCCLeaveMessageContent.h"

@interface WFCULeaveCell ()

@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation WFCULeaveCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCLeaveMessageContent *imgContent = (WFCCLeaveMessageContent *)msgModel.message.content;
    
    CGSize size = CGSizeMake(100, 100);
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCLeaveMessageContent *leaveContent = (WFCCLeaveMessageContent *)model.message.content;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ -- %@",leaveContent.title,leaveContent.reason];
}



- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bubbleView.frame.size.width, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:0.5f];
        _titleLabel.numberOfLines = 0;
        [self.bubbleView addSubview:_titleLabel];
    }
    return _titleLabel;
}


@end
