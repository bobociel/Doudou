//
//  MeTableViewCell.m
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MeTableViewCell.h"

@interface MeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelToView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelToImageView;
@property (weak, nonatomic) IBOutlet UIImageView *redPointImage;

@end

@implementation MeTableViewCell

- (void)configureCellWithIconName:(NSString *)iconName andLabelText:(NSString *)text hasIcon:(BOOL)hasIcon hasRedPoint:(BOOL)hasRedPoint{
	if (hasIcon) {
		self.iconImageView.hidden = NO;
		self.iconImageView.image = [UIImage imageNamed:iconName];
	} else {
		self.iconImageView.hidden = NO;
	}
    if(hasRedPoint) {
        self.redPointImage.hidden = NO;
    } else {
        self.redPointImage.hidden = YES;
    }
	self.label.text = text;
	[self setLayout:hasIcon];
}

- (void)setLayout:(BOOL)hasIcon {
	if (hasIcon) {
		self.labelToView.priority = 750;
		self.labelToImageView.priority = 999;
	} else {
		self.labelToView.priority = 999;
		self.labelToImageView.priority = 750;
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
