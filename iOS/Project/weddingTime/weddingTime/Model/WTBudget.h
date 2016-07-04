//
//  WTBudget.h
//  weddingTime
//
//  Created by wangxiaobo on 16/4/18.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,WTADType) {
	WTADTypePost = 1,
	WTADTypeSupplier,
	WTADTypeURL,
	WTADTypeBao
};

@interface WTBudgetInfo : NSObject
@property (nonatomic,copy) NSString *min_price;
@property (nonatomic,copy) NSString *max_price;
@property (nonatomic,copy) NSString *step;
@end

@interface WTBudgetInfos : NSObject
@property (nonatomic,strong) WTBudgetInfo *planBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *photoBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *captureBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *hostBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *dressBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *makeUpBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *videoBudgetInfo;
@property (nonatomic,strong) WTBudgetInfo *hotelBudgetInfo;
@end

@interface WTBudgetDetail : NSObject
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *budget_cost;
@property (nonatomic,copy) NSString *planBudget;
@property (nonatomic,copy) NSString *photoBudget;
@property (nonatomic,copy) NSString *captureBudget;
@property (nonatomic,copy) NSString *hostBudget;
@property (nonatomic,copy) NSString *dressBudget;
@property (nonatomic,copy) NSString *makeUpBudget;
@property (nonatomic,copy) NSString *videoBudget;
@property (nonatomic,copy) NSString *hotelBudget;
@end

@interface WTBudget : NSObject
@property (nonatomic,strong) WTBudgetInfos  *service_price;
@property (nonatomic,strong) WTBudgetDetail *budget;
@end

@interface WTAd : NSObject
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *jump_to;
@property (nonatomic,assign) WTADType jump_way;
@property (nonatomic,assign) unsigned long long start;
@property (nonatomic,assign) unsigned long long end;
@end
