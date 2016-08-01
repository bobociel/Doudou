//
//  WTDetailCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTImageDetailCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#define kThumb600 @"?imageView2/1/w/600/h/600"
@implementation WTImageDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCardImage:(WTWeddingCardImage *)cardImage
{
	_cardImage = cardImage;
	NSString *URLStr = [NSString stringWithFormat:@"%@%@",_cardImage.path,kThumb600];
	[_detailImageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:URLStr]
										  placeholderImage:nil
												   options:SDWebImageRetryFailed
												  progress:nil
												 completed:nil
									  ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
									ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												  Diameter:50];
}

+ (CGFloat)cellHeight:(WTWeddingCardImage *)cardImage
{
	return cardImage.h / cardImage.w * screenWidth ;
}

@end

@implementation UITableView (WTImageDetailCell)

- (WTImageDetailCell *)WTImageDetailCell
{
	static NSString *CellIdentifier = @"WTImageDetailCell";

	WTImageDetailCell *cell = (WTImageDetailCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTImageDetailCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
	}
	return cell;
}

@end
