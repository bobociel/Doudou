//
//  MHeaderCell.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MHeaderCell.h"
#import "TPFloatRatingView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Merchant.h"

@interface MHeaderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mPosterImageView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet TPFloatRatingView *mRateView;
@property (weak, nonatomic) IBOutlet UILabel *mAVGPriceLabel;

@end

@implementation MHeaderCell

- (void)configureCellWithMerchantInfo:(Merchant *)merchant {
    NSURL *imageURL = [NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:merchant.mhi_cover_img]];
    [self.mPosterImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            self.mPosterImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
        }
    }];

    self.mNameLabel.text = merchant.mhi_name;
    self.mRateView.emptySelectedImage = [UIImage imageNamed:@"star_normal"];
    self.mRateView.fullSelectedImage = [UIImage imageNamed:@"star_highlight"];
    self.mRateView.contentMode = UIViewContentModeScaleAspectFit;
    //    self.scoreView.maxRating = 5;
    //    self.scoreView.minRating = 0;
    self.mRateView.minImageSize = CGSizeMake(14, 14);
    self.mRateView.rating = merchant.mhs_score / 2.0;
    //    self.scoreView.editable = NO;
    self.mRateView.halfRatings = YES;
    //    self.scoreView.floatRatings = NO;
    self.mAVGPriceLabel.text = [NSString stringWithFormat:@"%ld", merchant.mhi_avg_money];
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
