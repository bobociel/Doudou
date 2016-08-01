//
//  CommonTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UserInfoManager.h"
#import "LWAssistUtil.h"
#import <Masonry.h>
#import "GetService.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "CommAnimationForControl.h"
@implementation UITableView(CommWeddingListCell)

- (CommonTableViewCell *)commonCell{
    
    static NSString *CellIdentifier = @"CommonTableViewCell";
    
    CommonTableViewCell * cell = (CommonTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@interface CommonTableViewCell ()

@property (nonatomic,assign) int like_count;
@end

@implementation CommonTableViewCell
{
    UIImageView *topImage;
    UILabel *nameLabel;
    UILabel *detailLabel;
    UIView *shadowView;
    UIImageView *likeIcon;
    UIButton *likeButton;
	UIImageView *videoIcon;
}
- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.shadowSign = YES;
        [self initView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    topImage.frame = CGRectMake(0, 0, screenWidth, 300 * Height_ato);
    topImage.bounds = CGRectMake(0, 0, screenWidth, 300 * Height_ato);
}

- (void)initView
{
    topImage = [UIImageView new];
    [self.contentView addSubview:topImage];
    
    nameLabel = [UILabel new];
    [self.contentView addSubview:nameLabel];
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    
    
    detailLabel = [UILabel new];
    [self.contentView addSubview:detailLabel];
    detailLabel.textColor = subTitleLableColor;
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    
    shadowView = [UIView new];
    shadowView.backgroundColor = rgba(230, 230, 230, 1);
    [self.contentView addSubview:shadowView];
    
    
    likeIcon = [UIImageView new];
    likeIcon.userInteractionEnabled = NO;
    [self.contentView addSubview:likeIcon];

    likeButton = [[UIButton alloc] initWithFrame:CGRectMake(349 *Width_ato, 237 * Height_ato, 61, 57)];
    [self.contentView addSubview:likeButton];
    [likeButton addTarget:self action:@selector(likeIconAction) forControlEvents:UIControlEventTouchUpInside];
    likeButton.backgroundColor = [UIColor clearColor];
    likeIcon.frame = CGRectMake(369.18 * Width_ato, 257 * Height_ato, 26, 22.28);

    nameLabel.frame = CGRectMake(15 * Width_ato, 330 * Height_ato, screenWidth, 23 * Height_ato);
    detailLabel.frame = CGRectMake(15 * Width_ato, 365 * Height_ato, screenWidth, 17 * Height_ato);
    float height = 362 * Height_ato;
    if (height < 237) {
        detailLabel.frame = CGRectMake(15, 370 * Height_ato, screenWidth, 17 * Height_ato);
    }
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(410 * screenHeight / 736.0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(5* Height_ato);
    }];

	videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon"]];
	videoIcon.frame = CGRectMake((screenWidth - 80)/2, (300 * Height_ato - 80)/2 , 80, 80);
	[self.contentView addSubview:videoIcon];

	videoIcon.hidden = YES;
}

- (void)likeIconAction
{
    if (![LWAssistUtil isLogin]) {
        return;
    }
    
    if (_ifSH) {
        if (_type == 0) {
            if (_isLike) {

                self.like_count--;
                NSNumber *num_now = @(self.like_count);
                NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
                NSString *price = [LWUtil getString:_info[@"price"] andDefaultStr:@"0"];
				NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;

                NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   作品 %@   喜欢 %@",price, works_count, like_count];
                detailLabel.text = detail;
                likeIcon.image = [UIImage imageNamed:@"like_unselect"];
                [likeIcon.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScaleAnimationUnDefault"];
                _isLike = NO;
                NSInteger num = [UserInfoManager instance].num_like.integerValue;
                num--;
                [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                [[UserInfoManager instance] saveToUserDefaults];
                [PostDataService postLikeWithService_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                    if (error) {
                        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    } else {  }
                }];
                //todo
            } else {
                self.like_count++;
                NSNumber *num_now = @(self.like_count);
                NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
                NSString *price = [LWUtil getString:_info[@"price"] andDefaultStr:@"0"];
                NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;

                NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   作品 %@   喜欢 %@",price, works_count, like_count];
                detailLabel.text = detail;
                
                [likeIcon.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScaleAnimationDefault"];
                likeIcon.image = [UIImage imageNamed:@"like_select"];

                NSInteger num = [UserInfoManager instance].num_like.integerValue;
                num++;
                [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                [[UserInfoManager instance] saveToUserDefaults];
                _isLike = YES;
                [PostDataService postLikeWithService_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                    if (error) {
                        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，收藏请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    } else {
                        NSString *name=[LWAssistUtil cellInfo:_info[@"company"] andDefaultStr:@""];
                        NSString *title=[NSString stringWithFormat:@"喜欢了一个服务商\n%@   ",name];
                      
                        [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                            if (ourCov) {
                                 [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_service_id,@"type":@"s",@"title":title,@"name":name} andCovTitle:title  conversation:ourCov push:YES success:^{
                                     
                                 } failure:^(NSError *error) {
                                     
                                 }];
                            }
                        }];
                        
                        
                    }
                }];
                
                _isLike = YES;
                //todo
            }
        } else {
            if (_isLike) {
                
                //                NSNumber *row = [NSNumber numberWithInteger:self.row];
                //                NSDictionary *dic = @{@"cancelRow" : row};
                self.like_count--;
                NSNumber *num_now = @(self.like_count);
                NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
                NSString *price = [LWUtil getString:_info[@"price_start"] andDefaultStr:@"0"];

				NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"menu_num"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;
				works_count = [works_count integerValue] == 0 ? [LWUtil getString:_info[@"menu_count"] andDefaultStr:@"0"]: works_count ;

                NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   套餐 %@   喜欢 %@",price, works_count, like_count];
                detailLabel.text = detail;
                
                likeIcon.image = [UIImage imageNamed:@"like_unselect"];
                [likeIcon.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScaleAnimationUnDefault"];
                //                        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidCancelLikeNotify object:nil userInfo:dic];
                NSInteger num = [UserInfoManager instance].num_like.integerValue;
                num--;
                [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                [[UserInfoManager instance] saveToUserDefaults];
                _isLike = NO;
                [PostDataService postLikeWithHotel_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                    if (error) {
                        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    } else {
                        
                    }
                    
                }];
                
                
                //todo
            } else {
                self.like_count++;
                NSNumber *num_now = @(self.like_count);
                NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
                NSString *price = [LWUtil getString:_info[@"price_start"] andDefaultStr:@"0"];

                 NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"menu_num"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;
				works_count = [works_count integerValue] == 0 ? [LWUtil getString:_info[@"menu_count"] andDefaultStr:@"0"]: works_count ;

                NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   套餐 %@   喜欢 %@",price, works_count, like_count];
                detailLabel.text = detail;
                
                [likeIcon.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScaleAnimationDefault"];
                likeIcon.image = [UIImage imageNamed:@"like_select"];
                //                        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidCancelLikeNotify object:nil userInfo:nil];
                NSInteger num = [UserInfoManager instance].num_like.integerValue;
                num++;
                [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
                [[UserInfoManager instance] saveToUserDefaults];
                _isLike = YES;
                [PostDataService postLikeWithHotel_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                    //                [likeIcon.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScaleAnimationDefault"];
                    //                likeIcon.image = [UIImage imageNamed:@"like_select"];
                    if (error) {
                        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，收藏请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    } else {
                        NSString *name=[LWAssistUtil cellInfo:_info[@"name"] andDefaultStr:@""];
                        NSString *title=[NSString stringWithFormat:@"喜欢了一个酒店\n%@   ",name];
                        
                        [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                            if (ourCov) {
                                [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_service_id,@"type":@"h",@"title":title,@"name":name} andCovTitle:title  conversation:ourCov push:YES success:^{
                                    
                                } failure:^(NSError *error) {
                                    
                                }];
                            }
                        }];

                        
                    }
                }];
                
                _isLike = YES;
            }
        }
        NSNumber *islike;
        if (_isLike) {
            islike = @(1);
        } else {
            islike = @(0);
        }
        if ([self.delegate respondsToSelector:@selector(refreshArrayWithRow:isLike:)]) {
            [self.delegate refreshArrayWithRow:self.row isLike:islike];
        }
        return;
    }
    else//喜欢列表
    {
        if (_type == 0) {
           
            likeButton.userInteractionEnabled = NO;
            NSInteger num = [UserInfoManager instance].num_like.integerValue;
            num--;
            [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
            [[UserInfoManager instance] saveToUserDefaults];
            self.like_count--;
            NSNumber *num_now = @(self.like_count);
            NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
            NSString *price = [LWUtil getString:_info[@"price"] andDefaultStr:@"0"];

             NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;

            NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   作品 %@   喜欢 %@",price, works_count, like_count];
            detailLabel.text = detail;
            likeIcon.image = [UIImage imageNamed:@"like_unselect"];
            [likeIcon.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefaultWithCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                _isLike = NO;
            }] forKey:@"layerScaleAnimationUnDefault"];

            [PostDataService postLikeWithService_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                if (error) {
                    [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    self.alpha = 1.0f;
                } else {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.alpha = 0;
                    } completion:^(BOOL finished) {
                        likeIcon.userInteractionEnabled = YES;
                        if ([self.delegate respondsToSelector:@selector(cancelLikeNum:)]) {
                            [self.delegate cancelLikeNum:self.row];
                        }
                        
                    }];
				}
            }];
            
        } else {
            likeButton.userInteractionEnabled = NO;
            NSInteger num = [UserInfoManager instance].num_like.integerValue;
            num--;
            [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
            [[UserInfoManager instance] saveToUserDefaults];
            self.like_count--;
            NSNumber *num_now = @(self.like_count);
            NSString *like_count = [LWUtil getString:num_now andDefaultStr:@"0"];
            NSString *price = [LWUtil getString:_info[@"price_start"] andDefaultStr:@"0"];
            NSString *works_count = [_info[@"post_num"] integerValue] == 0 ? [LWUtil getString:_info[@"menu_num"] andDefaultStr:@"0"] : [LWUtil getString:_info[@"post_num"] andDefaultStr:@"0"] ;
			works_count = [works_count integerValue] == 0 ? [LWUtil getString:_info[@"menu_count"] andDefaultStr:@"0"]: works_count ;

            NSString *detail = [NSString stringWithFormat:@"报价 ￥%@起   套餐 %@   喜欢 %@",price, works_count, like_count];
            detailLabel.text = detail;
            likeIcon.image = [UIImage imageNamed:@"like_unselect"];
            [likeIcon.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefaultWithCompletionBlock:^(POPAnimation *anim, BOOL finished) {
				
                _isLike = NO;
            }] forKey:@"layerScaleAnimationUnDefault"];
            [PostDataService postLikeWithHotel_id:_service_id Block:^(NSDictionary *result, NSError *error) {
                if (error) {
                    [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
                    self.alpha = 1.0f;
                } else {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.alpha = 0;
                    } completion:^(BOOL finished) {
                        if ([self.delegate respondsToSelector:@selector(cancelLikeNum:)]) {
                            [self.delegate cancelLikeNum:self.row];
                        }
                        
                    }];

                }
                
            }];
            
        }
    }
    
}
- (void)setUIWithInfo:(id)info
{
    self.info = info;
    likeButton.userInteractionEnabled = YES;
	if(self.supplier_type == 12) 
	{
		videoIcon.hidden = NO;
	}
    NSString *imageUrl;
    NSString *name;
    NSString *like_count;
    NSString *price;
    NSString *works_count;
    NSString *detail;
    NSNumber *is_like = info[@"is_like"];
    if (is_like.intValue == 1) {
        self.isLike = YES;
    } else {
        self.isLike = NO;
    }
    if (_ifSH) {
        if (_isLike) {
            likeIcon.image = [UIImage imageNamed:@"like_select"];
        } else {
            likeIcon.image = [UIImage imageNamed:@"like_unselect"];
        }
    } else {
        likeIcon.image = [UIImage imageNamed:@"like_select"];
    }
    if (_type == 0) {
        if (_ifSH) {
            imageUrl = [LWUtil getString:info[@"logo_path"] andDefaultStr:@""];
            name = [LWUtil getString:info[@"company"] andDefaultStr:@"暂无"];
			price = [LWUtil getString:info[@"price"] andDefaultStr:@"0"];

			like_count = [info[@"like_num"] integerValue] == 0 ? [LWUtil getString:info[@"like_count"] andDefaultStr:@"0"] : [LWUtil getString:info[@"like_num"] andDefaultStr:@"0"];
			NSNumber *number = info[@"like_num"] == 0 ? info[@"like_count"]: info[@"like_num"] ;
            self.like_count = number.intValue;
			works_count = [info[@"post_num"] integerValue] == 0 ? [LWUtil getString:info[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:info[@"post_num"] andDefaultStr:@"0"];
            detail = [NSString stringWithFormat:@"报价 ￥%@起   作品 %@   喜欢 %@",price, works_count, like_count];
        } else {
            imageUrl = [LWUtil getString:info[@"logo_path"] andDefaultStr:@""];
            name = [LWUtil getString:info[@"company"] andDefaultStr:@"暂无"];
            price = [LWUtil getString:info[@"price"] andDefaultStr:@"0"];

			like_count = [info[@"like_num"] integerValue] == 0 ? [LWUtil getString:info[@"like_count"] andDefaultStr:@"0"] : [LWUtil getString:info[@"like_num"] andDefaultStr:@"0"];
			NSNumber *number = info[@"like_num"] == 0 ? info[@"like_count"]: info[@"like_num"] ;
			self.like_count = number.intValue;
			works_count = [info[@"post_num"] integerValue] == 0 ? [LWUtil getString:info[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:info[@"post_num"] andDefaultStr:@"0"];

            detail = [NSString stringWithFormat:@"报价 ￥%@起   作品 %@   喜欢 %@",price, works_count, like_count];
        }
    } else {
        if (_ifSH) {
            imageUrl = info[@"main_pic"];
            name = [LWUtil getString:info[@"name"] andDefaultStr:@"暂无"];
            price = [LWUtil getString:info[@"price_start"] andDefaultStr:@"0"];

			like_count = [info[@"like_num"] integerValue] == 0 ? [LWUtil getString:info[@"collect_num"] andDefaultStr:@"0"] : [LWUtil getString:info[@"like_num"] andDefaultStr:@"0"];
			like_count = [like_count integerValue] == 0 ? [LWUtil getString:_info[@"like_count"] andDefaultStr:@"0"] : like_count;
			self.like_count = like_count.intValue;

			works_count = [info[@"post_num"] integerValue] == 0 ? [LWUtil getString:info[@"menu_num"] andDefaultStr:@"0"] : [LWUtil getString:info[@"post_num"] andDefaultStr:@"0"];
			works_count = [works_count integerValue] == 0 ? [LWUtil getString:_info[@"menu_count"] andDefaultStr:@"0"]: works_count ;

            detail = [NSString stringWithFormat:@"报价 ￥%@起   套餐 %@   喜欢 %@",price, works_count, like_count];
        } else {
            imageUrl = info[@"main_pic"];
            name = [LWUtil getString:info[@"name"] andDefaultStr:@"暂无"];
            price = [LWUtil getString:info[@"price_start"] andDefaultStr:@"0"];

			like_count = [info[@"like_num"] integerValue] == 0 ? [LWUtil getString:info[@"collect_num"] andDefaultStr:@"0"] : [LWUtil getString:info[@"like_num"] andDefaultStr:@"0"];
			like_count = [like_count integerValue] == 0 ? [LWUtil getString:_info[@"like_count"] andDefaultStr:@"0"] : like_count;
			self.like_count = like_count.intValue;

			works_count = [info[@"post_num"] integerValue] == 0 ? [LWUtil getString:info[@"menu_num"] andDefaultStr:@"0"] : [LWUtil getString:info[@"post_num"] andDefaultStr:@"0"];
			works_count = [works_count integerValue] == 0 ? [LWUtil getString:_info[@"menu_count"] andDefaultStr:@"0"]: works_count ;

            detail = [NSString stringWithFormat:@"报价 ￥%@起   套餐 %@   喜欢 %@",price, works_count, like_count];
        }
    }
    
    __weak UIImageView *top = topImage;
    topImage.contentMode = UIViewContentModeCenter;
	topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
    [topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageUrl]
								  placeholderImage:nil
										   options:SDWebImageRetryFailed
										  progress:nil
										 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
											 if (image != nil) {
												 top.contentMode =  UIViewContentModeScaleAspectFill;
											 }
										 }
							  ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										  Diameter:50];

    topImage.clipsToBounds = YES;
	[topImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    topImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    nameLabel.text = name;
    detailLabel.text = detail;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
