//
//  MapNaviagateRouteManager.h
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/17.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapNaviagateRouteManager : NSObject

/** 默认目的地名称，若未设置，默认为”目的地“ */
@property (class, nonatomic, copy) NSString *defaultDestinationName;

#pragma mark - 跳转到地图APP导航（“坐标” or “目的地名称” or “坐标+目的地名称”）

/**
 根据坐标导航
 
 @param controller 列表展示在此controller上
 @param coordinate 目的地坐标
 */
+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 根据目的地名称导航
 
 @param controller 列表展示在此controller上
 @param destination 目的地名称
 */
+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withDestination:(NSString *)destination;

/**
 根据”坐标+目的地名称“导航（尽量使用这个方法）
 
 @param controller 列表展示在此controller上
 @param coordinate 坐标
 @param destination 目的地名称
 */
+ (void)presentRouteNaviMenuOnController:(UIViewController *)controller withCoordate:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination;



@end

NS_ASSUME_NONNULL_END
