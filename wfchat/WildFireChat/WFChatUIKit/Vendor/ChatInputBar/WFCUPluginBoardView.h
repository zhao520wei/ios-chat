//
//  PluginBoardView.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WFCUPluginBoardViewDelegate <NSObject>
- (void)onItemClicked:(NSUInteger)itemTag;
@end
// 聊天界面的 输入功能模块
@interface WFCUPluginBoardView : UIView
- (instancetype)initWithDelegate:(id<WFCUPluginBoardViewDelegate>)delegate withVoip:(BOOL)withVoip;
@end
