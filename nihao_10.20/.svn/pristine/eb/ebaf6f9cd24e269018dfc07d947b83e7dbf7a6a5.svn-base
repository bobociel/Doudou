//
//  DynamicCell.m
//  nihao
//
//  Created by 刘志 on 15/6/15.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "DynamicCell.h"
#import "UserPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "BaseFunction.h"
#import <pop/POP.h>
#import "HttpManager.h"
#import "AppConfigure.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "MWPhotoBrowser.h"

@interface DynamicCell ()<POPAnimationDelegate, UIAlertViewDelegate,MMGridViewDataSource,MMGridViewDelegate,MWPhotoBrowserDelegate,UIActionSheetDelegate>

@end

@implementation DynamicCell {
    UserPost *userPost;
    NSIndexPath *currentIndexPath;
    NSInteger _picWidth;
    NSInteger _picHeight;
    MWPhotoBrowser *_photoBrowser;
    SDWebImageManager *_sdWebImageManager;
    UIActionSheet *_savePicSheet;
}

static const NSInteger PIC_MARGIN = 1.5;

- (void)awakeFromNib {
    [super awakeFromNib];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _sdWebImageManager = [SDWebImageManager sharedManager];
}

- (void)configureCellForMyPosts:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 显示delete按钮
    self.deleteBtn.hidden = NO;
    // 隐藏关注按钮
    self.focusState.hidden = YES;
    currentIndexPath = indexPath;
    self.viewNumView.hidden = NO;
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:self.viewNumView];
    [self setPostViews:post];
}

- (void) configureCellForPostDetail : (UserPost *) post forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 显示delete按钮
    self.deleteBtn.hidden = YES;
    // 隐藏关注按钮
    self.focusState.hidden = NO;
    currentIndexPath = indexPath;
    self.viewNumView.hidden = NO;
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:self.viewNumView];
    [self setPostViews:post];
}

- (void)configureCellForMyFollowPosts:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 显示delete按钮
    self.deleteBtn.hidden = YES;
	self.focusState.hidden = NO;
    currentIndexPath = indexPath;
    self.viewNumView.hidden = YES;
    [self setPostViews:post];
}

- (void)configureCellForDiscover:(UserPost *)post forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.deleteBtn.hidden = YES;
    self.focusState.hidden = NO;
    currentIndexPath = indexPath;
    self.viewNumView.hidden = YES;
    [self setPostViews:post];
}

