//
//  NewsCell.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "NewsCell.h"
#import "News.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import <pop/POP.h>
#import "AppConfigure.h"
#import "HttpManager.h"

@interface NewsCell ()

@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsIntroLabel;
@property (weak, nonatomic) IBOutlet UIImageView *newsImg0;
@property (weak, nonatomic) IBOutlet UIImageView *newsImg1;
@property (weak, nonatomic) IBOutlet UIImageView *newsImg2;
@property (weak, nonatomic) IBOutlet UILabel *newsTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsCommentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsLikeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *imagesContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewToNewsIntroLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewToNewsImagesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsImagesViewToNewsIntrolLabel;

@end

@implementation NewsCell {
	News *currentNews;
}

- (void)configureCellWithInfo:(News *)news forRowAtIndexPath:(NSIndexPath *)indexPath {
	currentNews = news;
    self.newsTitleLabel.text = news.ni_title;
    self.newsIntroLabel.text = news.ni_introduction;
    NSArray *newsImgs = news.pictures;
    if (newsImgs.count > 0) {
        [self hasImages];
        if (newsImgs.count >= 1) {
            self.newsImg0.hidden = NO;
            NSDictionary *pic0 = newsImgs[0];
            NSString *urlString = pic0[@"picture_thumbnail_network_url"];
            [self setImageView:self.newsImg0 withImageURLString:urlString];
            
            if (newsImgs.count >= 2) {
                self.newsImg1.hidden = NO;
                NSDictionary *pic1 = newsImgs[1];
                NSString *urlString = pic1[@"picture_thumbnail_network_url"];
                [self setImageView:self.newsImg1 withImageURLString:urlString];
                
                if (newsImgs.count >= 3) {
                    self.newsImg2.hidden = NO;
                    NSDictionary *pic2 = newsImgs[2];
                    NSString *urlString = pic2[@"picture_thumbnail_network_url"];
                    [self setImageView:self.newsImg2 withImageURLString:urlString];
                } else {
                    self.newsImg2.hidden = YES;
                }
            } else {
                self.newsImg1.hidden = YES;
                self.newsImg2.hidden = YES;
            }
        }
    } else {
        [self zeroImage];
    }
    
    self.newsTimeLabel.text = [BaseFunction dynamicDateFormat:news.ni_date];
    self.newsLikeCountLabel.text = [NSString stringWithFormat:@"%d", news.ni_sum_pii_count];
    self.newsCommentCountLabel.text = [NSString stringWithFormat:@"%d", news.ni_sum_cmi_count];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *imageViews = @[_newsImg0,_newsImg1,_newsImg2];
    for(NSInteger i = 0;i < imageViews.count;i++) {
        UIImageView *imageView = imageViews[i];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigPhoto:)];
        tapGesture.numberOfTapsRequired = 1;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tapGesture];
    }
	NSString *likeImageName = (currentNews.pii_is_praise == 0) ? @"common_icon_like" : @"common_icon_liked";
	self.likeImageView.image = [UIImage imageNamed:likeImageName];
}

- (void) showBigPhoto : (UITapGestureRecognizer *) sender {
    if(self.showBigPhoto) {
        self.showBigPhoto();
    }
}

- (void)setImageView:(UIImageView *)imageView withImageURLString:(NSString *)imageURLString {
    [imageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:imageURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            imageView.image = image;
        } else {
            imageView.image = [UIImage imageNamed:@"img_is_load_failed"];
            NSLog(@"imageURL = %@", imageURL);
        }
    }];
}

- (IBAction)likeThisNewsBtnClick:(id)sender {
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
			[params setObject:[NSString stringWithFormat:@"%d", currentNews.ni_id] forKey:@"pii_source_id"];
			[params setObject:@"2" forKey:@"pii_source_type"];
			//点赞或取消点赞
			if(currentNews.pii_is_praise == 0) {
				[HttpManager userPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
				currentNews.ni_sum_pii_count++;
				currentNews.pii_is_praise = 1;
			} else {
				[HttpManager userCancelPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
				currentNews.ni_sum_pii_count--;
				currentNews.pii_is_praise = 0;
			}
			self.newsLikeCountLabel.text = [NSString stringWithFormat:@"%d", currentNews.ni_sum_pii_count];
		}
	};
	anim.removedOnCompletion = YES;
	[self.likeImageView.layer pop_addAnimation:anim forKey:@"size_bigger"];
	NSString *likeImageName = (currentNews.pii_is_praise == 0) ? @"common_icon_liked" : @"common_icon_like";
	self.likeImageView.image = [UIImage imageNamed:likeImageName];
}

- (void)hasImages {
    self.imagesContainer.hidden = NO;
    self.bottomViewToNewsIntroLabel.priority = 750;
    if (self.bottomViewToNewsImagesView.priority != 999) {
        self.bottomViewToNewsImagesView.priority = 999;
    }
    if (self.newsImagesViewToNewsIntrolLabel.priority != 999) {
        self.newsImagesViewToNewsIntrolLabel.priority = 999;
    }
}

- (void)zeroImage {
    self.imagesContainer.hidden = YES;
    self.bottomViewToNewsImagesView.priority = 750;
    if (self.bottomViewToNewsIntroLabel.priority != 999) {
        self.bottomViewToNewsIntroLabel.priority = 999;
    }
    if (self.newsImagesViewToNewsIntrolLabel.priority == 999) {
        self.newsImagesViewToNewsIntrolLabel.priority = 750;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
