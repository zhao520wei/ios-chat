//
//  WFCFileCell.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFileCell.h"

@interface WFCFileCell ()

@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UILabel * title;
@property (nonatomic, strong) UILabel * subTitle;
@property (nonatomic, strong) UIImageView * moreImgView;

@end

@implementation WFCFileCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark get/set

-(UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, kScreenWidth-10, self.contentView.frame.size.height)];
    }
    return _backView;
}
-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
    }
    return _iconImageView;
}
-(UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]init];
    }
    return _title;
}
-(UILabel *)subTitle{
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] init];
    }
    return _subTitle;
}
-(UIImageView *)moreImgView{
    if (!_moreImgView) {
        _moreImgView = [[UIImageView alloc] init];
    }
    return _moreImgView;
}




@end
