//
//  AppDelegate.h
//  TestNotification
//
//  Created by wangxiaobo on 16/1/11.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


@interface Friend : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSMutableArray *frdArray;
@end

@interface User : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSMutableArray *frdArray;
@property (nonatomic, strong) Friend *frd;
@end





