//
//  UserDefaultManager.m
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "UserInfoManager.h"
#import "LWAssistUtil.h"
#import "UIImageView+WebCache.h"

#import "GetService.h"
#import "PostDataService.h"
#import "BlingService.h"
#import "LWAssistUtil.h"
static  NSString *const key_DomainName         = @"key_DomainName";
static  NSString *const key_userId_self        = @"userId_self";
static  NSString *const key_userId_partner     = @"userId_partner";

static  NSString *const key_avatar_self        = @"avatar_self";
static  NSString *const key_avatar_partner     = @"key_avatar_partner";

static  NSString *const key_username_self      = @"username_self";
static  NSString *const key_username_partner      = @"key_username_partner";

static  NSString *const key_isFirstUseApp      = @"isFirstUseApp";
static  NSString *const key_wedding_address = @"key_wedding_address";
static  NSString *const key_wedding_map_point = @"key_wedding_map_point";

static  NSString *const key_tokenId_self       = @"tokenId_self";
static  NSString *const key_tokenId_partner    = @"tokenId_partner";

static  NSString *const key_userGender    = @"key_userGender";
static  NSString *const key_phone_partner    = @"key_phone_partner";
static  NSString *const key_phone_self    = @"key_phone_self";
static  NSString *const key_weddingTime    = @"key_weddingTime";
static  NSString *const key_guestwords    = @"key_guestwords";
static  NSString *const key_num_like      = @"key_num_like";
static  NSString *const key_num_order     = @"key_num_order";
static  NSString *const key_num_demand    = @"key_num_demand";
static  NSString *const key_num_bless_readed    = @"key_num_bless_readed";
static  NSString *const key_num_bless      = @"key_num_bless";
static  NSString *const key_curcity        = @"key_curcity";
static  NSString *const key_demaindNum     =@"key_demaindNum";
static  NSString *const key_notFirstGetOrderList = @"key_notFirstGetOrderList";
static  NSString *const key_city_name = @"key_city_name";
static  NSString *const key_inviteDic = @"key_inviteDic";
static  NSString *const key_back_music_name = @"key_back_music_name";
@implementation UserInfoManager

+ (UserInfoManager *)instance {
    static UserInfoManager *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[UserInfoManager alloc] init];
        [_instance loadFromUserDefaults];
    });
    return _instance;
}

-(instancetype)init
{
    if (self=[super init]) {
        observerMapping = [NSMutableDictionary dictionary];
        self.inviteDic = [NSMutableDictionary dictionary];
        return self;
    }
    return nil;
    
}

-(NSString*)tokenId_self
{
    NSString *s=[LWUtil getString:_tokenId_self andDefaultStr:@""];
    return s;
}

/**
 *  GET Wedding Time
 */

- (NSString *)weddingTimeString
{
	NSDate *weddingDate = [NSDate dateWithTimeIntervalSince1970:_weddingTime];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYY-MM-dd"];

	return [dateFormatter stringFromDate:weddingDate];
}

- (NSString *)weddingTimeStringYMD
{
	NSDate *weddingDate = [NSDate dateWithTimeIntervalSince1970:_weddingTime];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYY年MM月dd日"];

	return [dateFormatter stringFromDate:weddingDate];
}

