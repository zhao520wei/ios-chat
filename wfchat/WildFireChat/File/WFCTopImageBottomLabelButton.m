//
//  WFCTopImageBottomLabelButton.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/28.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCTopImageBottomLabelButton.h"

@interface WFCTopImageBottomLabelButton ()

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation WFCTopImageBottomLabelButton

- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        self.imageView.image = image;
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height * 0.6);
        self.titleLabel.frame = CGRectMake(0, frame.size.height * 0.7, frame.size.width, frame.size.height * 0.3);
    }
    return self;
}

#pragma mark - Get / Set

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment =  NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
