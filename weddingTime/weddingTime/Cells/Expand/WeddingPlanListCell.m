//
//  WeddingPlanListCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanListCell.h"

@implementation UITableView(WeddingPlanListCell)

- (WeddingPlanListCell *)WeddingPlanListCell{
    
    static NSString *CellIdentifier = @"WeddingPlanListCell";
    
    WeddingPlanListCell * cell = (WeddingPlanListCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (WeddingPlanListCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end


@implementation WeddingPlanListCell
- (void)awakeFromNib
{
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:defaultLineColor];
    self.titleLable.textColor = titleLableColor;
    self.timeLable.textColor  = [WeddingTimeAppInfoManager instance].baseColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setMatter:(WTMatter *)matter
{
	_matter = matter;
	self.titleLable.text = [LWUtil getString:matter.title andDefaultStr:@"没有事项名称"];

	double timestamp = matter.close_time ? : [[NSDate date] timeIntervalSince1970];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy.MM.dd"];
	NSString * dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
	self.timeLable.text=dateStr;
}

@end