- (void)loadFromUserDefaults
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    //数据本地化
    _backMusicName = [LWUtil getString:[userDefaults objectForKey:key_back_music_name] andDefaultStr:@""];
    _wedding_address=[LWUtil getString:[userDefaults objectForKey:key_wedding_address]andDefaultStr:@""];
    _wedding_map_point=[LWUtil getString:[userDefaults objectForKey:key_wedding_map_point]andDefaultStr:@""];
    
    _city_name =[LWUtil getString:[userDefaults objectForKey:key_city_name]andDefaultStr:@""];
    _tokenId_self=[LWUtil getString:[userDefaults objectForKey:key_tokenId_self]andDefaultStr:@""];
    _tokenId_partner=[LWUtil getString:[userDefaults objectForKey:key_tokenId_partner]andDefaultStr:@""];
    
    _username_self=[LWUtil getString:[userDefaults objectForKey:key_username_self]andDefaultStr:@""];
    _avatar_self=[LWUtil getString:[userDefaults objectForKey:key_avatar_self]andDefaultStr:@""];
    _userGender=[[userDefaults objectForKey:key_userGender] intValue];
    _phone_partner=[LWUtil getString:[userDefaults objectForKey:key_phone_partner]andDefaultStr:@""];
    _phone_self=[LWUtil getString:[userDefaults objectForKey:key_phone_self]andDefaultStr:@""];
    _username_partner=[LWUtil getString:[userDefaults objectForKey:key_username_partner]andDefaultStr:@""];
    _domainName=[LWUtil getString:[userDefaults objectForKey:key_DomainName]andDefaultStr:@""];
    
    _userId_self=[LWUtil getString:[userDefaults objectForKey:key_userId_self]andDefaultStr:@""];
    _userId_partner=[LWUtil getString:[userDefaults objectForKey:key_userId_partner]andDefaultStr:@""];
    _avatar_partner=[LWUtil getString:[userDefaults objectForKey:key_avatar_partner]andDefaultStr:@""];
    
    _weddingTime= [[userDefaults objectForKey:key_weddingTime] longLongValue];
	_guestWords = [LWUtil getString:[userDefaults objectForKey:key_guestwords] andDefaultStr:@""];

    _notFirstGetOrderList = [[userDefaults objectForKey:key_notFirstGetOrderList] boolValue];
    _num_like=[LWUtil getString:[userDefaults objectForKey:key_num_like]andDefaultStr:@""];
    _num_order=[LWUtil getString:[userDefaults objectForKey:key_num_order] andDefaultStr:@""];
    _num_demand=[LWUtil getString:[userDefaults objectForKey:key_num_demand] andDefaultStr:@""];
	_num_bless_readed = [userDefaults doubleForKey:key_num_bless_readed];
	_num_bless = [userDefaults doubleForKey:key_num_bless];

    _curCityId=[[userDefaults objectForKey:key_curcity]intValue];
    _inviteDic = [userDefaults objectForKey:key_inviteDic];
}

- (void)saveToUserDefaults {

    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    //数据本地化
    [userDefaults setObject:_backMusicName forKey:key_back_music_name];
    [userDefaults setObject:_inviteDic forKey:key_inviteDic];
    [userDefaults setObject:_wedding_address forKey:key_wedding_address];
    [userDefaults setObject:_wedding_map_point forKey:key_wedding_map_point];
    [userDefaults setObject:[NSNumber numberWithBool:_notFirstGetOrderList] forKey:key_notFirstGetOrderList];
    [userDefaults setObject:_city_name forKey:key_city_name];
    [userDefaults setObject:_tokenId_self forKey:key_tokenId_self];
    [userDefaults setObject:_tokenId_partner forKey:key_tokenId_partner];
    
    [userDefaults setObject:_username_self forKey:key_username_self];
    
    [userDefaults setObject:_avatar_self forKey:key_avatar_self];
    [userDefaults setObject:[NSNumber numberWithInt:_userGender] forKey:key_userGender];
    [userDefaults setObject:_phone_partner forKey:key_phone_partner];
    [userDefaults setObject:_phone_self forKey:key_phone_self];
    [userDefaults setValue:_username_partner forKey:key_username_partner];
    
    [userDefaults setObject:_domainName forKey:key_DomainName];
	[userDefaults setObject:_guestWords forKey:key_guestwords];

    [userDefaults setObject:_userId_self forKey:key_userId_self];
    [userDefaults setObject:_userId_partner forKey:key_userId_partner];
    [userDefaults setObject:_avatar_partner forKey:key_avatar_partner];
    [userDefaults setObject:_num_demand forKey:key_num_demand];
    [userDefaults setObject:_num_like forKey:key_num_like];
    [userDefaults setObject:_num_order forKey:key_num_order];
    
    [userDefaults setObject:@(_weddingTime) forKey:key_weddingTime];
    [userDefaults setObject:@(_curCityId) forKey:key_curcity];
    [userDefaults synchronize];
    
    
    NSMutableArray *observerChain = [observerMapping objectForKey:infoUpdateObserver];
    if (observerChain) {
        for (int i = 0; i < [observerChain count]; i++) {
            NSValue *value= [observerChain objectAtIndex:i];
            __weak id<UserInfoManagerObserver> observer = [value nonretainedObjectValue];
            if ([observer respondsToSelector:@selector(userInfoUpdate)]) {
                [observer userInfoUpdate];
            }
        }
    }
}

