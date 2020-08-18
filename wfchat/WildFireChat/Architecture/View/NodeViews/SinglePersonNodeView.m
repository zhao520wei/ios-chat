//
//  SinglePersonNodeView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "SinglePersonNodeView.h"
#import "UIFont+YH.h"
#import "SDWebImage.h"


@interface SinglePersonNodeView ()
/**
 姓名
 */
@property (nonatomic, strong) UILabel *nameLabel;
/**
 工号
 */
@property (nonatomic, strong) UILabel *IDLabel;
/**
 部门
 */
@property (nonatomic, strong) UILabel *departmentLabel;
/**
 选择按钮
 */
@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UIImageView * portraitImgView;


@property (nonatomic, assign) BOOL isAbleSelected;// 是否能选中状态

@end

@implementation SinglePersonNodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame withIsAbleSelected:(BOOL)isCanSelected{
    if (self = [super initWithFrame:frame]) {
        self.isAbleSelected = isCanSelected;
        [self setupSubviewsWithIsAbleSelected:isCanSelected];
    }
    return self;
}

#pragma mark ======== Custom Delegate ========

#pragma mark NodeViewProtocol
- (void)updateNodeViewWithNodeModel:(id<NodeModelProtocol>)node{
    //将node转为该view对应的指定node，然后执行操作
    SinglePersonNode *personNode = (SinglePersonNode *)node;
    if (self.isAbleSelected) {
        if (personNode.selected == YES) {
            self.selectBtn.selected = YES;
        }else{
            self.selectBtn.selected = NO;
        }
    }
    _nameLabel.text = personNode.displayName;
//    _IDLabel.text = [NSString stringWithFormat:@"%@", personNode.mobile];
//    _departmentLabel.text = personNode.address;
    
//    _nameLabel.backgroundColor = UIColor.redColor;
//    _IDLabel.backgroundColor = UIColor.purpleColor;
//    _departmentLabel.backgroundColor = UIColor.orangeColor;
    
    [_portraitImgView sd_setImageWithURL:[NSURL URLWithString:personNode.portrait] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat leftOffset = 15.0;
    if (self.isAbleSelected) {
        _selectBtn.frame = CGRectMake(15, self.frame.size.height/2-6, 18, 18);
        leftOffset += 50.0 ;
    }
    _portraitImgView.frame = CGRectMake(15+leftOffset, 10, 30, 30);
    
    _nameLabel.frame = CGRectMake(15+leftOffset + 40, 0, self.frame.size.width - 100, self.frame.size.height);
    _IDLabel.frame = CGRectMake(15+leftOffset+80+12 + 40, self.frame.size.height/2-7, 150, 14);
    _departmentLabel.frame = CGRectMake(15+leftOffset+80+12+150+12 + 40, 0, self.frame.size.width-(15+leftOffset+150+12+80+12+12), self.frame.size.height);
}

#pragma mark ======== Private Methods ========

- (void)setupSubviewsWithIsAbleSelected:(BOOL)isCanSelected{
    if (isCanSelected) {
        [self addSubview:self.selectBtn];
    }
    [self addSubview:self.nameLabel];
    [self addSubview:self.IDLabel];
    [self addSubview:self.departmentLabel];
    [self addSubview:self.portraitImgView];
}

- (void)btnSelect:(UIButton *)btn{
    btn.selected = !btn.selected;
}

#pragma mark ======== Setters && Getters ========

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _nameLabel.textColor = kMainColor;
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    }
    return _nameLabel;
}

-(UIImageView *)portraitImgView{
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc]init];
        _portraitImgView.layer.cornerRadius = 15;
        _portraitImgView.layer.masksToBounds = YES;
    }
    return _portraitImgView;
}

- (UILabel *)IDLabel{
    if (!_IDLabel) {
        _IDLabel = [[UILabel alloc]init];
        _IDLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _IDLabel.textColor = [UIColor blackColor];
    }
    return _IDLabel;
}

- (UILabel *)departmentLabel{
    if (!_departmentLabel) {
        _departmentLabel = [[UILabel alloc]init];
        _departmentLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _departmentLabel.textColor = [UIColor blackColor];
        _departmentLabel.numberOfLines = 0;
        _departmentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _departmentLabel;
}

- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"single_unselected"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"single_selected"] forState:UIControlStateSelected];
    }
    return _selectBtn;
}



@end
