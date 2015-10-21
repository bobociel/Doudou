//
//  AskCell.m
//  nihao
//
//  Created by HelloWorld on 7/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskCell.h"
#import "AskContent.h"
#import "BaseFunction.h"

@interface AskCell ()

@property (weak, nonatomic) IBOutlet UILabel *askTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *askAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *askTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *askCommentCountLabel;

@end

@implementation AskCell

- (void)initCellViewWithAskContent:(AskContent *)askContent {
	self.askTitleLabel.text = askContent.aki_title;
	self.askAuthorLabel.text = askContent.aki_source_nikename;
	self.askTimeLabel.text = [BaseFunction dynamicDateFormat:askContent.aki_date];
	self.askCommentCountLabel.text = [NSString stringWithFormat:@"%ld", askContent.aki_sum_cmi_count];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
