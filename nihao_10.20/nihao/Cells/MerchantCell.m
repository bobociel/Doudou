//
//  MerchantCell.m
//  nihao
//
//  Created by HelloWorld on 5/29/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MerchantCell.h"
#import "TPFloatRatingView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Merchant.h"

@interface MerchantCell ()

@property (weak, nonatomic) IBOutlet UIImageView *merchantImageView;
@property (weak, nonatomic) IBOutlet UILabel *merchantNameLabel;
@property (weak, nonatomic) IBOutlet TPFloatRatingView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *personPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *districtLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locateIcon;

@end

@implementation MerchantCell

- (void)initCellWithMerchantData:(Merchant *)merchant {
    [self.merchantImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:merchant.mhi_header_img]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            self.merchantImageView.image = image;
        } else {
            self.merchantImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
      
        }
    }];
    self.merchantNameLabel.text = merchant.mhi_name;
    self.personPriceLabel.text = [NSString stringWithFormat:@"%ld", merchant.mhi_avg_money];
    self.districtLabel.text = merchant.mhc_name;
	double distance = [merchant.mhi_distance doubleValue];
    if (distance != 0.0) {
        self.distanceLabel.hidden = NO;
        self.distanceLabel.text = [BaseFunction convertDistanceToShortString:distance];
        self.locateIcon.hidden = NO;
    } else {
        self.distanceLabel.hidden = YES;
        self.locateIcon.hidden = YES;
    }
    //    self.scoreView.delegate = self;
    if (!self.scoreView.emptySelectedImage) {
        self.scoreView.emptySelectedImage = [UIImage imageNamed:@"star_normal"];
    }
    if (!self.scoreView.fullSelectedImage) {
        self.scoreView.fullSelectedImage = [UIImage imageNamed:@"star_highlight"];
    }
    self.scoreView.contentMode = UIViewContentModeScaleAspectFit;
    //    self.scoreView.maxRating = 5;
    //    self.scoreView.minRating = 0;
    self.scoreView.minImageSize = CGSizeMake(14, 14);
    self.scoreView.rating = merchant.mhs_score / 2.0;
    //    self.scoreView.editable = NO;
    self.scoreView.halfRatings = YES;
    //    self.scoreView.floatRatings = NO;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
