//
//  RightArrowTableViewCell.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/8/14.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "RightArrowTableViewCell.h"
#import "SDWebImage.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "WFCUConfigManager.h"

@implementation RightArrowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _portraitView.frame = CGRectMake(16, (self.frame.size.height - 40) / 2.0, 40, 40);
    _nameLabel.frame = CGRectMake(16 + 40 + 11, (self.frame.size.height - 17) / 2.0, [UIScreen mainScreen].bounds.size.width - (16 + 40 + 11), 17);
    _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.rightArrow.frame = CGRectMake(kScreenWidth - 15 - 20, (self.frame.size.height - 20) / 2.0, 20, 20);
}


- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [UIImageView new];
        _portraitView.layer.masksToBounds = YES;
        _portraitView.layer.cornerRadius = 3.f;
        [self.contentView addSubview:_portraitView];
    }
    return _portraitView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [WFCUConfigManager globalManager].textColor;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UIImageView *)rightArrow{
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:_rightArrow];
    }
    return _rightArrow;
}

@end
