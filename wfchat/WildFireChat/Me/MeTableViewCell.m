//
//  MeTableViewCell.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/8/14.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "MeTableViewCell.h"


@interface MeTableViewCell ()



@end


@implementation MeTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)centerLable{
    if (!_centerLable) {
        _centerLable = [[UILabel alloc]init];
        _centerLable.textColor = UIColor.whiteColor;
        _centerLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview: _centerLable];
        _centerLable.frame = CGRectMake(0, 0, self.bounds.size.width - 50, self.bounds.size.height);
    }
    return _centerLable;
}



@end
