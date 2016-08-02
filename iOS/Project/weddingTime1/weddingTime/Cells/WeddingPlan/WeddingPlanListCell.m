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

- (void)awakeFromNib {
   // [self.lineView setAsLineView];
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:defaultLineColor];
    self.titleLable.textColor = titleLableColor;
    self.timeLable.textColor  = [WeddingTimeAppInfoManager instance].baseColor;

    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setInfo:(id)info {
//    int status = [[LWAssistUtil cellInfo:info[@"status"] andDefaultStr:@"1"] intValue];
//    self.statusChangeBtn.tag=status;
    [self resetStatusBtn];
    self.titleLable.text=[LWUtil getString:info[@"title"] andDefaultStr:@"没有事项名称"];
    int64_t timeSince  = [[LWUtil getString:info[@"close_time"] andDefaultStr: [NSString stringWithFormat:@"%lld", (int64_t)[[NSDate date] timeIntervalSince1970]]] intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSince];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    self.timeLable.text=dateStr;
}

- (void)resetStatusBtn {
//    [self.statusChangeBtn setImage:self.statusChangeBtn.tag==finishedStatus?[UIImage imageNamed :@"icon_wedding_finish"]:[UIImage imageNamed :@"icon_wedding_unfinish"] forState:UIControlStateNormal];
}

@end