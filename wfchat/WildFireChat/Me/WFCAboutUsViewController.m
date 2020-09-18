//
//  WFCAboutUsViewController.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/18.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCAboutUsViewController.h"
#import "WFCUConfigManager.h"

@interface WFCAboutUsViewController ()

@end

@implementation WFCAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关于我们";
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  
    [self setNeedsStatusBarAppearanceUpdate];
    //解决在iOS 13上 导航栏和状态栏 重叠
    [self.navigationController.view setNeedsLayout];
}


- (void)setupSubviews {
    
    CGFloat centerX = self.view.center.x;
    
    UIImageView * iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    iconImageView.center = CGPointMake(centerX, 150);
    iconImageView.layer.cornerRadius = 10.0f;
    iconImageView.layer.masksToBounds = YES;
    iconImageView.image = [UIImage imageNamed:@"app_icon"];
    [self.view addSubview:iconImageView];
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, kScreenWidth, 30)];
    nameLabel.text = @"倚天协同办公";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [WFCUConfigManager globalManager].textColor;
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:nameLabel];
    
    UILabel * versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, kScreenWidth, 30)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"当前版本: %@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    versionLabel.textColor = [UIColor grayColor];
    versionLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:versionLabel];
    
    
    UILabel * productLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 90, kScreenWidth, 30 )];
    productLabel1.textAlignment = NSTextAlignmentCenter;
    productLabel1.text = @"大连倚天软件有限公司";
    productLabel1.numberOfLines = 1;
    productLabel1.textColor = [UIColor grayColor];
    productLabel1.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:productLabel1];
    UILabel * productLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 60, kScreenWidth, 30 )];
    productLabel2.textAlignment = NSTextAlignmentCenter;
    productLabel2.text = @"Copyright ® 2020 大连倚天 All Right Reserve";
    productLabel2.numberOfLines = 1;
    productLabel2.textColor = [UIColor grayColor];
    productLabel2.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:productLabel2];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