- (void)setPostViews:(UserPost *)post {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
    userPost = post;
    if(userPost.pictures.count != 0) {
        //计算图片的大小
        //根据数量的不同设置图片集控件的高和宽
        for(UIView *subView in _gridView.subviews) {
            subView.hidden = NO;
        }
        
        NSUInteger row;
        NSUInteger column;
        if(userPost.pictures.count == 4) {
            column = 2;
            row = 2;
            _picWidth = (SCREEN_WIDTH - CGRectGetMinX(_gridView.frame) - 12) / 3;
            _picHeight = _picWidth;
        } else if(userPost.pictures.count == 1) {
            column = 1;
            row = 1;
            Picture *picture = userPost.pictures[0];
            _picWidth = picture.picture_thumbnail_width;
            _picHeight = picture.picture_thumbnail_height;
            
            //对缩略图的长和宽进行放缩处理
            _picWidth = _picWidth * 3 / 4;
            _picHeight = _picHeight * 3 / 4;
        } else {
            column = (userPost.pictures.count / 3 > 0) ? 3 : userPost.pictures.count % 3;
            row = (userPost.pictures.count % 3 == 0) ? userPost.pictures.count / 3 : (userPost.pictures.count / 3 + 1);
            _picWidth = (SCREEN_WIDTH - CGRectGetMinX(_gridView.frame) - 12) / 3;
            _picHeight = _picWidth;
        }
        
        _gridView.numberOfRows = row;
        _gridView.numberOfColumns = column;
        _gridView.cellMargin = PIC_MARGIN;
        _gridViewWidthConstraint.constant = _picWidth * column + (column - 1) * PIC_MARGIN;
        _gridViewHeightConstraint.constant = _picHeight * row;
        [_gridView reloadData];
        
    } else {
        for(UIView *subView in _gridView.subviews) {
            subView.hidden = YES;
        }
        _gridViewWidthConstraint.constant = 0.0;
        _gridViewHeightConstraint.constant = 0.0;
    }

    if (IsStringEmpty(post.ci_nikename)) {
        self.nickname.text = [NSString stringWithFormat:@"nihao_%d", post.cd_ci_id];
    } else {
        self.nickname.text = post.ci_nikename;
    }
    
	self.content.text = post.cd_info;
    self.content.lineBreakMode = NSLineBreakByClipping;
    self.publishTime.text = [BaseFunction dynamicDateFormat:post.cd_date];
    [self.publishTime sizeToFit];
    self.publishTimeWidthConstraint.constant = CGRectGetWidth(self.publishTime.frame);
    
    self.goodNum.text = [NSString stringWithFormat:@"%d", post.cd_sum_pii_count];
    self.commentNum.text = [NSString stringWithFormat:@"%d", post.cd_sum_cmi_count];
    self.viewNumLabel.text = [NSString stringWithFormat:@"%ld",post.cd_look_count];
    if(IsStringEmpty(post.cd_address)) {
        self.postLocation.hidden = YES;
    } else {
        self.postLocation.hidden = NO;
        self.postLocation.text = post.cd_address;
    }
    
    NSString *iconURLString = post.ci_header_img;
    if (IsStringEmpty(iconURLString)) {
        if (post.ci_sex == UserSexTypeFemale) {
            self.header.image = [UIImage imageNamed:@"default_icon_female"];
        } else {
            self.header.image = [UIImage imageNamed:@"default_icon_male"];
        }
    } else {
        [self.header sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                self.header.image = image;
            } else {
                self.header.image = [UIImage imageNamed:@"img_is_load_failed"];
            }
        }];
    }
    
    //给用户头像添加点击事件
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserLogo:)];
    recognizer.numberOfTapsRequired = 1;
    self.header.userInteractionEnabled = YES;
    [self.header addGestureRecognizer:recognizer];
    
    //是否已经点赞
    NSString *likeImageName = (userPost.pii_is_praise == 0) ? @"common_icon_like" : @"common_icon_liked";
    _goodImageView.image = [UIImage imageNamed:likeImageName];
    
    //是否已经关注
    if(!_focusState.hidden) {
        NSInteger friendType = userPost.friend_type;
		NSInteger cUserID = [AppConfigure integerForKey:LOGINED_USER_ID];
        if(userPost.cd_ci_id == cUserID) {
			_focusState.hidden = YES;
			[_focusState superview].userInteractionEnabled = NO;
        } else if(friendType == UserFriendTypeFollowed ||friendType == UserFriendTypeFriend) {
			//已关注对方
			_focusState.hidden = NO;
			NSString *imgName = (friendType == UserFriendTypeFollowed) ? @"icon_followed" : @"icon_followed_each_other";
			_focusState.image = ImageNamed(imgName);
			[_focusState superview].userInteractionEnabled = YES;
        } else {
            //未关注对方
            _focusState.hidden = NO;
            _focusState.image = ImageNamed(@"icon_follow");
            [_focusState superview].userInteractionEnabled = YES;
        }
    }
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void) tapUserLogo : (UITapGestureRecognizer *) recognizer {
    if(self.viewUserInfo) {
        self.viewUserInfo(userPost);   
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)addFocus:(id)sender {
    NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
    if(userPost.friend_type == UserFriendTypeNone || userPost.friend_type == UserFriendTypeFollower) {
        //add focus
        [self showHUDWithText:@"Following..."];
        [HttpManager addRelationBySelfUserID:uid toPeerUserID:[NSString stringWithFormat:@"%d",userPost.cd_ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:[self getNavigationController].view animated:YES];
            _focusState.hidden = YES;
            [self showHUDDoneWithText:@"Followed"];
            //刷新列表
            if(self.addFoucs) {
                if(userPost.friend_type == UserFriendTypeNone) {
                    userPost.friend_type = UserFriendTypeFollowed;
                } else {
                    userPost.friend_type = UserFriendTypeFriend;
                }
                self.addFoucs(userPost);
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:[self getNavigationController].view animated:YES];
            [self showNetErrHUD];
        }];
    } else {
        //delete focus
        [self showHUDWithText:@"UnFollowing..."];
        [HttpManager removeRelationBySelfUserID:uid toPeerUserID:[NSString stringWithFormat:@"%d",userPost.cd_ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:[self getNavigationController].view animated:YES];
            _focusState.hidden = YES;
            [self showHUDDoneWithText:@"UnFollowed"];
            if(self.cancelFocus) {
                if(userPost.friend_type == UserFriendTypeFriend) {
                    userPost.friend_type = UserFriendTypeFollower;
                } else {
                    userPost.friend_type = UserFriendTypeNone;
                }
                self.cancelFocus(userPost);
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:[self getNavigationController].view animated:YES];
            [self showNetErrHUD];
        }];
    }
}

/**
 *  显示正在转动的HUD
 */
