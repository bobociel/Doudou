//
//  PostDetailHeaderView.m
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PostDetailHeaderView.h"
#import "UserPost.h"
#import "BaseFunction.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PicCell.h"
#import <pop/POP.h>
#import "AppConfigure.h"
#import "HttpManager.h"
#import "UserInfoViewController.h"
#import "MMGridView.h"
#import "MWPhotoBrowser.h"
#import "AppDelegate.h"

@interface PostDetailHeaderView () <MMGridViewDataSource, MMGridViewDelegate, MWPhotoBrowserDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postContentLabel;
@property (weak, nonatomic) IBOutlet MMGridView *gridView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewWidthConstraint;

@property (nonatomic, assign) CGFloat itemWidth;

@end

static const NSInteger PIC_MARGIN = 1.5;

@implementation PostDetailHeaderView {
	UserPost *currentPost;
	NSInteger _picWidth;
	NSInteger _picHeight;
	MWPhotoBrowser *_photoBrowser;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = (PostDetailHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"PostDetailHeaderView" owner:self options:nil][0];
		self.frame = frame;
		_gridView.delegate = self;
		_gridView.dataSource = self;
	}
	
	return self;
}

- (void)configureHeaderViewWithPostInfo:(UserPost *)post {
	currentPost = post;
	
	if(currentPost.pictures.count != 0) {
		//计算图片的大小
		//根据数量的不同设置图片集控件的高和宽
		for(UIView *subView in _gridView.subviews) {
			subView.hidden = NO;
		}
		
		NSUInteger row;
		NSUInteger column;
		if(currentPost.pictures.count == 4) {
			column = 2;
			row = 2;
			_picWidth = (SCREEN_WIDTH - CGRectGetMinX(_gridView.frame) - 12) / 3;
			_picHeight = _picWidth;
		} else if(currentPost.pictures.count == 1) {
			column = 1;
			row = 1;
			Picture *picture = currentPost.pictures[0];
			_picWidth = picture.picture_thumbnail_width;
			_picHeight = picture.picture_thumbnail_height;
			
			//对缩略图的长和宽进行放缩处理
			_picWidth = _picWidth * 3 / 4;
			_picHeight = _picHeight * 3 / 4;
		} else {
			column = (currentPost.pictures.count / 3 > 0) ? 3 : currentPost.pictures.count % 3;
			row = (currentPost.pictures.count % 3 == 0) ? currentPost.pictures.count / 3 : (currentPost.pictures.count / 3 + 1);
			_picWidth = (SCREEN_WIDTH - CGRectGetMinX(_gridView.frame) - 12) / 3;
			_picHeight = _picWidth;
		}
		_gridView.numberOfRows = row;
		_gridView.numberOfColumns = column;
		_gridView.cellMargin = PIC_MARGIN;
		[_gridView reloadData];
		_gridViewWidthConstraint.constant = _picWidth * column + (column - 1) * PIC_MARGIN;
		_gridViewHeightConstraint.constant = _picHeight * row + (row - 1) * PIC_MARGIN;
	} else {
		for(UIView *subView in _gridView.subviews) {
			subView.hidden = YES;
		}
		_gridViewWidthConstraint.constant = SCREEN_WIDTH - 90;
		_gridViewHeightConstraint.constant = 0;
	}
	
	NSString *iconURLString = post.ci_header_img;
	if (IsStringEmpty(iconURLString)) {
		if (post.ci_sex == UserSexTypeFemale) {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_female"];
		} else {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_male"];
		}
	} else {
		[self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (!error) {
				self.userIconImageView.image = image;
			} else {
				self.userIconImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
				NSLog(@"imageURL = %@", imageURL);
			}
		}];
	}
    
    //给用户头像添加点击事件
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUserInfo:)];
    recognizer.numberOfTapsRequired = 1;
    self.userIconImageView.userInteractionEnabled = YES;
    [self.userIconImageView addGestureRecognizer:recognizer];
	
	if (IsStringEmpty(post.ci_nikename)) {
		self.userNameLabel.text = [NSString stringWithFormat:@"user_%d", post.cd_ci_id];
	} else {
		self.userNameLabel.text = post.ci_nikename;
	}
	self.postDateLabel.text = [BaseFunction dynamicDateFormat:post.cd_date];
	self.postContentLabel.text = post.cd_info;
	self.likeCountLabel.text = [NSString stringWithFormat:@"%d", post.cd_sum_pii_count];
	self.commentCountLabel.text = [NSString stringWithFormat:@"%d", post.cd_sum_cmi_count];
	
//	self.followBtn.hidden = (post.friend_type == 2 || post.friend_type == 4);
	[self configureFollowButton];
	
	NSString *likeImageName = (currentPost.pii_is_praise == 0) ? @"common_icon_like" : @"common_icon_liked";
	self.likeImageView.image = [UIImage imageNamed:likeImageName];
	
	if (post.cd_ci_id != ([[AppConfigure objectForKey:LOGINED_USER_ID] intValue])) {
		self.deleteBtn.hidden = YES;
	} else {
		self.followBtn.hidden = YES;
	}
}

