//
//  MCommonCell.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MCommonCell.h"

@interface MCommonCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MCommonCell

- (void)configureCellWithIconName:(NSString *)iconName content:(NSString *)content {
	self.iconImageView.image = [UIImage imageNamed:iconName];
	self.contentLabel.text = content;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
