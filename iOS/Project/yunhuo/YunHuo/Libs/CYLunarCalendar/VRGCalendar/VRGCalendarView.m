//
//  VRGCalendarView.m
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//

#import "VRGCalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+convenience.h"
#import "NSMutableArray+convenience.h"
#import "UIView+convenience.h"
#import "LunarCalendar.h"
#import "CYDatetime.h"
#import "FMDB.h"

#define kTopBarHeight	0//40

@implementation VRGCalendarView
@synthesize currentMonth,delegate,labelCurrentMonth, animationView_A,animationView_B;
@synthesize markedDates,markedColors,calendarHeight,selectedDate;
@synthesize rowOfSelectedDate = rowOfSelectedDate;

#pragma mark - Select Date
#pragma mark 获取日期的相关信息
-(NSString *)readyDatabase:(NSString *)dbName
{
    BOOL success;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *writableDBPath=[documentsDirectory stringByAppendingPathComponent:dbName];
    success=[fileManager fileExistsAtPath:writableDBPath];
    if(!success)
    {
        NSString *defaultDBPath=[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbName];
        success=[fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success)
        {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    return writableDBPath;
}

-(NSMutableDictionary *)getChineseCalendarInfo:(NSString *)date
{
    NSString *dbPath =[self readyDatabase:@"ChineseCalendar.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    
    NSMutableDictionary *resultDict=[[[NSMutableDictionary alloc] init] autorelease];
    
    FMResultSet *rs = [db executeQuery:@"select * from ChineseCalendar where RiQi = ?", date];
    while ([rs next]) {
        [resultDict setObject:[rs stringForColumn:@"GanZhi"] forKey:@"GanZhi"];
        [resultDict setObject:[rs stringForColumn:@"Yi"] forKey:@"Yi"];
        [resultDict setObject:[rs stringForColumn:@"Ji"] forKey:@"Ji"];
        [resultDict setObject:[rs stringForColumn:@"Chong"] forKey:@"Chong"];
        [resultDict setObject:[rs stringForColumn:@"WuXing"] forKey:@"WuXing"];
    }
    [rs close];
    
    return resultDict;
}

-(void)selectDate:(int)date {
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
    [comps setDay:date];
    self.selectedDate = [gregorian dateFromComponents:comps];
    
    int selectedDateYear = [selectedDate year];
    int selectedDateMonth = [selectedDate month];
    int currentMonthYear = [currentMonth year];
    int currentMonthMonth = [currentMonth month];
    
    if (selectedDateYear < currentMonthYear) {
        [self showPreviousMonth];
    } else if (selectedDateYear > currentMonthYear) {
        [self showNextMonth];
    } else if (selectedDateMonth < currentMonthMonth) {
        [self showPreviousMonth];
    } else if (selectedDateMonth > currentMonthMonth) {
        [self showNextMonth];
    } else {
//        [self setNeedsDisplay];
    }
    
    CYDatetime *CYDate = [[[CYDatetime alloc]init] autorelease];
    CYDate.year=[selectedDate year];
    CYDate.month=[selectedDate month];
    CYDate.day = [selectedDate day];
    LunarCalendar *lunarCalendar = [[[CYDate convertDate] chineseCalendarDate ]autorelease];
    
//    NSLog(@"%d",date);
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString* dateString = [[[NSString alloc]initWithString:[formatter stringFromDate:self.selectedDate]]autorelease];
    [formatter release];
//    NSLog(@"%@",self.selectedDate);
    
    NSMutableDictionary *detailDict=[[[NSMutableDictionary alloc] initWithDictionary:[self getChineseCalendarInfo:dateString]] autorelease];
    [detailDict setObject:[NSString stringWithFormat:@"%d%d%d",lunarCalendar.GregorianYear,lunarCalendar.GregorianMonth,lunarCalendar.GregorianDay] forKey:@"GregorianDate"];
    
    [detailDict setObject:[NSString stringWithFormat:@"%@%@%@",lunarCalendar.IsLeap?@"闰":@"", lunarCalendar.MonthLunar,lunarCalendar.DayLunar] forKey:@"LunarDate"];
    
    [detailDict setObject:[NSString stringWithFormat:@"%@",lunarCalendar.Constellation] forKey:@"Constellation"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //每周的第一天从星期一开始
    [calendar setFirstWeekday:1];
    NSDateComponents *comps2 = [calendar components:NSWeekCalendarUnit fromDate:self.selectedDate];
    
    [detailDict setObject:[NSString stringWithFormat:@"第%d周",comps2.week] forKey:@"Weekday"];
	
	int firstweekday = [currentMonth firstWeekDayInMonth];
		
	rowOfSelectedDate = (firstweekday+date-1)/7;
	
	selectedMark.center = CGPointMake((kVRGCalendarViewDayWidth+2)*((firstweekday+date-1)%7+0.5),(rowOfSelectedDate+0.5)*(kVRGCalendarViewDayHeight+2));

    if ([delegate respondsToSelector:@selector(calendarView:dateSelected:lunarDict:)])
    {
        [delegate calendarView:self dateSelected:self.selectedDate lunarDict:detailDict];
    }
}

#pragma mark - Mark Dates
//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates {
    self.markedDates = dates;
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[dates count]; i++) {
        [colors addObject:[UIColor colorWithHexString:@"0x079700"]];
    }
    
    self.markedColors = [NSArray arrayWithArray:colors];
    [colors release];
    
//    [self setNeedsDisplay];
}

//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors {
    self.markedDates = dates;
    self.markedColors = colors;
    
    [self setNeedsDisplay];
}

#pragma mark - Set date to now
-(void)reset {
    NSCalendar *gregorian = [[[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: [NSDate date]];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    
    [self updateSize];
	contentView.image = [self drawCurrentState];
//    [self setNeedsDisplay];
    [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
    
    [self selectDate:[NSDate date].day];
}

#pragma mark - Next & Previous
-(void)showNextMonth {
	self.currentMonth = [currentMonth offsetMonth:1];
	if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight: animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
	contentView.image = [self drawCurrentState];
//	[self setNeedsDisplay];
	return;
	//TBD,暂时跳过动画部分
    if (isAnimating) return;
    self.markedDates=nil;
    isAnimating=YES;
    prepAnimationNextMonth=YES;
    
    [self setNeedsDisplay];
    
    int lastBlock = [currentMonth firstWeekDayInMonth]+[currentMonth numDaysInMonth];
    int numBlocks = [self numRows]*7;
    BOOL hasNextMonthDays = lastBlock<numBlocks;
    
    //Old month
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //New month
    self.currentMonth = [currentMonth offsetMonth:1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight: animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationNextMonth=NO;
    [self setNeedsDisplay];
    
    UIImage *imageNextMonth = [self drawCurrentState];
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
    
    //Animate
    animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    animationView_B = [[UIImageView alloc] initWithImage:imageNextMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    [animationHolder release];
    
    if (hasNextMonthDays) {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight - (kVRGCalendarViewDayHeight+3);
    } else {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight -3;
    }
    
    //Animation
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         //blockSafeSelf.frameHeight = 100;
                         if (hasNextMonthDays) {
                             animationView_A.frameY = -animationView_A.frameHeight + kVRGCalendarViewDayHeight+3;
                         } else {
                             animationView_A.frameY = -animationView_A.frameHeight + 3;
                         }
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}

-(void)showPreviousMonth {
	self.currentMonth = [currentMonth offsetMonth:-1];
	if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
//	prepAnimationPreviousMonth=NO;
	contentView.image = [self drawCurrentState];
//	[self setNeedsDisplay];
	return;
	//TBD,暂时跳过动画部分
    if (isAnimating) return;
    isAnimating=YES;
    self.markedDates=nil;
    //Prepare current screen
    prepAnimationPreviousMonth = YES;
    [self setNeedsDisplay];
    BOOL hasPreviousDays = [currentMonth firstWeekDayInMonth]>0;
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //Prepare next screen
    self.currentMonth = [currentMonth offsetMonth:-1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationPreviousMonth=NO;
    [self setNeedsDisplay];
    UIImage *imagePreviousMonth = [self drawCurrentState];
    
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
    
    animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    animationView_B = [[UIImageView alloc] initWithImage:imagePreviousMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    [animationHolder release];
    
    if (hasPreviousDays) {
        animationView_B.frameY = animationView_A.frameY - (animationView_B.frameHeight-kVRGCalendarViewDayHeight) + 3;
    } else {
        animationView_B.frameY = animationView_A.frameY - animationView_B.frameHeight + 3;
    }
    
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         
                         if (hasPreviousDays) {
                             animationView_A.frameY = animationView_B.frameHeight-(kVRGCalendarViewDayHeight+3); 
                             
                         } else {
                             animationView_A.frameY = animationView_B.frameHeight-3;
                         }
                         
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}


#pragma mark - update size & row count
-(void)updateSize {
    self.frameHeight = self.calendarHeight;
//    [self setNeedsDisplay];
}

-(float)calendarHeight {
    return kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
}

-(int)numRows {
    float lastBlock = [self.currentMonth numDaysInMonth]+[self.currentMonth firstWeekDayInMonth];
	return ceilf(lastBlock/7);
}

#pragma mark - Touches
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{       
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    self.selectedDate=nil;
    
    //Touch a specific day
    if (touchPoint.y > kVRGCalendarViewTopBarHeight) {
        float xLocation = touchPoint.x;
        float yLocation = touchPoint.y-kVRGCalendarViewTopBarHeight;
        
        int column = floorf(xLocation/(kVRGCalendarViewDayWidth+2));
        int row = floorf(yLocation/(kVRGCalendarViewDayHeight+2));
        
        int blockNr = (column+1)+row*7;
        int firstWeekDay = [self.currentMonth firstWeekDayInMonth]; //-1 because weekdays begin at 1, not 0
        int date = blockNr-firstWeekDay;
        [self selectDate:date];
        return;
    }
    
    self.markedDates=nil;
    self.markedColors=nil;  
    
    CGRect rectArrowLeft = CGRectMake(0, 0, 50, kTopBarHeight);
    CGRect rectArrowRight = CGRectMake(self.frame.size.width-50, 0, 50, kTopBarHeight);
    
    //Touch either arrows or month in middle
    if (CGRectContainsPoint(rectArrowLeft, touchPoint)) {
        [self showPreviousMonth];
    } else if (CGRectContainsPoint(rectArrowRight, touchPoint)) {
        [self showNextMonth];
    } else if (CGRectContainsPoint(self.labelCurrentMonth.frame, touchPoint)) {
        //Detect touch in current month
        int currentMonthIndex = [self.currentMonth month];
        int todayMonth = [[NSDate date] month];
        [self reset];
        if ((todayMonth!=currentMonthIndex) && [delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
    }
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
}

- (void) drawContent:(CGContextRef)context
{
	CGRect rect = self.bounds;
    int firstWeekDay = [self.currentMonth firstWeekDayInMonth]; //-1 because weekdays begin at 1, not 0
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月"];
    labelCurrentMonth.text = [formatter stringFromDate:self.currentMonth];
    [labelCurrentMonth sizeToFit];
    labelCurrentMonth.frameX = roundf(self.frame.size.width/2 - labelCurrentMonth.frameWidth/2);
    labelCurrentMonth.frameY = 10;
    [formatter release];
    [currentMonth firstWeekDayInMonth];
    
    CGContextClearRect(context,rect);
    
    CGRect rectangle = CGRectMake(0,0,self.frame.size.width,kVRGCalendarViewTopBarHeight);
    CGContextAddRect(context, rectangle);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    
    //Arrows
    int arrowSize = 12;
    int xmargin = 20;
    int ymargin = 18;
    
    //Arrow Left
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xmargin+arrowSize/1.5, ymargin);
    CGContextAddLineToPoint(context,xmargin+arrowSize/1.5,ymargin+arrowSize);
    CGContextAddLineToPoint(context,xmargin,ymargin+arrowSize/2);
    CGContextAddLineToPoint(context,xmargin+arrowSize/1.5, ymargin);
    
    CGContextSetFillColorWithColor(context, 
                                   [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    
    //Arrow right
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    CGContextAddLineToPoint(context,self.frame.size.width-xmargin,ymargin+arrowSize/2);
    CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5),ymargin+arrowSize);
    CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    
    CGContextSetFillColorWithColor(context, 
                                   [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    
    //Weekdays
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"EEE";
    //always assume gregorian with monday first
    NSMutableArray *weekdays = [[NSMutableArray alloc] initWithArray:[dateFormatter shortWeekdaySymbols]];
    [weekdays moveObjectFromIndex:0 toIndex:6];
    
    //chinese array for weekdays
    NSArray *chineseWeekdays= [NSArray arrayWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",nil];
    
    
    for (int i =0; i<[weekdays count]; i++) {
        
        if (i==0||i==6)
        {
            CGContextSetFillColorWithColor(context,
                                           [UIColor colorWithHexString:@"0xff3333"].CGColor);
        }
        else
        {
            CGContextSetFillColorWithColor(context,
                                           [UIColor colorWithHexString:@"0x383838"].CGColor);
        }
        
        NSString *weekdayValue = (NSString *)[chineseWeekdays objectAtIndex:i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [weekdayValue drawInRect:CGRectMake(i*(kVRGCalendarViewDayWidth+2), kTopBarHeight, kVRGCalendarViewDayWidth+2, 20) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    }
    
    int numRows = [self numRows];
    
    CGContextSetAllowsAntialiasing(context, NO);
    
    //Grid background
    float gridHeight = numRows*(kVRGCalendarViewDayHeight+2)+1;
    CGRect rectangleGrid = CGRectMake(0,kVRGCalendarViewTopBarHeight,self.frame.size.width,gridHeight);
    CGContextAddRect(context, rectangleGrid);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xf3f3f3"].CGColor);	
//    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xf3f3f3"].CGColor);
    //CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xff0000"].CGColor);
    CGContextFillPath(context);
    
    //Grid white lines
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+1);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+1);
    for (int i = 1; i<7; i++) {
        CGContextMoveToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1-1, kVRGCalendarViewTopBarHeight);
        CGContextAddLineToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1-1, kVRGCalendarViewTopBarHeight+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1+1);
        CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1+1);
    }
    
    CGContextStrokePath(context);
    
    //Grid dark lines
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"0xcfd4d8"].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight);
    for (int i = 1; i<7; i++) {
        //columns
        CGContextMoveToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1, kVRGCalendarViewTopBarHeight);
        CGContextAddLineToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1, kVRGCalendarViewTopBarHeight+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1);
        CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1);
    }
    CGContextMoveToPoint(context, 0, gridHeight+kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, gridHeight+kVRGCalendarViewTopBarHeight);
    
    CGContextStrokePath(context);
    
    CGContextSetAllowsAntialiasing(context, YES);
    
    //Draw days
    CGContextSetFillColorWithColor(context, 
                                   [UIColor colorWithHexString:@"0x383838"].CGColor);
    
    int numBlocks = numRows*7;
    NSDate *previousMonth = [self.currentMonth offsetMonth:-1];
    int currentMonthNumDays = [currentMonth numDaysInMonth];
    int prevMonthNumDays = [previousMonth numDaysInMonth];
    
    int selectedDateBlock = ([selectedDate day]-1)+firstWeekDay;
    
    //prepAnimationPreviousMonth nog wat mee doen
    
    //prev next month
    BOOL isSelectedDatePreviousMonth = prepAnimationPreviousMonth;
    BOOL isSelectedDateNextMonth = prepAnimationNextMonth;
    
    if (self.selectedDate!=nil) {
        isSelectedDatePreviousMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]<[currentMonth month]) || [selectedDate year] < [currentMonth year];
        
        if (!isSelectedDatePreviousMonth) {
            isSelectedDateNextMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]>[currentMonth month]) || [selectedDate year] > [currentMonth year];
        }
    }
    
    if (isSelectedDatePreviousMonth) {
        int lastPositionPreviousMonth = firstWeekDay-1;
        selectedDateBlock=lastPositionPreviousMonth-([selectedDate numDaysInMonth]-[selectedDate day]);
    } else if (isSelectedDateNextMonth) {
        selectedDateBlock = [currentMonth numDaysInMonth] + (firstWeekDay-1) + [selectedDate day];
    }
    
    
    NSDate *todayDate = [NSDate date];
    int todayBlock = -1;
    
    if ([todayDate month] == [currentMonth month] && [todayDate year] == [currentMonth year]) {
        todayBlock = [todayDate day] + firstWeekDay - 1;
    }
    
    for (int i=0; i<numBlocks; i++) {
        int targetDate ;
        int targetColumn = i%7;
        int targetRow = i/7;
        int targetX = targetColumn * (kVRGCalendarViewDayWidth+2);
        int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2);
        
        CYDatetime *CYDate = [[[CYDatetime alloc]init] autorelease];
        
        // BOOL isCurrentMonth = NO;
        if (i<firstWeekDay)
        { //previous month
			
			//TBD,非选中月份的日期不显示
			continue;
			
//            targetDate = (prevMonthNumDays-firstWeekDay)+(i+1);
//            NSString *hex = (isSelectedDatePreviousMonth) ? @"0x383838" : @"aaaaaa";
//            
//            if(targetColumn==0||targetColumn==6)
//            {
//                CGContextSetFillColorWithColor(context,
//                                           [UIColor colorWithHexString:@"0xf39999"].CGColor);
//            }
//            else
//            {
//                CGContextSetFillColorWithColor(context,
//                                               [UIColor colorWithHexString:hex].CGColor);
//            }
//            
//            if([self.currentMonth month]==1)
//            {
//                CYDate.year=[self.currentMonth year]-1;
//                CYDate.month =12;
//            }
//            else
//            {
//                CYDate.year=[self.currentMonth year];
//                CYDate.month =[self.currentMonth month]-1;
//            }
			
            
        }
        else if (i>=(firstWeekDay+currentMonthNumDays))
        { //next month
			
			//TBD,非选中月份的日期不显示
			continue;
			
//            targetDate = (i+1) - (firstWeekDay+currentMonthNumDays);
//            NSString *hex = (isSelectedDateNextMonth) ? @"0x383838" : @"aaaaaa";
//            
//            if(targetColumn==0||targetColumn==6)
//            {
//                CGContextSetFillColorWithColor(context,
//                                               [UIColor colorWithHexString:@"0xf39999"].CGColor);
//            }
//            else
//            {
//                CGContextSetFillColorWithColor(context,
//                                               [UIColor colorWithHexString:hex].CGColor);
//            }
//            
//            if([self.currentMonth month]==12)
//            {
//                CYDate.year=[self.currentMonth year]+1;
//                CYDate.month =1;
//            }
//            else
//            {
//                CYDate.year=[self.currentMonth year];
//                CYDate.month =[self.currentMonth month]+1;
//            }
        }
        else
        { //current month
            // isCurrentMonth = YES;
            targetDate = (i-firstWeekDay)+1;
//            NSString *hex = (isSelectedDatePreviousMonth || isSelectedDateNextMonth) ? @"0xaaaaaa" : @"0x383838";
            NSString *hex = @"0x383838";//(isSelectedDatePreviousMonth || isSelectedDateNextMonth) ? @"0xaaaaaa" : @"0x383838";
            if(targetColumn==0||targetColumn==6)
            {
                CGContextSetFillColorWithColor(context,
                                               [UIColor colorWithHexString:@"0xff3333"].CGColor);
            }
            else
            {
                CGContextSetFillColorWithColor(context,
                                               [UIColor colorWithHexString:hex].CGColor);
            }
            
            CYDate.year=[self.currentMonth year];
            CYDate.month =[self.currentMonth month];
        }
        
        CYDate.day = targetDate;
        LunarCalendar *lunarCalendar = [[[CYDate convertDate] chineseCalendarDate ]autorelease];
        NSString * lunarDate = [lunarCalendar.DayLunar isEqualToString:@"初一"]?lunarCalendar.MonthLunar :[[NSString alloc]initWithFormat:
                                @"%@",[lunarCalendar.SolarTermTitle isEqualToString:@""]?lunarCalendar.DayLunar:lunarCalendar.SolarTermTitle];
        
        
        NSString *date = [NSString stringWithFormat:@"%i",targetDate];
        
        //draw selected date
        if (selectedDate && i==selectedDateBlock) {
//            CGRect rectangleGrid = CGRectMake(targetX,targetY,kVRGCalendarViewDayWidth+2,kVRGCalendarViewDayHeight+2);
//            CGContextAddRect(context, rectangleGrid);
//            CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0x006dbc"].CGColor);
//            CGContextFillPath(context);
//            
//            CGContextSetFillColorWithColor(context, 
//                                           [UIColor whiteColor].CGColor);
			
//			rowOfSelectedDate = targetRow;
//			
//			selectedMark.center = CGPointMake(targetX+kVRGCalendarViewDayWidth/2+1,targetY+kVRGCalendarViewDayHeight/2+1);
        } else if (todayBlock==i) {
            CGRect rectangleGrid = CGRectMake(targetX,targetY,kVRGCalendarViewDayWidth+2,kVRGCalendarViewDayHeight+2);
            CGContextAddRect(context, rectangleGrid);
//            CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0x383838"].CGColor);
			CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xd0d0d0"].CGColor);
            CGContextFillPath(context);
            
            CGContextSetFillColorWithColor(context, 
                                           [UIColor whiteColor].CGColor);
        }
		
		//TBD,添加理财部分数据
		float appointmentparth = 10;
		int appointmentcount = [self.dataSource calendarViewAppointmentNum:self onDate:[CYDate convertDate]];
		BOOL isallaccpet = NO;
		NSString *count = [NSString stringWithFormat:@"%d",appointmentcount];
		
		if ( appointmentcount > 0 )
		{
			CGContextSaveGState(context);
			
//			CGContextSetFillColorWithColor(context, RED_LINE_COLOR.CGColor);
			if ( isallaccpet )
			{
				[count drawInRect:CGRectMake(targetX, targetY + 1, kVRGCalendarViewDayWidth, 12) withFont:[UIFont fontWithName:@"HelveticaNeue" size:10] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
			}
			else
			{
				CGContextFillEllipseInRect(context, CGRectMake(targetX+14, targetY + 5, 5, 5));
				[count drawInRect:CGRectMake(targetX+20, targetY + 1, 40, 12) withFont:[UIFont fontWithName:@"HelveticaNeue" size:10] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
			}
			
			
			CGContextRestoreGState(context);
		}
		targetY += appointmentparth;
		
        [date drawInRect:CGRectMake(targetX-9, targetY, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
        
        [lunarDate drawInRect:CGRectMake(targetX+11, targetY+8, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withFont:[UIFont fontWithName:@"HelveticaNeue" size:8] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
        
        NSString *holiday=[lunarCalendar.Holiday count]>0?[[[lunarCalendar.Holiday objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:0]:@"";
        
        [holiday drawInRect:CGRectMake(targetX, targetY+22, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withFont:[UIFont fontWithName:@"HelveticaNeue" size:8] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
        
        
    }
    
    //    CGContextClosePath(context);
    
    
    //Draw markings
    if (!self.markedDates || isSelectedDatePreviousMonth || isSelectedDateNextMonth) return;
    
    for (int i = 0; i<[self.markedDates count]; i++) {
        id markedDateObj = [self.markedDates objectAtIndex:i];
        
        int targetDate;
        if ([markedDateObj isKindOfClass:[NSNumber class]]) {
            targetDate = [(NSNumber *)markedDateObj intValue];
        } else if ([markedDateObj isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)markedDateObj;
            targetDate = [date day];
        } else {
            continue;
        }
        
        
        
        int targetBlock = firstWeekDay + (targetDate-1);
        int targetColumn = targetBlock%7;
        int targetRow = targetBlock/7;
        
        int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
        int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 38;
        
        CGRect rectangle = CGRectMake(targetX+10,targetY+4,10,4);
        CGContextAddRect(context, rectangle);
        
        UIColor *color;
        if (selectedDate && selectedDateBlock==targetBlock) {
            color = [UIColor whiteColor];
        }  else if (todayBlock==targetBlock) {
            color = [UIColor whiteColor];
        } else {
            color  = (UIColor *)[markedColors objectAtIndex:i];
        }
        
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
    }
}

#pragma mark - Draw image for animation
-(UIImage *)drawCurrentState {
    float targetHeight = kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
	
	float scale = 2;//[UIScreen mainScreen].nativeScale;
    UIGraphicsBeginImageContext(CGSizeMake(kVRGCalendarViewWidth*scale, (targetHeight-kVRGCalendarViewTopBarHeight)*scale));
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, -kVRGCalendarViewTopBarHeight);    // <-- shift everything up by 40px when drawing.
	CGContextScaleCTM(c, scale, scale);
	[self drawContent:c];
//    [self.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark - Init
//-(id)init {
//    self = [super initWithFrame:CGRectMake(0, 0, kVRGCalendarViewWidth, 0)];
//    if (self) {
//        self.contentMode = UIViewContentModeTop;
//        self.clipsToBounds=YES;
//        
//        isAnimating=NO;
//        labelCurrentMonth = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, kVRGCalendarViewWidth-68, 40)];
//        [self addSubview:labelCurrentMonth];
//        labelCurrentMonth.backgroundColor=[UIColor whiteColor];
//        labelCurrentMonth.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
//        labelCurrentMonth.textColor = [UIColor colorWithHexString:@"0x383838"];
//        labelCurrentMonth.textAlignment = NSTextAlignmentCenter;
//		
//		[self reset];
////        [self performSelector:@selector(reset) withObject:nil afterDelay:0.1]; //so delegate can be set after init and still get called on init
//        //        [self reset];
//
//    }
//    return self;
//}

- (void) awakeFromNib
{
	self.contentMode = UIViewContentModeTop;
	self.clipsToBounds=YES;
	
	isAnimating=NO;
	labelCurrentMonth = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, kVRGCalendarViewWidth-68, kTopBarHeight)];
//	[self addSubview:labelCurrentMonth];
	labelCurrentMonth.backgroundColor=[UIColor whiteColor];
	labelCurrentMonth.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
	labelCurrentMonth.textColor = [UIColor colorWithHexString:@"0x383838"];
	labelCurrentMonth.textAlignment = NSTextAlignmentCenter;
	
	contentView = [[UIImageView alloc] initWithFrame:self.bounds];
	contentView.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:contentView];

	selectedMark = [[UIView alloc] initWithFrame:CGRectMake(0,0,kVRGCalendarViewDayWidth,kVRGCalendarViewDayHeight)];
	selectedMark.backgroundColor = [UIColor clearColor];
	selectedMark.layer.borderWidth = 1.25;
	selectedMark.layer.cornerRadius = 4.0;
//	selectedMark.layer.borderColor = RED_LINE_COLOR.CGColor;
	[self addSubview:selectedMark];
	
	contentView.image = [self drawCurrentState];
	
//	[self reset];
//	[self performSelector:@selector(reset) withObject:nil afterDelay:0.1]; //so delegate can be set after init and still get called
}

-(void)dealloc {
	self.dataSource=nil;
	self.delegate=nil;
	self.currentMonth=nil;
	self.labelCurrentMonth=nil;
	self.markedDates=nil;
	self.markedColors=nil;
	
    [currentMonth release];
    [labelCurrentMonth release];
    [animationView_A release];
    [animationView_B release];
    [markedDates release];
    [markedColors release];
    [selectedDate release];
    
    [super dealloc];
}

- (void) layoutSubviews
{
	contentView.frame = self.bounds;
	[super layoutSubviews];
}
@end
