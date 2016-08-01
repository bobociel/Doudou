//
//  CommDatePickView.h
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareButton.h"
typedef NS_ENUM(NSUInteger,PickerViewStyle) {
	PickerViewStyleDefault,
	PickerViewStyleRedSure,
	PickerViewStyleRedSureCate
};

typedef NS_ENUM(NSUInteger,PickerViewType) {
	PickerViewTypeDefault,
	PickerViewTypeDate,
	PickerViewTypeDateAndTime,
	PickerViewTypeTime,
	PickerViewTypeCate
};

@protocol CommDatePickViewDelegate <NSObject>
- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type;
@end

@interface CommDatePickView : UIView
@property (nonatomic,strong) UIDatePicker *dataPickView;
@property (nonatomic,copy) NSString *resultString;
@property (nonatomic,weak) id <CommDatePickViewDelegate> delagate;

+ (instancetype)viewWithStyle:(PickerViewStyle)style;
- (void)setCurrentTimeWith:(unsigned long long )timestamp;
- (void)showWithType:(PickerViewType)tag;
- (void)hide:(BOOL)animation callback:(void(^)())callback;
@end
