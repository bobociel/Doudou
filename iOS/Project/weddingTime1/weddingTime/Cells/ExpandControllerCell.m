//
//  ExpandControllerCell.m
//  weddingTime
//
//  Created by 默默 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ExpandControllerCell.h"
@implementation UITableView(ExpandControllerCell)
-(ExpandControllerCell*)ExpandControllerCell{
    static NSString *CellIdentifier = @"ExpandControllerCell";
    ExpandControllerCell *cell = (ExpandControllerCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (ExpandControllerCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
        
    }

    cell.selectedBackgroundView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
    cell.selectedBackgroundView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
    return cell;
}

@end
@implementation ExpandControllerCell

- (void)awakeFromNib {
    // Initialization code
    self.subTtleLabel.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)getHeightWithInfo:(id)info
{
    return CellHeight;
}

-(void)setInfo:(id)info
{
    NSDictionary*infoDic=info;
    self.mainTitleLabel.text=[LWUtil getString: infoDic[@"title"]  andDefaultStr:@""];
    self.subTtleLabel.text=[LWUtil getString:infoDic[@"subTitle"] andDefaultStr:@""];
    self.logoImageView.image=[UIImage imageNamed:[LWUtil getString:infoDic[@"image"] andDefaultStr:@""]];
}

@end

