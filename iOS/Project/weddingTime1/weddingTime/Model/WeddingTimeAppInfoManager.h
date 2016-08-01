//
//  WeddingTimeAppInfoManager.h
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#define titleLableColor       [UIColor colorWithRed:67.0f/255.0f green:73.0f/255.0f blue:82.0f/255.0f alpha:1]//主标题颜色

#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define defaultFont12 [WeddingTimeAppInfoManager fontWithSize:12];
#define defaultFont24 [WeddingTimeAppInfoManager fontWithSize:24];
#define defaultFont14 [WeddingTimeAppInfoManager fontWithSize:14];
#define defaultFont16 [WeddingTimeAppInfoManager fontWithSize:16];
#define defaultFont18 [WeddingTimeAppInfoManager fontWithSize:18];

#define defaultLineColor rgba(221, 221, 221, 1)

#define WeddingTimeBaseColor [WeddingTimeAppInfoManager instance].baseColor 

@interface WeddingTimeAppInfoManager : NSObject

@property (nonatomic,strong) UIColor *baseColor;
@property (nonatomic, strong) NSString *curid_order_detail;
@property (nonatomic, strong) NSString *curid_demand_detail;
@property (nonatomic, strong) NSString *curid_conversation;
@property (nonatomic, strong) NSString *curid_work;
@property (nonatomic, strong) NSString *curid_hotel_id;
@property (nonatomic, strong) NSString *curid_supplier;
@property (nonatomic, strong) NSString *curtag_inspiration;

@property (nonatomic, strong) NSMutableDictionary *supplierOnlineStatus;
+ (WeddingTimeAppInfoManager *)instance;

+ (NSString *)shortVersion;

+ (double)currentVresionDouble;

+ (double)versionDoubleWithVersion:(NSString *)versionString;

+ (UIFont*)fontWithSize:(CGFloat)size;

+ (NSArray *)defaultInspirationColors;

+ (UIImage *)avatarPlcehold;

+ (UIImage *)avatarPlceholdSelf;

+ (UIImage *)avatarPlceholdPartner;

+ (void)setAvatar:(id)object userId:(NSString*)userId;

+(void)checkUserNotificationSettings;
@end