- (void) showHUDWithText : (NSString *) text {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[self getNavigationController].view];
    [[self getNavigationController].view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = text;
    [HUD setCenter:[self getNavigationController].view.center];
    [HUD setUserInteractionEnabled:YES];
    HUD.yOffset = CGRectGetMinY([self getNavigationController].view.frame);
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

/**
 *  显示已关注的HUD
 */
- (void) showHUDDoneWithText : (NSString *) text {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[self getNavigationController].view];
    [[self getNavigationController].view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_right"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD setCenter:[self getNavigationController].view.center];
    [HUD setUserInteractionEnabled:YES];
    HUD.yOffset = CGRectGetMinY([self getNavigationController].view.frame);
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

/**
 *  显示网络异常HUD
 */
- (void) showNetErrHUD {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[self getNavigationController].view];
    [[self getNavigationController].view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = BAD_NETWORK;
    [HUD setCenter:[self getNavigationController].view.center];
    [HUD setUserInteractionEnabled:YES];
    HUD.yOffset = CGRectGetMinY([self getNavigationController].view.frame);
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

/**
 *  获取当前view所在viewcontroller的navigationcontroller
 *
 *  @return 
 */
- (UINavigationController *) getNavigationController {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UITabBarController *tabController = (UITabBarController *)delegate.window.rootViewController;
    UINavigationController *navController = tabController.viewControllers[0];
    return navController;
}

- (IBAction)addGood:(id)sender {
    NSInteger distance = 8;
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_goodImageView.frame) + distance, CGRectGetHeight(_goodImageView.frame) + distance)];
    anim.springBounciness = 20;
    anim.completionBlock = ^(POPAnimation *anim,BOOL finished) {
        if(finished) {
            POPSpringAnimation *animSmaller = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
            animSmaller.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_goodImageView.frame) - distance, CGRectGetHeight(_goodImageView.frame) - distance)];
            animSmaller.springBounciness = 20;
            animSmaller.removedOnCompletion = YES;
            [_goodImageView.layer pop_addAnimation:animSmaller forKey:@"size_smaller"];
            
            NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:uid forKey:@"pii_ci_id"];
            [params setObject:[NSString stringWithFormat:@"%d",userPost.cd_id] forKey:@"pii_source_id"];
            [params setObject:@"1" forKey:@"pii_source_type"];
            //点赞或取消点赞
            if(userPost.pii_is_praise == 0) {
                [HttpManager userPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
                userPost.cd_sum_pii_count ++;
                userPost.pii_is_praise = 1;
            } else {
				[HttpManager userCancelPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
                userPost.cd_sum_pii_count --;
                userPost.pii_is_praise = 0;
            }
            _goodNum.text = [NSString stringWithFormat:@"%d",userPost.cd_sum_pii_count];
        }
    };
    anim.removedOnCompletion = YES;
    [_goodImageView.layer pop_addAnimation:anim forKey:@"size_bigger"];
    NSString *likeImageName = (userPost.pii_is_praise == 0) ? @"common_icon_liked" : @"common_icon_like";
    _goodImageView.image = [UIImage imageNamed:likeImageName];
}

- (IBAction)addComment:(id)sender {
    if(self.viewDynamicInfo) {
        self.viewDynamicInfo(userPost);
    }
}

- (IBAction)delete:(id)sender {
    [self showAlert];
}

- (void)showAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:DELETE_COMMENT_CONFIRM_TEXT delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        if (self.deletePost) {
            self.deletePost(userPost, currentIndexPath);
        }
	}
}

#pragma mark - griview datasource
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView {
    return userPost.pictures.count;
}
- (UIView *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index {
    UIButton *cell = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _picWidth, _picHeight)];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *placeHolder = [UIImage imageNamed:@"img_is_loading"];
    Picture *picture = userPost.pictures[index];
    [_sdWebImageManager downloadImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture.picture_thumbnail_network_url]]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if(image && finished && !error) {
                                [cell setImage:image forState:UIControlStateNormal];
                            } else {
                                [cell setImage:placeHolder forState:UIControlStateNormal];
                            }
                        }];
    return cell;
}

#pragma mark - gridview delegate
- (void)gridView:(MMGridView *)gridView didSelectCell:(UIView *)cell atIndex:(NSUInteger)index {
    [self showPhotoBrowerAtIndex:index];
}

#pragma mark - 浏览图片gallery
- (void) showPhotoBrowerAtIndex : (NSInteger) index {
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //设置浏览图片的navigationbar为蓝色
    _photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    _photoBrowser.displayActionButton = NO;
    _photoBrowser.enableGrid = NO;
    [_photoBrowser setCurrentPhotoIndex:index];
    // Manipulate
    [_photoBrowser showNextPhotoAnimated:YES];
    [_photoBrowser showPreviousPhotoAnimated:YES];
    // Present
    [_navigationController pushViewController:_photoBrowser animated:YES];
}

#pragma mark - mwphotobrowser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return userPost.pictures.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < userPost.pictures.count) {
        Picture *picture = userPost.pictures[index];
        NSString *photoUrl = picture. picture_original_network_url;
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:photoUrl]]];
        return photo;
    }
    
    return nil;
}

@end
