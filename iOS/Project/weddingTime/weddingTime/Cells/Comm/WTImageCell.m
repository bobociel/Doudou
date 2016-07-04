//
//  WTImageCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTImageCell.h"
#import "CommAnimationForControl.h"
#import "UIView+YYAdd.h"
#define kCellWidth ((screenWidth - 15) / 4.0)
#define kCellHeight ((screenWidth - 15) / 4.0)
@interface WTImageCell ()

@end

@implementation WTImageCell

- (void)awakeFromNib {
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.clipsToBounds = YES;
}

- (void)setAsset:(ALAsset *)asset
{
	_asset = asset;

	self.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
	if([[_asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
	{
		self.markImageView.hidden = YES;
		[self.dimingView.layer addSublayer:[self gradientLayer]];
		self.timeLabel.text = [WTImageCell getTimeStringOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
	}
	else if([[_asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
	{
		self.dimingView.hidden = YES;
		self.iconVideoView.hidden = YES;
		self.timeView.hidden = YES;
	}
}

- (IBAction)onSelected:(UIButton *)sender
{
	self.markImageView.highlighted = !self.markImageView.highlighted;
	if([self.delegate respondsToSelector:@selector(WTImageCell:didClickWithAsset:)])
	{
		[self.delegate WTImageCell:self didClickWithAsset:self.asset];
		[self.markImageView.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScale"];
	}
}

- (CALayer *)gradientLayer
{
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	CGRect frame = CGRectMake(0, 0, kCellWidth, 20.0);
	gradientLayer.frame = frame;
	gradientLayer.colors = @[(id)[[[UIColor blackColor] colorWithAlphaComponent:0] CGColor] ,
							 (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor],
							 (id)[[[UIColor blackColor] colorWithAlphaComponent:0.3] CGColor],
							 (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor],
							 (id)[[[UIColor blackColor] colorWithAlphaComponent:0.7] CGColor],
							 (id)[[[UIColor blackColor] colorWithAlphaComponent:1.0] CGColor],];
	return gradientLayer;
}

+ (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:uFlags fromDate:dateRef toDate:dateNow options:0];

    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}


@end
