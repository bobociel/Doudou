//
//  MCommentCell.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MCommentCell.h"
#import "TPFloatRatingView.h"
#import "MMGridView.h"
#import "MerchantComment.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "MWPhotoBrowser.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MImagesViewController.h"

@interface MCommentCell () <MMGridViewDataSource, MMGridViewDelegate, MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNicknameLabel;
@property (weak, nonatomic) IBOutlet TPFloatRatingView *userRateView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet MMGridView *imagesGridView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewWidthConstraint;

@end

static const NSInteger PIC_MARGIN = 6;

@implementation MCommentCell {
	MerchantComment *mComment;
//	SDWebImageManager *sdWebImageManager;
//	NSInteger picWidth;
//	NSInteger picHeight;
	NSInteger picSize;
	MWPhotoBrowser *photoBrowser;
}

- (void)awakeFromNib {
	// Initialization code
	[super awakeFromNib];
	self.imagesGridView.delegate = self;
	self.imagesGridView.dataSource = self;
//	sdWebImageManager = [SDWebImageManager sharedManager];
}

- (void)configureCellWithMerchantComment:(MerchantComment *)comment commentContentType:(NSInteger)commentContentType {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	mComment = comment;
	
	if(mComment.pictures.count != 0) {
		for(UIView *subView in self.imagesGridView.subviews) {
			subView.hidden = NO;
		}
		
		// 计算图片的大小
		picSize = (SCREEN_WIDTH - CGRectGetMinX(self.imagesGridView.frame) - 10) / 4;
		
		self.imagesGridView.numberOfRows = 1;
		NSInteger column = [self columnForGridView];
		self.imagesGridView.numberOfColumns = column;
		self.imagesGridView.cellMargin = PIC_MARGIN;
//		self.gridViewWidthConstraint.constant = picSize * column + (column - 1) * PIC_MARGIN * 2;
		self.gridViewHeightConstraint.constant = picSize;
		[self.imagesGridView reloadData];
	} else {
		for(UIView *subView in self.imagesGridView.subviews) {
			subView.hidden = YES;
		}
		
//		_gridViewWidthConstraint.constant = 0.0;
		_gridViewHeightConstraint.constant = 0.0;
	}
	self.gridViewWidthConstraint.constant = SCREEN_WIDTH - CGRectGetMinX(self.imagesGridView.frame) - 10;
	
	if (IsStringEmpty(mComment.ci_nikename)) {
		self.userNicknameLabel.text = [NSString stringWithFormat:@"nihao_%ld", mComment.ci_id];
	} else {
		self.userNicknameLabel.text = mComment.ci_nikename;
	}
	
	self.commentContentLabel.numberOfLines = commentContentType == MCommentContentTypeSummary ? 2 : 0;
	
	self.commentContentLabel.text = mComment.cmi_info;
	self.timeLabel.text = [BaseFunction dynamicDateFormat:mComment.cmi_date];
	
	self.userRateView.emptySelectedImage = [UIImage imageNamed:@"star_normal"];
	self.userRateView.fullSelectedImage = [UIImage imageNamed:@"star_highlight"];
	self.userRateView.contentMode = UIViewContentModeScaleAspectFit;
	self.userRateView.minImageSize = CGSizeMake(14, 14);
	
	MerchantsScore *merchantsScore = mComment.merchantsScore;
	
	self.userRateView.rating = merchantsScore.mhs_score / 2.0;
	self.userRateView.halfRatings = YES;
	
	NSString *iconURLString = mComment.ci_header_img;
	if (IsStringEmpty(iconURLString)) {
		if (mComment.ci_sex == UserSexTypeFemale) {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_female"];
		} else {
			self.userIconImageView.image = [UIImage imageNamed:@"default_icon_male"];
		}
	} else {
		[self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (error) {
				self.userIconImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
			}
		}];
	}
	
	//给用户头像添加点击事件
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserIcon:)];
	recognizer.numberOfTapsRequired = 1;
	[self.userIconImageView addGestureRecognizer:recognizer];
}

/**
 *  用户头像点击事件
 *
 *  @param recognizer
 */
- (void)tapUserIcon:(UITapGestureRecognizer *)recognizer {
	if(self.clickedUserIcon) {
		self.clickedUserIcon(mComment);
	}
}

- (NSInteger)columnForGridView {
	if (mComment.pictures.count <= 4) {
		return mComment.pictures.count;
	} else {
		return 4;
	}
}

#pragma mark - griview datasource
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView {
	return [self columnForGridView];
}

- (UIView *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index {
	if (mComment.pictures.count > 4 && index == 3) {// 显示 Total
		UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, picSize, picSize)];
		cell.backgroundColor = RootBackgroundColor;
		cell.textAlignment = NSTextAlignmentCenter;
		cell.text = [NSString stringWithFormat:@"Max\n%ld", mComment.pictures.count];
		cell.textColor = Color9E9E9E;
		cell.font = FontNeveLightWithSize(16);
		cell.numberOfLines = 0;
		
		return cell;
	} else {
		UIImageView *cell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, picSize, picSize)];
		cell.contentMode = UIViewContentModeScaleAspectFill;
		cell.clipsToBounds = YES;
		Picture *picture = mComment.pictures[index];
		[cell sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture.picture_thumbnail_network_url]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (error) {
				cell.image = [UIImage imageNamed:@"img_is_load_failed"];
			}
		}];
		
		return cell;
	}
}

#pragma mark - Private

- (void)openViewController:(UIViewController *)viewController {
	AppDelegate *appDelegate =  [[UIApplication sharedApplication] delegate];
	UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
	UINavigationController *listingNav = tabBarController.viewControllers[2];
	[listingNav pushViewController:viewController animated:YES];
}

#pragma mark - gridview delegate

- (void)gridView:(MMGridView *)gridView didSelectCell:(UIView *)cell atIndex:(NSUInteger)index {
	if (mComment.pictures.count > 4 && index == 3) {// 多余4张图片，并且点击的是"Total"
		MImagesViewController *imagesViewController = [[MImagesViewController alloc] init];
		imagesViewController.pictures = mComment.pictures;
		[self openViewController:imagesViewController];
	} else {
		[self showPhotoBrowerAtIndex:index];
	}
}

#pragma mark - 浏览图片gallery

- (void)showPhotoBrowerAtIndex:(NSInteger)index {
	photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	//设置浏览图片的navigationbar为蓝色
	photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
	[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
	photoBrowser.displayActionButton = NO;
	photoBrowser.enableGrid = NO;
	[photoBrowser setCurrentPhotoIndex:index];
	[photoBrowser setCurrentPhotoIndex:index];
	// Manipulate
	[photoBrowser showNextPhotoAnimated:YES];
	[photoBrowser showPreviousPhotoAnimated:YES];
	// Present
	[self openViewController:photoBrowser];
}

#pragma mark - mwphotobrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return mComment.pictures.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index < mComment.pictures.count) {
		Picture *picture = mComment.pictures[index];
		NSString *photoUrl = picture. picture_original_network_url;
		MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:photoUrl]]];
		return photo;
	}
	
	return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
