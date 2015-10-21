//
//  ListingCategoryCell.m
//  nihao
//
//  Created by HelloWorld on 5/27/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ListingCategoryCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ListingCategoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation ListingCategoryCell

- (void)initCellWithCategoryImagePath:(NSString *)imagePath categoryName:(NSString *)categoryName {
    if (imagePath) {
        NSURL *imageURL = [[NSURL alloc] initWithString:[imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.categoryImageView sd_setImageWithURL:imageURL];
        self.categoryLabel.text = categoryName;
    } else{
        self.categoryImageView.image =[UIImage imageNamed:@"compose_add merchant.png"];
        self.categoryLabel.text = categoryName;
    }
    //    self.categoryImageView.image = [UIImage imageNamed:imagePath];
}

- (void)awakeFromNib {
    // Initialization code
}

@end