- (void)saveBlessCToUserDefaults {
	NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:_num_bless_readed forKey:key_num_bless_readed];
	[userDefaults setDouble:_num_bless forKey:key_num_bless];
    [userDefaults synchronize];
}

-(void)setImageWithUrl:(NSString*)url forOb:(id)object placehoderimg:(UIImage*)placeholder
{
    if ([object isKindOfClass:[UIImageView class]]) {
        UIImageView *imageview=(UIImageView*)object;
        UIImage *placehoderimg=imageview.image;
        if (!placehoderimg||![url isNotEmptyCtg]) {
            placehoderimg=placeholder;
        }
        
        [imageview sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placehoderimg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                imageview.image=placeholder;
            }
        }];
        
    }
    else if ([object isKindOfClass:[UIButton class]])
    {
        UIButton *btn=(UIButton*)object;
        UIImage *placehoderimg=btn.currentBackgroundImage;
        if (!placehoderimg||![url isNotEmptyCtg]) {
            placehoderimg=placeholder;
        }
        UIImageView *imageview=[UIImageView new];
        [imageview sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placehoderimg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                [btn setBackgroundImage:placeholder forState:UIControlStateNormal];
            }
            else
                [btn setBackgroundImage:imageview.image forState:UIControlStateNormal];
        }];
    }
}

-(void)addInfoUpdateObserver:(id<UserInfoManagerObserver>)observer forName:(NSString*)name
{
    NSValue *value=[NSValue valueWithNonretainedObject:observer];
    NSMutableArray *observerChain = [observerMapping objectForKey:name];
    if (observerChain == nil) {
        observerChain = [[NSMutableArray alloc] initWithObjects:value, nil];
    } else {
        if(![observerChain containsObject:value])
            [observerChain addObject:value];
    }
    [observerMapping setObject:observerChain forKey:name];
}

- (void)removeInfoUpdateObserver:(id<UserInfoManagerObserver>)observer forName:(NSString*)name {
    NSValue *value = [NSValue valueWithNonretainedObject:observer];
    NSMutableArray *observerChain = [observerMapping objectForKey:name];
    if (observerChain != nil) {
        if ([observerChain containsObject:value]) {
            [observerChain removeObject:value];
            [observerMapping setObject:observerChain forKey:name];
        }
    }
}

- (void)removeAllEventObserver {
    [observerMapping removeAllObjects];
}

-(void)updateUserInfoFromServer
{
    [PostDataService postUserCenterWithBlock:^(NSDictionary *result, NSError *error) {
        if(error) {
            return;
        }
        [self saveUserInfoFromUserCenter:result];
    }];
//    [BlingService getInviteStateWithBlock:^(NSDictionary *result, NSError *error) {
//        if (error) {
//            return;
//        }
//        self.inviteDic = result;
//        [self saveUserInfoFromInviteState:result];
//    }];
}

- (void)saveUserInfoFromInviteState:(NSDictionary *)result
{
    NSDictionary *data = result[@"data"];
    if ([data[@"type"] isEqualToString:@"invitee"]) {
        self.blingState = waitBling;
        [self saveToUserDefaults];
    }
}

