//
//  SearchSliderBarCell.m
//  lovewith
//
//  Created by imqiuhang on 15/4/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "SearchSliderBarCell.h"
#import "NMRangeSlider.h"

@implementation UITableView(SearchSliderBarCell)

- (SearchSliderBarCell *)SearchSliderBarCell {
    
    static NSString *CellIdentifier = @"SearchSliderBarCell";
    SearchSliderBarCell *cell = (SearchSliderBarCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[SearchSliderBarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end


@implementation SearchSliderBarCell
{
    UILabel       *titleLable;
    UILabel       *subTitleLable;
    NMRangeSlider *slider;
    int curlVaule ;
    int currValue ;
    UIImageView *imageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageView.frame = CGRectMake(20, self.size.height - 0.3, screenWidth - 15, 0.3);
}
- (void)startWithStyle:(SearchSliderBarCellStyle)aStyle {
    
    self.searchStyle =aStyle;
    
    [self.contentView removeAllSubviews];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,self.height-0.5, self.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed :@"splitbg"]];
    [self.contentView addSubview:lineView];
    
    imageView = [[UIImageView alloc] init];
    [LWAssistUtil imageViewSetAsLineView:imageView color:[UIColor lightGrayColor]];
    [self.contentView addSubview:imageView];
    
    titleLable           = [[UILabel alloc] initWithFrame:CGRectMake(225 * Width_ato, 70 * Height_ato, 130 * Width_ato, 21 * Height_ato)];
    titleLable.font      = [WeddingTimeAppInfoManager fontWithSize:16];
    titleLable.textColor = rgba(102, 102, 102, 1);
    [self.contentView addSubview:titleLable];
    
    subTitleLable =[[UILabel alloc] initWithFrame:CGRectMake(91 * Width_ato, 69 * Height_ato, 130 * Width_ato, 22 * Height_ato)];
    subTitleLable.textAlignment = NSTextAlignmentRight;
    subTitleLable.font      = [WeddingTimeAppInfoManager fontWithSize:18];
    subTitleLable.textColor = [WeddingTimeAppInfoManager instance].baseColor;
    [self.contentView addSubview:subTitleLable];
    
    slider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(15 * Width_ato, 30 * Height_ato, screenWidth - 30 * Width_ato, 24 * Height_ato)];
    slider.tintColor=[WeddingTimeAppInfoManager instance].baseColor;

    [self performSelector:@selector(reset) withObject:nil afterDelay:0.3];

    
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

}
- (void)animad {
     curlVaule = slider.lowerValue;
     currValue =slider.upperValue;
    [slider setLowerValue:1 upperValue:2 animated:NO];
    [self performSelector:@selector(animadEvent) withObject:nil afterDelay:0.3];
}


- (void)setLower:(float)lower Upper:(float)upper
{
    [slider setLowerValue:lower upperValue:upper animated:NO];
}
- (void)animadEvent {
    //[slider setLowerValue:curlVaule upperValue:currValue animated:YES];

}

- (void)reset {
    [self addSubview:slider];
    if (self.searchStyle==SearchSliderBarCellStyleTable) {
        titleLable.text     = @"桌";
        slider.minimumValue = 1;
        slider.maximumValue = 100;
        slider.minimumRange = 1;
        [slider setUpperValue:100 animated:YES];
        [slider setLowerValue:1 animated:YES];
//        [slider setLowerValue:20 upperValue:50 animated:YES];
        subTitleLable.text  = @"1 - 100";
        
    }else {
        titleLable.text=@"元／桌起";
        slider.minimumValue = 1;
        slider.maximumValue = 100;
        slider.minimumRange = 1;
        [slider setLowerValue:1 upperValue:100 animated:YES];
        subTitleLable.text  = @"100-10000";
    }
    [self postDelegate];
}

- (void)postDelegate {
    int lValue = self.searchStyle ==SearchSliderBarCellStylePrice?(int)slider.lowerValue*100:(int)slider.lowerValue;
    int rValue =self.searchStyle ==SearchSliderBarCellStylePrice?(int)slider.upperValue*100:(int)slider.upperValue;
    if ([self.slideDelegate respondsToSelector:@selector(slideVauleDidChanged:andleftValue:adnRightValue:)]) {
        [self.slideDelegate slideVauleDidChanged:self.searchStyle andleftValue:lValue adnRightValue:rValue];
    }
}

- (void)sliderChanged:(NMRangeSlider *)sender {
    
    if (self.searchStyle==SearchSliderBarCellStyleTable) {
        subTitleLable.text=[NSString stringWithFormat:@"%i－%i",(int)sender.lowerValue<1?1:(int)sender.lowerValue,(int)sender.upperValue];
        
    }else {
        subTitleLable.text=[NSString stringWithFormat:@"%i－%i",(int)sender.lowerValue*100<100?100:(int)sender.lowerValue*100,(int)sender.upperValue*100];
    }
    [self postDelegate];
}

@end
