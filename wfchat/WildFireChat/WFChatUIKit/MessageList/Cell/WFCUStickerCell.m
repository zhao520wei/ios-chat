//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUStickerCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "MBProgressHUD.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

#import "SDFLAnimatedImage.h"
#import "FLAnimatedImageView+WebCache.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "WFCUMediaMessageDownloader.h"
#import "UIImageView+WebCache.h"
@interface WFCUStickerCell ()
@property (nonatomic, strong)FLAnimatedImageView *thumbnailView;
@end

@implementation WFCUStickerCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCStickerMessageContent *imgContent = (WFCCStickerMessageContent *)msgModel.message.content;
    CGSize size = imgContent.size;
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCStickerMessageContent *stickerMsg = (WFCCStickerMessageContent *)model.message.content;
   
    __weak typeof(self) weakSelf = self;
    if (!stickerMsg.localPath.length) {
//        model.mediaDownloading = YES;
        NSLog(@"开始下载 sticker ");
//        __block MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        BOOL downloading = [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
//             model.mediaDownloading = NO;
            NSLog(@" sticker  下载完成");
//            [hud hideAnimated:YES];
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
                stickerMsg.localPath = localPath;
                [weakSelf setModel:weakSelf.model];
            }
        } error:^(long long messageUid, int error_code) {
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
            }
//            hud.mode = MBProgressHUDModeText;
//            hud.label.text = [NSString stringWithFormat:@"下载Stiker失败 error_code: %d",error_code];
//            [hud hideAnimated:YES afterDelay:1];
            NSLog(@" sticker  下载失败");
        }];
        if (downloading) {
            model.mediaDownloading = YES;
        }
    }
  
    self.thumbnailView.frame = self.bubbleView.bounds;
    
     /*
    if (stickerMsg.localPath.length) {
        NSLog(@"已有 sticker  ");
//        if (@available(iOS 14, *)) {
            [self.thumbnailView sd_setImageWithURL:[NSURL fileURLWithPath:stickerMsg.localPath]];
            NSLog(@" -----  14");
//        } else {
//            NSLog(@" -----  13");
//            self.thumbnailView.image = [YLGIFImage imageWithContentsOfFile:stickerMsg.localPath];
//        }
        
    } else {
        self.thumbnailView.image = nil;
    }
      */
    
//    UIImage * image = [UIImage imageNamed:@"default_gif"];
//    NSData * gifData =  UIImagePNGRepresentation(image);
//    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
//    SDFLAnimatedImage *placeholder = [[SDFLAnimatedImage alloc] initWithAnimatedImage:animatedImage];
    if (stickerMsg.localPath.length) {
        [self.thumbnailView sd_setImageWithURL:[NSURL fileURLWithPath:stickerMsg.localPath] placeholderImage:nil];
    } else {
        [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:stickerMsg.remoteUrl] placeholderImage:nil];
    }
    


    self.bubbleView.image = nil;
}

- (FLAnimatedImageView *)thumbnailView {
    if (!_thumbnailView) {
//        if (@available(iOS 14, *)) {
//            _thumbnailView = [[UIImageView alloc] init];
//        } else {
//            _thumbnailView = [[YLImageView alloc] init];
//        }
        _thumbnailView = [[FLAnimatedImageView alloc] init];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview:_thumbnailView];
    }
    return _thumbnailView;
}
@end
