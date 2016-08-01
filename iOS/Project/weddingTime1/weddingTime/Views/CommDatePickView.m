//
//  CommDatePickView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommDatePickView.h"
#define CommDatePickViewTag 48237

@implementation CommDatePickView
{
    int showTag;
    UIView       *backgroundView;
    UIView       *contentView;
    UIButton *doneBtn;
    BOOL isDataAndTime;
    
}

- (instancetype)init {
    if (self==[super init]) {
        [self initView];
    }
    return self;
}

- (void)setAsDateAndTime {
    self.dataPickView.datePickerMode = UIDatePickerModeDateAndTime;
    isDataAndTime = YES;
}

- (void)initView {
    self.tag=CommDatePickViewTag;
    self.frame=KEY_WINDOW.bounds;
    
    backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0.f;
    [self addSubview:backgroundView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 250)];
    [self addSubview:contentView];
    contentView.top=self.height;
    contentView.backgroundColor=[UIColor whiteColor];
    
    doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    doneBtn.right=self.width-10;
    doneBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = defaultFont18;
    [contentView addSubview:doneBtn];
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.dataPickView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, doneBtn.bottom, self.width, 200)];
    self.dataPickView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:1*60*60];
    self.dataPickView.datePickerMode = UIDatePickerModeDate;
    [self.dataPickView setTimeZone:[NSTimeZone defaultTimeZone]];
    [contentView addSubview:self.dataPickView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    [backgroundView addGestureRecognizer:tap];
    
    
}

- (void)done {
    NSDate *date;
    if (isDataAndTime) {

        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponentsDate = [calendar components:unitFlags fromDate:self.dataPickView.date];
        date = [calendar dateFromComponents:dateComponentsDate];

    }else {
        date = self.dataPickView.date;
    }
    if ([self.delagate respondsToSelector:@selector(didPickDataWithDate:andTag:)]) {
        [self.delagate didPickDataWithDate:date andTag:showTag ];
    }
    [self hide:YES];
}

- (void)tapEvent {
    [self hide:YES];
}

- (void)showWithTag:(int)tag {
    
    showTag= tag;
    if ([KEY_WINDOW viewWithTag:CommDatePickViewTag]) {
        [[KEY_WINDOW viewWithTag:CommDatePickViewTag] removeFromSuperview];
    }
    [KEY_WINDOW addSubview:self];

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        contentView.bottom=self.height;
        backgroundView.alpha=0.4f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide:(BOOL)animation {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        contentView.top=self.height;
        backgroundView.alpha=0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
