//
//  MeTableViewCell.h
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeTableViewCell : UITableViewCell

- (void)configureCellWithIconName:(NSString *)iconName andLabelText:(NSString *)text hasIcon:(BOOL)hasIcon hasRedPoint : (BOOL) hasRedPoint;

@end
