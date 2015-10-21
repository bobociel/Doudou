//
//  MLocationCell.h
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Merchant;

@protocol MLocationCellDelegate <NSObject>

- (void)shouldCallMerchant;

@end

@interface MLocationCell : UITableViewCell

- (void)configureCellWithMerchantInfo:(Merchant *)merchant;

@property (nonatomic, assign) id <MLocationCellDelegate> delegate;

@end
