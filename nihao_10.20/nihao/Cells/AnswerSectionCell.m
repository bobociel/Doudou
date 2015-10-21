//
//  AnswerSectionCell.m
//  nihao
//
//  Created by HelloWorld on 7/16/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AnswerSectionCell.h"
#import "Constants.h"

@interface AnswerSectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation AnswerSectionCell

- (void)configureCellWithText:(NSString *)text {
	self.contentLabel.text = text;
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (self.contentView.subviews.count <= 1) {
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
		line.backgroundColor = SeparatorColor;
		[self.contentView addSubview:line];
	}
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
