//
//  OrderDetailTC.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/10.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailTC : UITableViewCell

- (void)setInfo:(id)info index:(NSIndexPath *)index;
- (void)setPromptLabelText:(NSString *)text;
- (void)setValueLabelTextColor:(UIColor *)color;
- (void)setvaluelabeltext:(NSString *)text;
@end

@interface UITableView (OrderDetailTC)

- (OrderDetailTC *)orderDetailTC;
@end