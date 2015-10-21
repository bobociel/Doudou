//
//  MHeaderCell.h
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Merchant;

@interface MHeaderCell : UITableViewCell

- (void)configureCellWithMerchantInfo:(Merchant *)merchant;

@end
