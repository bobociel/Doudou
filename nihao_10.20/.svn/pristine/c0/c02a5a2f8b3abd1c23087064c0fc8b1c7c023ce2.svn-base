//
//  AskCategoryCell.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskCategoryCell.h"
#import "AskCategory.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"

@interface AskCategoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryQuestionCountLabel;

@end

@implementation AskCategoryCell

- (void)initCellViewWithAskCategory:(AskCategory *)askCategory {
	NSString *iconURLString = askCategory.akc_img;
	[self.categoryImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if (!error) {
			self.categoryImageView.image = image;
		} else {
			self.categoryImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
		}
	}];
    self.categoryNameLabel.text = askCategory.akc_name;
	self.categoryQuestionCountLabel.text = [NSString stringWithFormat:@"%ld", askCategory.akc_aki_count];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
