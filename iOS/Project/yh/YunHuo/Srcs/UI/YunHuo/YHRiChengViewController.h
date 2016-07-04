//
//  YHRiChengTableViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface YHRiChengLineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIImageView *boardBG;
@property (weak, nonatomic) IBOutlet UILabel *richengIndex;
@property (weak, nonatomic) IBOutlet UITextView *richengContent;
@property (weak, nonatomic) IBOutlet UILabel *richengTime;
@end


@interface YHRiChengCardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIImageView *boardBG;
@property (weak, nonatomic) IBOutlet UILabel *richengIndex;
@property (weak, nonatomic) IBOutlet UITextView *richengContent;
@property (weak, nonatomic) IBOutlet UILabel *richengTime;

@end

@interface YHRiChengViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,JTCalendarDataSource>
@property (weak, nonatomic) IBOutlet UITableView *cardTableView;
@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;
@property (nonatomic) BOOL isUsingCardView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForCalendar;

- (IBAction)onSwitch:(id)sender;
@end
