//
//  BottomView.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BOTTOMVIEWNOTIFY @"bottomViewNotify"
static  NSString *const orderObserver=@"orderObserver";



typedef NS_ENUM(NSInteger, isFromType) {
    isFrom_supplier = 0,
    isFrom_work    =1,
    
};
@protocol SecondBottomDelegate <NSObject>

- (void)secondBottomHasSelect:(BOOL)is_like;

@end
@protocol BottomViewDelegate <NSObject>
@optional
- (void)orderButtonHasSelect:(NSNumber *)supplier_id type:(isFromType)type;
- (void)conversationButtonHasSelectType:(NSInteger)type;
@end
@interface BottomView : UIView

@property (nonatomic, copy) NSNumber *supplier_id;
@property (nonatomic, copy) NSNumber *work_id;
@property (nonatomic, copy) NSString *tel_num;
@property (nonatomic, assign) isFromType isfrom_type;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, weak) id<SecondBottomDelegate> delegate;
@property (nonatomic, weak) id<BottomViewDelegate> mainDelegate;

- (void)showFourButtons;
- (void)showThreeButtons;
- (void)showTwoButtons;
- (void)changeLikeButtonStyle;
//-(void)addObserver:(__weak id<BottomViewDelegate>)observer forName:(NSString*)name;
////别忘了在iewcontroller的delleac中remove哦
//-(void)removeObserver:(__weak id<BottomViewDelegate>)observer forName:(NSString*)name;
@end
