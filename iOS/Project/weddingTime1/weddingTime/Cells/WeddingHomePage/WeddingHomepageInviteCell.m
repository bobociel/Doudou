//
//  WeddingHomepageInviteCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingHomepageInviteCell.h"
@implementation UITableView(WeddingHomepageInviteCell)

- (WeddingHomepageInviteCell *)WeddingHomepageInviteCell{
    
    static NSString *CellIdentifier = @"WeddingHomepageInviteCell";
    
    WeddingHomepageInviteCell * cell = (WeddingHomepageInviteCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (WeddingHomepageInviteCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end


@implementation WeddingHomepageInviteCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:rgba(221, 221, 221, 1)];
    self.titleLable.textColor=titleLableColor;
    self.subTitleLable.textColor = subTitleLableColor;
}

-(void)setInfo:(id)info {
    self.titleLable.attributedText=nil;
    self.titleLable.text=@"";
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ 人",[LWUtil getString:info[@"name"] andDefaultStr:@"宾客"],[LWUtil getString:info[@"part_num"] andDefaultStr:@"1"]]];
    
    NSRange titleRange =[attributedText.string rangeOfString:[LWUtil getString:info[@"part_num"] andDefaultStr:@"1"]];
    
    if (titleRange.location!=NSNotFound) {
        [attributedText addAttribute:NSForegroundColorAttributeName  value:[WeddingTimeAppInfoManager instance].baseColor range:titleRange];
        self.titleLable.attributedText=attributedText;
    }else {
        self.self.titleLable.text=attributedText.string;
    }
    
    self.subTitleLable.text = [LWUtil getString:info[@"content"] andDefaultStr:@""];

}

@end
