- (void)configureFollowButton {
	switch (currentPost.friend_type) {
		case UserFriendTypeNone:
		case UserFriendTypeFollower:
			[self.followBtn setImage:[UIImage imageNamed:@"icon_follow"] forState:UIControlStateNormal];
			break;
		case UserFriendTypeFriend:
			[self.followBtn setImage:[UIImage imageNamed:@"icon_followed_each_other"] forState:UIControlStateNormal];
			break;
		case UserFriendTypeFollowed:
			[self.followBtn setImage:[UIImage imageNamed:@"icon_followed"] forState:UIControlStateNormal];
			break;
	}
}

#pragma mark - click events
- (IBAction)likeBtnClick:(id)sender {
	NSInteger distance = 8;
	POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
	anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.likeImageView.frame) + distance, CGRectGetHeight(self.likeImageView.frame) + distance)];
	anim.springBounciness = 20;
	anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
		if(finished) {
			POPSpringAnimation *animSmaller = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
			animSmaller.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.likeImageView.frame) - distance, CGRectGetHeight(self.likeImageView.frame) - distance)];
			animSmaller.springBounciness = 20;
			animSmaller.removedOnCompletion = YES;
			[self.likeImageView.layer pop_addAnimation:animSmaller forKey:@"size_smaller"];
			
			NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			[params setObject:uid forKey:@"pii_ci_id"];
			[params setObject:[NSString stringWithFormat:@"%d", currentPost.cd_id] forKey:@"pii_source_id"];
			[params setObject:@"1" forKey:@"pii_source_type"];
			//点赞或取消点赞
			if(currentPost.pii_is_praise == 0) {
				[HttpManager userPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
				currentPost.cd_sum_pii_count++;
				currentPost.pii_is_praise = 1;
			} else {
				[HttpManager userCancelPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
				currentPost.cd_sum_pii_count--;
				currentPost.pii_is_praise = 0;
			}
			self.likeCountLabel.text = [NSString stringWithFormat:@"%d", currentPost.cd_sum_pii_count];
		}
	};
	anim.removedOnCompletion = YES;
	[self.likeImageView.layer pop_addAnimation:anim forKey:@"size_bigger"];
	NSString *likeImageName = (currentPost.pii_is_praise == 0) ? @"common_icon_liked" : @"common_icon_like";
	self.likeImageView.image = [UIImage imageNamed:likeImageName];
}

// 关注该用户
- (IBAction)followUser:(id)sender {
	if (self.followUser) {
		self.followUser();
	}
}

// 删除这条 Post
- (IBAction)deletePost:(id)sender {
	[self showAlert];
}

// 显示删除 Post 确认对话框
- (void)showAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:DELETE_COMMENT_CONFIRM_TEXT delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//	NSLog(@"buttonIndex = %ld", buttonIndex);
	if (buttonIndex == 1) {
		if (self.deletePost) {
			self.deletePost();
		}
	}
}

#pragma mark - griview datasource
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView {
	return currentPost.pictures.count;
}
- (UIView *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index {
	UIButton *cell = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _picWidth, _picHeight)];
	cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
	UIImage *placeHolder = [UIImage imageNamed:@"img_is_loading"];
	Picture *picture = currentPost.pictures[index];
	[SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture.picture_thumbnail_network_url]]
														options:0
													   progress:^(NSInteger receivedSize, NSInteger expectedSize)
	 {
   
	 }
													  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
	 {
		 
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
	[_photoBrowser setCurrentPhotoIndex:index];
	// Manipulate
	[_photoBrowser showNextPhotoAnimated:YES];
	[_photoBrowser showPreviousPhotoAnimated:YES];
	// Present
	AppDelegate *appDelegate =  [[UIApplication sharedApplication] delegate];
	UITabBarController *tabController = (UITabBarController *)appDelegate.window.rootViewController;
	UINavigationController *nav = tabController.viewControllers[0];
	[nav pushViewController:_photoBrowser animated:YES];
}

#pragma mark - mwphotobrowser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return currentPost.pictures.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index < currentPost.pictures.count) {
		Picture *picture = currentPost.pictures[index];
		NSString *photoUrl = picture.picture_original_network_url;
		MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:photoUrl]]];
		return photo;
	}
	
	return nil;
}

// 刷新 HeaderView
- (void)refreshHeaderViewWithFriendType:(NSInteger)friendType {
	self.commentCountLabel.text = [NSString stringWithFormat:@"%d", currentPost.cd_sum_cmi_count];
	currentPost.friend_type = friendType;
	[self configureFollowButton];
}

- (void) viewUserInfo : (UITapGestureRecognizer *) recognizer {
    if(self.viewUserInfo) {
        self.viewUserInfo();
    }
}

@end
