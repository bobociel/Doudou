//
//  CommDatePickView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommDatePickView.h"
#import "CommAnimationForControl.h"
#define CommDatePickViewTag 48237
#define kGap    15
#define kSBtnHeight 20
#define kSBtnWidth  36
#define kBBtnHeight 50
#define kLabelWidth 160
#define kCateItemH  (screenWidth/4.0)
#define kLineColor  rgba(221, 221, 221, 1)
@implementation CommDatePickView
{
    UIView       *backgroundView;
    UIView       *contentView;
	UIView       *cateView;
	UIButton     *doneBtn;
	UIButton     *cancelBtn;
	UILabel      *wedLabel;
    PickerViewType type;
	NSMutableArray *cateTitles;
}
@synthesize dataPickView;

- (instancetype)init {
	self = [super init];
    return self;
}

+ (instancetype)viewWithStyle:(PickerViewStyle)style
{
	CommDatePickView *view = [[CommDatePickView alloc] init];
	[view initViewWithStyle:style];
	return view;
}

- (void)initViewWithStyle:(PickerViewStyle)style {
    self.tag=CommDatePickViewTag;
    self.frame=KEY_WINDOW.bounds;
	cateTitles = [NSMutableArray array];

    backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0.f;
    [self addSubview:backgroundView];

	contentView = [[UIView alloc] initWithFrame:CGRectZero];
	contentView.frame = CGRectMake(0, screenHeight - 250, screenWidth, 250);
	contentView.backgroundColor=[UIColor whiteColor];
	[self addSubview:contentView];

	wedLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth - kLabelWidth)/2, kGap, kLabelWidth, kSBtnHeight)];
	wedLabel.font = DefaultFont18;
	wedLabel.textAlignment = NSTextAlignmentCenter;
	wedLabel.text = @"我的婚期";
	[contentView addSubview:wedLabel];

	doneBtn = [[UIButton alloc] initWithFrame:CGRectZero];
	doneBtn.titleLabel.font = DefaultFont18;
	[doneBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	[doneBtn setTitle:@"确定" forState:UIControlStateNormal];
	[contentView addSubview:doneBtn];
	[doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];

	cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
	cancelBtn.titleLabel.font = DefaultFont18;
	[cancelBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
	[contentView addSubview:cancelBtn];
	[cancelBtn addTarget:self action:@selector(tapEvent) forControlEvents:UIControlEventTouchUpInside];

	dataPickView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
	dataPickView.datePickerMode = UIDatePickerModeDate;
	[dataPickView setTimeZone:[NSTimeZone defaultTimeZone]];
	[contentView addSubview:dataPickView];

	cateView = [[UIView alloc] initWithFrame:CGRectZero];
	[contentView addSubview:cateView];

	if(style == PickerViewStyleDefault){
		cateView.frame = CGRectZero;
		wedLabel.frame = CGRectZero;
		cancelBtn.frame = CGRectZero;
		doneBtn.frame = CGRectMake(screenWidth - kGap - kSBtnWidth, kGap, kSBtnWidth, kSBtnHeight);
		[doneBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
		dataPickView.frame = CGRectMake(0, doneBtn.bottom, self.width, 200);
	}else if(style == PickerViewStyleRedSure){
		cateView.frame = CGRectZero;
		cancelBtn.frame = CGRectMake(kGap, kGap, kSBtnWidth, kSBtnHeight);
		doneBtn.frame = CGRectMake(0, 250 - kBBtnHeight, screenWidth, kBBtnHeight);
		doneBtn.backgroundColor = WeddingTimeBaseColor;
		[doneBtn setTitleColor:WHITE forState:UIControlStateNormal];
		dataPickView.frame = CGRectMake(0, cancelBtn.bottom, self.width, 160);
	} else if (style == PickerViewStyleRedSureCate){
		[dataPickView removeFromSuperview];
		contentView.frame = CGRectMake(0, screenHeight - 300, screenWidth, 300);
		cateView.frame = CGRectMake(0, 50, screenWidth, 200);
		wedLabel.text = @"选择咨询服务";
		wedLabel.textColor = LightGragyColor;
		cancelBtn.frame = CGRectMake(kGap, kGap, kSBtnWidth, kSBtnHeight);
		doneBtn.frame = CGRectMake(0, 300 - kBBtnHeight, screenWidth, kBBtnHeight);
		doneBtn.backgroundColor = WeddingTimeBaseColor;
		[doneBtn setTitleColor:WHITE forState:UIControlStateNormal];
		[doneBtn setTitle:@"进入咨询" forState:UIControlStateNormal];

		NSMutableArray *cates = [self categoryArray];
		for ( NSInteger i=0; i < cates.count; i++) {
			SquareButton *btn = [[SquareButton alloc] initWithFrame:CGRectMake(i % 4 * kCateItemH, i / 4 * 100, kCateItemH, 100)];
			btn.headLine.backgroundColor = kLineColor;
			btn.leftLine.backgroundColor = kLineColor;
			btn.rightLine.hidden = YES;
			btn.nameLabel.textColor = LightGragyColor;
			btn.iconButton.tintColor = rgba(200, 200, 200, 1);
			btn.nameLabel.text = cates[i][@"text"];
			[btn.iconButton setImage:[UIImage imageNamed:cates[i][@"image"]] forState:UIControlStateNormal];
			[cateView addSubview:btn];
			[btn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
		}
	}

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    [backgroundView addGestureRecognizer:tap];
}

- (void)setCurrentTimeWith:(unsigned long long )timestamp
{
	unsigned long long nowtimestamp = [[[NSDate date] dateByAddingHours:1] timeIntervalSince1970];
	dataPickView.date = [NSDate dateWithTimeIntervalSince1970:MAX(timestamp, nowtimestamp)];
}

#pragma mark - Action
- (void)done
{
    NSDate *date;
    if (type == PickerViewTypeDateAndTime)
	{
		NSDateComponents *dateComponentsDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:dataPickView.date];
        date = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsDate];
    }else if(type == PickerViewTypeDefault || type == PickerViewTypeDate) {
        date = dataPickView.date;
	}else if (type == PickerViewTypeTime){
		date = dataPickView.date;
	}else if (type == PickerViewTypeCate){
		if(cateTitles.count > 0){
			self.resultString = [NSString stringWithFormat:@"我想找%@",[cateTitles componentsJoinedByString:@"，"]];
		}
	}

    if ([self.delagate respondsToSelector:@selector(didPickDataWithDate:andType:)]) {
		[self hide:YES callback:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delagate didPickDataWithDate:date andType:type];
			});
		}];
    }
}

