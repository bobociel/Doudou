//
//  BottomView.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BottomView.h"
#import "GetService.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
@interface BottomView ()

@end
@implementation BottomView
{
    UIButton *likeButton;
    UIButton *telButton;
    UIButton *covButton;
    UIButton *orderButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)sendSecondBottomPush
{
    NSNumber *islike;
    if (_is_like) {
        islike = @(1);
    } else {
        islike = @(0);
    }
    NSDictionary *dic = @{
                          @"is_like" : islike,
                          @"supplier_id" : _supplier_id,
                          };
    [[NSNotificationCenter defaultCenter] postNotificationName:SecondBottomPush object:nil userInfo:dic];
}
- (void)likeAction
{
    if (![LWAssistUtil isLogin]) {
        return;
    }
    if (likeButton.tag == 1000) {
        
        if (_type == 0) {
            [PostDataService postLikeWithService_id:_supplier_id  Block:^(NSDictionary *result, NSError *error) {
                if (!error) {
                    NSString *title=[NSString stringWithFormat:@"喜欢了一个服务商\n%@   ",_name];
                    
                    [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                        if (ourCov) {
                            [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_supplier_id,@"type":@"s",@"title":title,@"name":_name} andCovTitle:title  conversation:ourCov push:YES success:^{
                                
                            } failure:^(NSError *error) {
                                
                            }];
                        }
                    }];


                    likeButton.tag = 1001;
                    self.is_like = YES;
                    NSInteger num = [UserInfoManager instance].num_like.integerValue;
                    num++;
                    [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                    [[UserInfoManager instance] saveToUserDefaults];
                    [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_select"] forState:UIControlStateNormal]; // todo
                    [[NSNotificationCenter defaultCenter] postNotificationName:BOTTOMVIEWNOTIFY object:nil];
                    [self sendSecondBottomPush];
//                    if ([self.delegate respondsToSelector:@selector(secondBottomHasSelect:)]) {
//                        [self.delegate secondBottomHasSelect:_is_like];
//                    }
                }
            }];
        } else {
            
            [PostDataService postLikeWithHotel_id:_supplier_id Block:^(NSDictionary *restult, NSError *error) {
                if (!error) {
                    NSString *title=[NSString stringWithFormat:@"喜欢了一个酒店\n%@   ",_name];
                    
                    [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                        if (ourCov) {
                            [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_supplier_id,@"type":@"h",@"title":title,@"name":_name} andCovTitle:title  conversation:ourCov push:YES success:^{
                                
                            } failure:^(NSError *error) {
                                
                            }];
                        }
                    }];
                    self.is_like = YES;
                    likeButton.tag = 1001;
                    NSInteger num = [UserInfoManager instance].num_like.integerValue;
                    num++;
                    [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                    [[UserInfoManager instance] saveToUserDefaults];
                    [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_select"] forState:UIControlStateNormal]; // todo
                    [[NSNotificationCenter defaultCenter] postNotificationName:BOTTOMVIEWNOTIFY object:nil];
                    [self sendSecondBottomPush];
//                    if ([self.delegate respondsToSelector:@selector(secondBottomHasSelect:)]) {
//                        [self.delegate secondBottomHasSelect:_is_like];
//                    }
                }
            }];
        }
        

    } else if (likeButton.tag == 1001) {
        if (_type == 0) {
            [PostDataService postLikeWithService_id:_supplier_id  Block:^(NSDictionary *result, NSError *error) {
                if (!error) {
                    self.is_like = NO;
                    likeButton.tag = 1000;
                    NSInteger num = [UserInfoManager instance].num_like.integerValue;
                    num--;
                    [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                    [[UserInfoManager instance] saveToUserDefaults];
                    [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal]; // todo
                    [[NSNotificationCenter defaultCenter] postNotificationName:BOTTOMVIEWNOTIFY object:nil];
                    [self sendSecondBottomPush];
//                    if ([self.delegate respondsToSelector:@selector(secondBottomHasSelect:)]) {
//                        [self.delegate secondBottomHasSelect:_is_like];
//                    }
                }
                
                
            }];
        } else {
            [PostDataService postLikeWithHotel_id:_supplier_id Block:^(NSDictionary *restult, NSError *error) {
                if (!error) {
                    self.is_like = NO;
                    likeButton.tag = 1000;
                    NSInteger num = [UserInfoManager instance].num_like.integerValue;
                    num--;
                    [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                    [[UserInfoManager instance] saveToUserDefaults];
                    [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal]; // todo
                    [[NSNotificationCenter defaultCenter] postNotificationName:BOTTOMVIEWNOTIFY object:nil];
                
                    [self sendSecondBottomPush];
//                    if ([self.delegate respondsToSelector:@selector(secondBottomHasSelect:)]) {
//                        [self.delegate secondBottomHasSelect:_is_like];
//                    }
                }
            }];
        }

    }
    
}

- (void)telAction
{
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView mp_setImageWithURL:self.supplier_avatar placeholderImage:[UIImage imageNamed:@"male_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:@"是否拨打该商家电话" centerImage:image];
        //        alert.delegate = self;
        
        alert.buttonTitles = @[@"取消", @"拨打"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            [alert close];
            
            if (index == 0) {
                
            } else if (index == 1) {
                if ([self.tel_num isNotEmptyCtg]) {
                    NSString *str = [NSString stringWithFormat:@"tel://%@", _tel_num];
                    //        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",@"10086"];
                    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]) {
                        [WTProgressHUD ShowTextHUD:@"号码无效" showInView:KEY_WINDOW];
                        return;
                        
                    }
                    
                } else {
                    [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
                }

            }
            
        };
        [alert show];
    }];
    
}

