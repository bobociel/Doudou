//
//  MerchantPoint.h
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MerchantPoint : NSObject <MKAnnotation>

// 实现MKAnnotation协议必须要定义这个属性
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
// 标题
@property (nonatomic, copy) NSString *title;

// 初始化方法
-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)t;

@end
