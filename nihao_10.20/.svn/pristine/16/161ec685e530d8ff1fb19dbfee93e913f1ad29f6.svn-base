//
//  MLocationCell.m
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MLocationCell.h"
#import "Merchant.h"

@interface MLocationCell ()

@property (weak, nonatomic) IBOutlet UILabel *locationENLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationCNLabel;

@end

@implementation MLocationCell

- (void)configureCellWithMerchantInfo:(Merchant *)merchant {
	self.locationENLabel.text = merchant.mhi_address_en;
    if(merchant.mhi_district) {
        self.locationCNLabel.text = [merchant.mhi_district stringByAppendingString:merchant.mhi_address_cn];
    } else {
        self.locationCNLabel.text = merchant.mhi_address_cn;
    }
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)callMerchant:(id)sender {
	if ([self.delegate respondsToSelector:@selector(shouldCallMerchant)]) {
		[self.delegate shouldCallMerchant];
	}
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
