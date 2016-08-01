//
//  UserDefaultManager.h
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TOKEN [UserInfoManager instance].tokenId_self
#define kBadgeMore @"99+"
static  NSString *const infoUpdateObserver=@"infoUpdateObserver";
static  NSString *const InviteState_single = @"InviteState_single";
static  NSString *const InviteState_invite = @"InviteState_invite";
static  NSString *const InviteState_double = @"InviteState_double";

typedef NS_ENUM(NSInteger, UserGender) {
    UserGenderUnknow = 0,
    UserGenderMale    =1,
    UserGenderFemale  =2
};
typedef NS_ENUM(NSInteger, UserBlingState) {
    hasBling = 0,
    unBling    =1,
    waitBling  =2
};
@protocol UserInfoManagerObserver <NSObject>

@optional
-(void)userInfoUpdate;
@end

@interface UserInfoManager : NSObject
{
     NSMutableDictionary *observerMapping;
}
@property (nonatomic,strong) NSString   *tokenId_self;
@property (nonatomic,strong) NSString   *tokenId_partner;
@property (nonatomic,strong) NSString   *avatar_self;
@property (nonatomic,strong) NSString   *avatar_partner;
@property (nonatomic,strong) NSString   *username_self;
@property (nonatomic,strong) NSString   *username_partner;
@property (nonatomic,strong) NSString   *phone_partner;
@property (nonatomic,strong) NSString   *phone_self;
@property (nonatomic,strong) NSString   *userId_self;
@property (nonatomic,strong) NSString   *userId_partner;

@property (nonatomic) UserGender        userGender;
@property (nonatomic) UserBlingState    blingState;
@property (nonatomic,strong) NSString   *domainName; //个性域名
@property (nonatomic,strong) NSString   *wedding_address;
@property (nonatomic,strong) NSString   *wedding_map_point;
@property (nonatomic,assign) int64_t    weddingTime; //婚期
@property (nonatomic,copy)   NSString   *guestWords; //邀请宾客词

@property (nonatomic,strong) NSMutableDictionary *inviteDic;
@property (nonatomic,strong) NSString *num_like;
@property (nonatomic,strong) NSString *num_order;
@property (nonatomic,strong) NSString *num_demand;
@property (nonatomic,assign) double    num_bless;
@property (nonatomic,assign) double    num_bless_readed;
@property int curCityId;
@property (nonatomic,strong) NSString *city_name;
@property (nonatomic, assign) BOOL notFirstGetOrderList;
@property (nonatomic, strong) NSString *backMusicName;
+ (UserInfoManager *)instance;

/**
 *  每次修改完数据后都要先调用实例instance在调用这个存到本地,请确保每次修改后都调用保存
 * @see &example
 *  [UserDefaultManager instance].exampleInt  = 100;
 [[UserDefaultManager instance] saveToUserDefaults];
 */
- (void)saveToUserDefaults;

- (void)saveBlessCToUserDefaults ;

/**
 *应用启动后 在APPDelegate里面启动调用一次即可,请确保只调用一次
 */
- (void)loadFromUserDefaults;

/**
 *  GET Wedding Time
 */

- (NSString *)weddingTimeString;
- (NSString *)weddingTimeStringYMD;

/**
 *根据事件名添加观察者
  */
-(void)addInfoUpdateObserver:(id<UserInfoManagerObserver>)observer forName:(NSString*)name;
-(void)removeInfoUpdateObserver:(id<UserInfoManagerObserver>)observer forName:(NSString*)name;

//forExit确保退出登录时一定要调用
- (void)removeAllEventObserver;

-(void)exit;

-(void)setMyAvatar:(id)myHeadImageView;
-(void)setPartnerAvatar:(id)partnerHeadImageView;

-(void)updateUserInfoFromServer;

//返回祝福未读条数
- (NSString *)getUnreadBlessCount;

@end
