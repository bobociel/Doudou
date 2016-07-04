//
//  InspirationViewCell.m
//  weddingTime
//
//  Created by 默默 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "InspirationViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
@implementation PSCollectionView(InspirationViewCell)

- (InspirationViewCell *)InspirationViewCell{
    
    static NSString *CellIdentifier = @"InspirationViewCell";

    InspirationViewCell *cell = (InspirationViewCell *)[self dequeueReusableView];
    if (nil == cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil][0];
    }
    
    cell.backgroundColor=[UIColor whiteColor];
    return cell;
}
@end


@implementation InspirationViewCell
{
    BOOL isFav;
    int listid;
}

- (void)awakeFromNib {
    self.backImage.layer.cornerRadius=5.f;
    self.backImage.clipsToBounds=YES;
    [self.doFav addTarget:self action:@selector(doFavEvent) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setInfo:(id)info {
    self.infos=info;

	self.backImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	[self.backImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!240",[LWUtil getString:info[@"cover"] andDefaultStr:@""]]]
								   placeholderImage:nil
											options:SDWebImageRetryFailed
										   progress:nil
										  completed:nil
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];

    isFav =[info[@"is_like"] boolValue];
    listid = [[LWUtil getString:info[@"cover_id"] andDefaultStr:@"0"] intValue];
    if ([self.delegate respondsToSelector:@selector(setBtn::)]) {
        [self.delegate setBtn:listid :self.doFav];
    }
    [self updateConstraints];
}

- (void)doFavEvent {
    if ([self.delegate respondsToSelector:@selector(doFav::)]) {
        [self.delegate doFav:listid :self.doFav];
    }
}

#define MARGIN 4.0
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    // Image
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    return height;
}
@end