//
//  MapNaviagateRouteManager.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/17.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "MapNaviagateRouteManager.h"

#define SOURCE_APPLICATION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

/**
 路径导航类型
 
 - FVRouteNaviTypeApple: 苹果地图导航
 - FVRouteNaviTypeGaode: 高德地图导航
 - FVRouteNaviTypeBaidu: 百度地图导航
 */
typedef NS_ENUM(NSUInteger, FVRouteNaviType) {
    FVRouteNaviTypeApple,
    FVRouteNaviTypeGaode,
    FVRouteNaviTypeBaidu,
};

static NSString *_defaultDestinationName = @"目的地";

@implementation MapNaviagateRouteManager

#pragma mark - 设置默认展示的目的地名称

+ (NSString *)defaultDestinationName {
    return _defaultDestinationName;
}

+ (void)setDefaultDestinationName:(NSString *)defaultDestinationName {
    _defaultDestinationName = defaultDestinationName;
}

#pragma mark - 跳转到地图APP导航（“坐标” or “目的地名称” or “坐标+目的地名称”）

/**
 根据坐标导航
 
 @param controller 列表展示在此controller上
 @param coordinate 目的地坐标
 */
+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self p_presentRouteNaviMenuOnController:controller withLocation:location destination:nil];
}

+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withDestination:(NSString *)destination {
    [self p_presentRouteNaviMenuOnController:controller withLocation:nil destination:destination];
}

+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withCoordate:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self p_presentRouteNaviMenuOnController:controller withLocation:location destination:destination];
}

#pragma mark - private method

+ (void)p_presentRouteNaviMenuOnController:(UIViewController *)controller withLocation:(nullable CLLocation *)location destination:(nullable NSString *)destination {
    
    if (!location && !destination) {
        NSAssert(nil, @"位置和地址不能同时为空");
        return;
    }
    
    // 能否打开苹果地图
    BOOL canOpenAppleMap = NO;
    // 能否打开高德地图
    BOOL canOpenGaodeMap = NO;
    // 能否打开百度地图
    BOOL canOpenBaiduMap = NO;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com"]]) {
        canOpenAppleMap = YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        canOpenGaodeMap = YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        canOpenBaiduMap = YES;
    }
    
    // 三种地图都木有，弹窗提示，return
    if (!canOpenAppleMap && !canOpenGaodeMap && !canOpenBaiduMap) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"你手机未安装支持的地图APP" message:@"请先下载苹果地图、高德地图或百度地图" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:confirmAction];
        [controller presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    
    //========== 以下是正常情况下的逻辑 ==========//
    
    // 地图列表
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"导航" message:@"请选择地图" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //========== 使用苹果地图导航 ==========//
    if (canOpenAppleMap) {
        [alertVC addAction:[self p_actionWithNaviType:FVRouteNaviTypeApple title:@"使用苹果自带地图导航" location:location destination:destination]];
    }
    
    //========== 使用高德地图导航 ==========//
    if (canOpenGaodeMap) {
        [alertVC addAction:[self p_actionWithNaviType:FVRouteNaviTypeGaode title:@"使用高德地图导航" location:location destination:destination]];
    }
    
    //========== 使用百度地图导航 ==========//
    if (canOpenBaiduMap) {
        [alertVC addAction:[self p_actionWithNaviType:FVRouteNaviTypeBaidu title:@"使用百度地图导航" location:location destination:destination]];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancelAction];
    
    [controller presentViewController:alertVC animated:YES completion:nil];
}

+ (UIAlertAction *)p_actionWithNaviType:(FVRouteNaviType)naviType title:(NSString *)title location:(CLLocation *)location destination:(NSString *)destination {
    // 目的地如果为空，展示名称默认为”目的地“
    NSString *destinationName = destination ?: self.defaultDestinationName;
    
    __block NSString *urlString = nil;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        switch (naviType) {
            case FVRouteNaviTypeApple: // 苹果地图
            {
                if (location) {
                    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
                    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
                    toLocation.name = destinationName;
                    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
                } else {
                    // 没坐标，仅有目的地名称
                    urlString = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@",destinationName];
                }
            }
                break;
                
            case FVRouteNaviTypeGaode: // 高德地图
            {
                if (location) {
                    // 有坐标时以坐标为准
                    urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&t=0&dname=%@",SOURCE_APPLICATION,location.coordinate.latitude, location.coordinate.longitude, destinationName];
                } else {
                    // 没有坐标时，以终点名称为准
                    urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sname=%@&dname=%@&dev=0&t=0&sid=BGVIS1&did=BGVIS2",SOURCE_APPLICATION,@"我的位置",destinationName];
                }
            }
                break;
                
            case FVRouteNaviTypeBaidu: // 百度地图
            {
                if (location) {
                    // 注：高德用的gcj02坐标系
                    urlString = [NSString stringWithFormat:@"baidumap://map/direction?location=%f,%f&coord_type=gcj02&type=TIME&src=%@&origin={{我的位置}}&destination=%@", location.coordinate.latitude, location.coordinate.longitude, SOURCE_APPLICATION, destinationName];
                } else {
                    urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=%@", destinationName];
                }
            }
                break;
        }
        
        // 打开地图APP
        if (urlString) {
            NSURL *targetURL = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:^(BOOL success) {
                    NSLog(@"scheme调用结束");
                }];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication] openURL:targetURL];
            }
        }
    }];
    
    return action;
}

@end
