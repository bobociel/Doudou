//
//  LBPickerView.h
//  TestNotification
//
//  Created by wangxiaobo on 16/1/15.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPickerView : UIView
- (instancetype)initPickerViewWithInfo:(id)arrayOrPlistName andSelectedRows:(NSArray *)selectedRows;
- (instancetype)initDatePickerWithDate:(NSDate *)date andDateMode:(UIDatePickerMode)mode;

- (void)showOrHide;
@end