- (void)saveUserInfoFromUserCenter:(NSDictionary *)result
{
    self.username_self = [LWUtil getString:result[@"username"] andDefaultStr:@""];
    self.domainName = [LWUtil getString:result[@"domain"] andDefaultStr:@""];
    self.num_demand = [LWUtil getString:result[@"reward_count"] andDefaultStr:@""];
    NSNumber *wed_time = result[@"wedding_timestamp"];
    self.weddingTime = wed_time.longLongValue;
    NSString *gender = [LWUtil getString:result[@"gender"] andDefaultStr:@""];
    if ([gender isEqualToString:@"f"]) {
        self.userGender = UserGenderFemale;
    } else if ([gender isEqualToString:@"m"]) {
        self.userGender = UserGenderMale;
    } else {
        self.userGender = UserGenderUnknow;
    }
    self.avatar_partner = [LWUtil getString:result[@"half_avatar"] andDefaultStr:@""];
    self.num_like = [LWUtil getString:result[@"follow_count"] andDefaultStr:@""];
    self.phone_partner = [LWUtil getString:result[@"half_phone"] andDefaultStr:@""];

	NSArray *points = [[LWUtil getString:result[@"wedding_map_point"] andDefaultStr:@""] componentsSeparatedByString:@","];
	if(points.count == 2){
		self.wedding_map_point = [NSString stringWithFormat:@"%@,%@",points[1],points[0]];
	}else{
		self.wedding_map_point = @"";
	}

    self.username_partner = [LWUtil getString:result[@"half_username"] andDefaultStr:@""];
    self.phone_self = [LWUtil getString:result[@"phone"] andDefaultStr:@""];
    self.userId_partner = [LWUtil getString:result[@"half_id"] andDefaultStr:@""];
    self.avatar_self = [LWUtil getString:result[@"avatar"] andDefaultStr:@""];
    self.wedding_address = [LWUtil getString:result[@"wedding_address"] andDefaultStr:@""];
    self.num_order = [LWUtil getString:result[@"order_count"] andDefaultStr:@""];
    self.userId_self = [LWUtil getString:result[@"id"] andDefaultStr:@""];
    if ([result[@""] isEqualToString:@""]) {
        self.blingState = hasBling;
    } else if([result[@""] isEqualToString:@""]) {
        self.blingState = unBling;
    }
    [self saveToUserDefaults];
}

-(void)setMyAvatar:(id)myHeadImageView
{
    [self setImageWithUrl:self.avatar_self forOb:myHeadImageView placehoderimg:[WeddingTimeAppInfoManager avatarPlceholdSelf]];
}

-(void)setPartnerAvatar:(id)partnerHeadImageView
{
    [self setImageWithUrl:self.avatar_partner forOb:partnerHeadImageView placehoderimg:[WeddingTimeAppInfoManager avatarPlceholdPartner]];
}

//返回祝福未读条数
- (NSString *)getUnreadBlessCount
{
	NSString *countString = @"";
	double num = self.num_bless - self.num_bless_readed;
	if(num <= 0){
		countString = @"";
	}else if (num < 100){
		countString = [NSString stringWithFormat:@"%.f",num];
	}else{
		countString = kBadgeMore;
	}
	
	return countString;
}

-(void)exit
{
    self.tokenId_self        = @"";
    self.tokenId_partner     = @"";
    self.avatar_self         = @"";
    self.avatar_partner      = @"";
    self.username_self       = @"";
    self.username_partner    = @"";
    self.phone_partner       = @"";
    self.phone_self          = @"";
    self.domainName          = @"";
    self.wedding_address= @"";
    self.wedding_map_point= @"";
    self.userId_self         = @"";
    self.userId_partner      = @"";
    //self.HotVip              = @{};
    self.userGender          = UserGenderUnknow;
    self.weddingTime         = NSTimeIntervalSince1970;
    // self.homePageInfo        = @{};
    self.backMusicName = @"";
    self.num_demand  = @"0";
    self.num_like = @"0";
    self.num_order = @"0";
	self.num_bless_readed = 0;
	self.num_bless = 0;
   
    [self saveToUserDefaults];
}


@end
