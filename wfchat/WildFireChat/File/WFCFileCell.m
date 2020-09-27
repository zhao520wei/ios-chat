//
//  WFCFileCell.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/25.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFileCell.h"
#import "UIColor+YH.h"
#import "WFCUConfigManager.h"

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

- (void)layoutSubviews{
    [super layoutSubviews];
    
//    self.contentView.backgroundColor = [UIColor redColor];
    
}

-(void)setModel:(SingleFileModel *)model {
    _model = model;
    
    self.backView.layer.borderWidth = 1;
    self.backView.layer.cornerRadius = 5;
    if (model.type == 1) {
        self.backView.layer.borderColor = [[UIColor colorWithHexString:@"0x3C97FF"] CGColor];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"0x3C97FF" alpha:0.2] ;
        self.iconImageView.image = [UIImage imageNamed:@"file_word"];
    } else if (model.type == 2) {
        self.backView.layer.borderColor = [[UIColor colorWithHexString:@"0xFF9693"] CGColor];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"0xFF9693" alpha:0.2] ;
        self.iconImageView.image = [UIImage imageNamed:@"file_excel"];
    } else if (model.type == 3) {
        self.backView.layer.borderColor = [[UIColor colorWithHexString:@"0x50D196"] CGColor];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"0x50D196" alpha:0.2] ;
        self.iconImageView.image = [UIImage imageNamed:@"file_ppt"];
    } else if (model.type == 4) {
        self.backView.layer.borderColor = [[UIColor colorWithHexString:@"0x50D196"] CGColor];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"0x50D196" alpha:0.2] ;
        self.iconImageView.image = [UIImage imageNamed:@"file_pdf"];
    }
    self.title.text = model.name;
    self.subTitle.text = model.from;
    
    self.imageView.frame = CGRectMake(kScreenWidth - 20, 19, 3, 12);
}

#pragma mark get/set

-(UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, kScreenWidth-10, 50)];
        [self.contentView addSubview:_backView];
    }
    return _backView;
}
-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 4, 36, 42)];
        [self.backView addSubview:_iconImageView];
    }
    return _iconImageView;
}
-(UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, kScreenWidth - 80, 15)];
        _title.font = [UIFont systemFontOfSize:15];
        _title.textColor = [WFCUConfigManager globalManager].textColor;
        [self.backView addSubview:_title];
    }
    return _title;
}
-(UILabel *)subTitle{
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, kScreenWidth - 80, 12)];
        _subTitle.font = [UIFont systemFontOfSize:12];
        _subTitle.textColor = [UIColor grayColor];
        [self.backView addSubview:_subTitle];
    }
    return _subTitle;
}
-(UIImageView *)moreImgView{
    if (!_moreImgView) {
        _moreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10, 19, 3, 12)];
        _moreImgView.image = [UIImage imageNamed:@"file_more"];
        [self.backView addSubview:_moreImgView];
    }
    return _moreImgView;
}




@end
