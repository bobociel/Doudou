//
//  WTImageCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#define kVideoImageHeight 20.0
#define kCellWidth ((screenWidth - 15) / 4.0)
#define kCellHeight ((screenWidth - 15) / 4.0)
#import "WTImageCell.h"
#import "CommAnimationForControl.h"
@interface WTImageCell ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoIcon;
@property (nonatomic, strong) UIColor *videoTitleColor;
@property (nonatomic, strong) UIFont *videoTimeFont;
@end

@implementation WTImageCell

- (void)awakeFromNib {
    // Initialization code
    _videoTitleColor  = [UIColor whiteColor];
    _videoTimeFont    = [UIFont systemFontOfSize:12];
}

- (void)setAsset:(ALAsset *)asset
{
	_asset = asset;
	self.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
	if ([[_asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
	{
		self.markImageView.hidden = YES;
	}

	self.title = [WTImageCell getTimeStringOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    self.videoIcon  = [UIImage imageNamed:@"icon_asset_video"];
}

- (IBAction)onSelected:(UIButton *)sender {
	self.markImageView.highlighted = !self.markImageView.highlighted;
	if([self.delegate respondsToSelector:@selector(WTImageCell:didClickWithAsset:)])
	{
		[self.delegate WTImageCell:self didClickWithAsset:self.asset];
		[self.markImageView.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScale"];
	}
}


- (void)drawRect:(CGRect)rect
{
    // Video title
    if ([[_asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        // Create a gradient from transparent to black
        CGFloat colors [] =
        {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.8,
            0.0, 0.0, 0.0, 1.0
        };
        
        CGFloat locations [] = {0.0, 0.75, 1.0};
        
        CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGFloat height          = rect.size.height;
        CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - kVideoImageHeight);
        CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        
        NSDictionary *attributes = @{NSFontAttributeName:_videoTimeFont,NSForegroundColorAttributeName:_videoTitleColor};
        CGSize titleSize        = [self.title sizeWithAttributes:attributes];
        [self.title drawInRect:CGRectMake(rect.size.width - (NSInteger)titleSize.width - 2 , startPoint.y + (kVideoImageHeight - 12) / 2, kCellWidth, height) withAttributes:attributes];
        
        [_videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (kVideoImageHeight - _videoIcon.size.height) / 2)];
    }
}

+ (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *components = [calendar components:uFlags fromDate:dateRef toDate:dateNow options:0];
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