- (void)covAction
{
    if (![LWAssistUtil isLogin]) {
        return;
    }
    [self.mainDelegate conversationButtonHasSelectType:self.type];
}

- (void)orderAction
{
    if (![LWAssistUtil isLogin]) {
        return;
    }
    if (self.isfrom_type == isFrom_supplier) {
        [self.mainDelegate orderButtonHasSelect:self.supplier_id type:self.isfrom_type];
    } else {
        [self.mainDelegate orderButtonHasSelect:self.work_id type:self.isfrom_type];
    }
    
}

- (void)changeLikeButtonStyle
{
    if (self.is_like) {
        likeButton.tag = 1001;
        [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_select"] forState:UIControlStateNormal];
    } else {
        likeButton.tag = 1000;
        [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
    }
}

- (void)initView
{
    likeButton = [[UIButton alloc] init];
   
    if (self.is_like) {
        likeButton.tag = 1001;
        [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_select"] forState:UIControlStateNormal];
    } else {
        likeButton.tag = 1000;
        [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
    }
     // todo
//    [likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateHighlighted]; // todo
    [likeButton addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:likeButton];
    telButton = [[UIButton alloc] init];
    [telButton setBackgroundImage:[UIImage imageNamed:@"tel"] forState:UIControlStateNormal];
    [telButton setBackgroundImage:[UIImage imageNamed:@"tel_select"] forState:UIControlStateHighlighted];
    [telButton addTarget:self action:@selector(telAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:telButton];
    covButton = [[UIButton alloc] init];
    [covButton setBackgroundImage:[UIImage imageNamed:@"cov"] forState:UIControlStateNormal];
    [covButton setBackgroundImage:[UIImage imageNamed:@"cov_select"] forState:UIControlStateHighlighted];
    [covButton addTarget:self action:@selector(covAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:covButton];
    orderButton = [[UIButton alloc] init];
    [self addSubview:orderButton];
    [orderButton setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
    [orderButton addTarget:self action:@selector(orderAction) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setTitle:@"预约" forState:UIControlStateNormal];
    [orderButton setTitleColor:WHITE forState:UIControlStateNormal];

    orderButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];

}

- (void)showTwoButtons
{
    telButton.frame = CGRectMake(20 * Width_ato, 2 * Height_ato, 46 * Width_ato, 46 * Width_ato);
    covButton.frame = CGRectMake(75 * Width_ato, 2 * Height_ato, 46 * Width_ato, 46 * Width_ato);
}

- (void)showThreeButtons
{
    likeButton.frame = CGRectMake(10 * Width_ato, 2 * Height_ato, 46 * Width_ato, 46 * Width_ato);
    telButton.frame = CGRectMake(66 * Width_ato, 2 * Height_ato, 46 * Width_ato, 46 * Width_ato);
    covButton.frame = CGRectMake(122 * Width_ato, 2 * Height_ato, 46 * Width_ato, 46 * Width_ato);
}
- (void)showFourButtons
{
    [self showThreeButtons];
    orderButton.frame = CGRectMake(318 * Width_ato, 4 * Height_ato, 87 * Width_ato, 44 * Height_ato);
    orderButton.layer.cornerRadius = 22.0f * Height_ato;
}

//- (void)addObserver:(id<BottomViewDelegate>)observer forName:(NSString *)name
//{
//    NSValue *value = [NSValue valueWithNonretainedObject:observer];
//    NSMutableArray *observerChain = [observerMapping objectForKey:name];
//    if (observerChain == nil) {
//        observerChain = [[NSMutableArray alloc] initWithObjects:observer, nil];
//    } else {
//        if(![observerChain containsObject:value])
//            [observerChain addObject:value];
//    }
//    [observerMapping setObject:observerChain forKey:name];
//}
//
//- (void)removeObserver:(id<BottomViewDelegate>)observer forName:(NSString *)name
//{
//    NSMutableArray *observerChain = [observerMapping objectForKey:name];
//    if (observerChain != nil) {
//        [observerChain removeObject:observer];
//        [observerMapping setObject:observerChain forKey:name];
//    }
//}

@end