- (void)tapEvent {
    [self hide:YES callback:nil];
}

#pragma mark - Show & ChangeDateStyle
- (void)showWithType:(PickerViewType)tag {
    type = tag;
	if(tag == PickerViewTypeDate || tag == PickerViewTypeDefault){
		dataPickView.datePickerMode = UIDatePickerModeDate;
		dataPickView.minimumDate = [[NSDate date] dateByAddingHours:1];
	}
	else if (tag == PickerViewTypeDateAndTime){
		dataPickView.datePickerMode = UIDatePickerModeDateAndTime;
		dataPickView.minimumDate = [[NSDate date] dateByAddingHours:1];
	}else if (tag == PickerViewTypeTime){
		dataPickView.datePickerMode = UIDatePickerModeTime;
		dataPickView.date = [[NSDate dateWithTimeIntervalSince1970:0] dateByAddingYears:30];
	}

    if ([KEY_WINDOW viewWithTag:CommDatePickViewTag]) {
        [[KEY_WINDOW viewWithTag:CommDatePickViewTag] removeFromSuperview];
    }
    [KEY_WINDOW addSubview:self];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        contentView.bottom=self.height;
        backgroundView.alpha = 0.7f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide:(BOOL)animation callback:(void(^)())callback {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        contentView.top=self.height;
        backgroundView.alpha=0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
		if(callback) { callback(); }
    }];
}

#pragma mark - CateView 
- (void)selectAction:(SquareButton *)sender
{
	sender.selected = !sender.selected;
	[sender.iconButton.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScale"];
	sender.iconButton.tintColor = sender.selected ? WeddingTimeBaseColor : rgba(221, 221, 221, 1);
	sender.nameLabel.textColor = sender.selected  ? WeddingTimeBaseColor : LightGragyColor;
	sender.selected ? [cateTitles addObject:sender.nameLabel.text] : [cateTitles removeObject:sender.nameLabel.text];
}

- (NSMutableArray *)categoryArray
{
	return [@[@{@"tag":@(WTWeddingTypePlan),@"text":@"婚礼策划",@"image":@"category_wedding_plan"}
			  ,@{@"tag":@(WTWeddingTypePhoto),@"text":@"婚纱写真",@"image":@"category_wedding_photo"}
			  ,@{@"tag":@(WTWeddingTypeCapture),@"text":@"婚礼跟拍",@"image":@"category_wedding_follow"}
			  ,@{@"tag":@(WTWeddingTypeHost),@"text":@"婚礼主持",@"image":@"category_wedding_holder"}
			  ,@{@"tag":@(WTWeddingTypeDress),@"text":@"婚纱礼服",@"image":@"category_wedding_choth"}
			  ,@{@"tag":@(WTWeddingTypeMakeUp),@"text":@"新娘跟妆",@"image":@"category_wedding_sculpt"}
			  ,@{@"tag":@(WTWeddingTypeVideo),@"text":@"婚礼摄像",@"image":@"category_wedding_video"}
			  ,@{@"tag":@(WTWeddingTypeHotel),@"text":@"婚宴酒店",@"image":@"category_wedding_hotel"}]
			mutableCopy];
}

@end
