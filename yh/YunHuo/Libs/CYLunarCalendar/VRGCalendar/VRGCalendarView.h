//
//  VRGCalendarView.h
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//
//  Modified by cyrusleung on 2014-06-19
//  1.调整了日历样式、汉化等
//  2.增加了农历和节假日显示

#import <UIKit/UIKit.h>
#import "UIColor+expanded.h"

#define kVRGCalendarViewTopBarHeight 0//60
#define kVRGCalendarViewWidth 320

#define kVRGCalendarViewDayWidth 44
#define kVRGCalendarViewDayHeight 54//44

@protocol VRGCalendarViewDelegate;
@protocol VRGCalendarViewAppointmentDataSource;
@interface VRGCalendarView : UIView {
    id <VRGCalendarViewDelegate> delegate;
	id <VRGCalendarViewAppointmentDataSource> dataSource;
    
    NSDate *currentMonth;
    
    UILabel *labelCurrentMonth;
    
    BOOL isAnimating;
    BOOL prepAnimationPreviousMonth;
    BOOL prepAnimationNextMonth;
    
    UIImageView *animationView_A;
    UIImageView *animationView_B;
    
    NSArray *markedDates;
    NSArray *markedColors;
	
	int rowOfSelectedDate;
	
	UIImageView	*contentView;
	UIView		*selectedMark;
}

@property (nonatomic, assign) IBOutlet id <VRGCalendarViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id <VRGCalendarViewAppointmentDataSource> dataSource;
@property (nonatomic, retain) NSDate *currentMonth;
@property (nonatomic, retain) UILabel *labelCurrentMonth;
@property (nonatomic, retain) UIImageView *animationView_A;
@property (nonatomic, retain) UIImageView *animationView_B;
@property (nonatomic, retain) NSArray *markedDates;
@property (nonatomic, retain) NSArray *markedColors;
@property (nonatomic, getter = calendarHeight) float calendarHeight;
@property (nonatomic, retain, getter = selectedDate) NSDate *selectedDate;
@property (nonatomic, readonly) int rowOfSelectedDate;

-(void)selectDate:(int)date;
-(void)reset;

-(void)markDates:(NSArray *)dates;
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors;

-(void)showNextMonth;
-(void)showPreviousMonth;

-(int)numRows;
-(void)updateSize;
-(UIImage *)drawCurrentState;

@end

@protocol VRGCalendarViewDelegate <NSObject>
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated;
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date lunarDict:(NSMutableDictionary*) dict;
@end

@protocol VRGCalendarViewAppointmentDataSource<NSObject>
- (int) calendarViewAppointmentNum:(VRGCalendarView *)calendarView onDate:(NSDate*)date;
@end