//
//  WeddingTimeAppInfoManager.h
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#define titleLableColor [UIColor colorWithRed:67.0f/255.0f green:73.0f/255.0f blue:82.0f/255.0f alpha:1]//主标题颜色
#define LightGragyColor [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1]
#define rgba(r,g,b,a)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define DefaultFont10 [WeddingTimeAppInfoManager fontWithSize:10]
#define DefaultFont12 [WeddingTimeAppInfoManager fontWithSize:12]
#define DefaultFont14 [WeddingTimeAppInfoManager fontWithSize:14]
#define DefaultFont16 [WeddingTimeAppInfoManager fontWithSize:16]
#define DefaultFont18 [WeddingTimeAppInfoManager fontWithSize:18]
#define DefaultFont20 [WeddingTimeAppInfoManager fontWithSize:20]
#define DefaultFont24 [WeddingTimeAppInfoManager fontWithSize:24]
#define DefaultFont30 [WeddingTimeAppInfoManager fontWithSize:30]
#define DefaultFont36 [WeddingTimeAppInfoManager fontWithSize:36]

#define DefaultBlodFont16 [WeddingTimeAppInfoManager blodFontWithSize:16]

#define defaultLineColor rgba(221, 221, 221, 1)

#define WeddingTimeBaseColor [WeddingTimeAppInfoManager instance].baseColor 

@interface WeddingTimeAppInfoManager : NSObject
@property (nonatomic,strong) UIColor *baseColor;
@property (nonatomic, strong) NSString *curid_conversation;
@property (nonatomic, strong) NSMutableDictionary *supplierOnlineStatus;
+ (WeddingTimeAppInfoManager *)instance;

+ (NSString *)shortVersion;

+ (double)currentVresionDouble;

+ (double)versionDoubleWithVersion:(NSString *)versionString;

+ (UIFont*)fontWithSize:(CGFloat)size;

+ (UIFont *)blodFontWithSize:(CGFloat)size;

+ (NSArray *)defaultInspirationColors;

+ (UIImage *)avatarPlcehold;

+ (UIImage *)avatarPlceholdSelf;

+ (UIImage *)avatarPlceholdPartner;

+ (void)setAvatar:(id)object userId:(NSString*)userId;

+ (BOOL)openedNotification;

+ (void)checkUserNotificationSettings;

+ (void)checkVersion ;

@end
