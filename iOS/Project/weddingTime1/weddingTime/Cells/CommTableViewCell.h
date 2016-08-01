//
//  CommTableViewCell.h
//  lovewith
//
//  Created by imqiuhang on 15/4/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommTableViewCell : UITableViewCell

//请在子类重写以下方法
- (void)setInfo:(id)info;
- (CGFloat)getHeightWithInfo:(id)info;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;



@end
