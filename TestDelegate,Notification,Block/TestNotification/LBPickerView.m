//
//  LBPickerView.m
//  TestNotification
//
//  Created by wangxiaobo on 16/1/15.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "LBPickerView.h"

typedef NS_ENUM(NSInteger, DataType) {
	DataTypeString,
	DataTypeArray,
	DataTypeDictionary
};

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kToolBarHeight 40.0
#define kPickerHeight 200.0
#define KButtonWidth 70.0
#define KSelfHeight (kPickerHeight + kToolBarHeight)
@interface LBPickerView () <UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, assign) DataType dataType;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property (nonatomic, strong) NSMutableDictionary *proviceAndCity;

@property (nonatomic, strong) NSMutableArray *chooedIndexs;
@property (nonatomic, strong) NSMutableArray *chooedTexts;
@end

@implementation LBPickerView

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.chooedIndexs = [NSMutableArray array];
		self.chooedTexts = [NSMutableArray array];
		self.proviceAndCity = [NSMutableDictionary dictionary];
		self.dataDictionary = [NSMutableDictionary dictionary];

		self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, KSelfHeight);
		self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kToolBarHeight)];
		[self addSubview:_toolView];

		self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.doneButton.frame = CGRectMake(kScreenWidth - KButtonWidth, 0, KButtonWidth, kToolBarHeight);
		[self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[self.doneButton setTitle:@"确定" forState:UIControlStateNormal];
		[_toolView addSubview:_doneButton];
		[self.doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
		lineView.backgroundColor = [UIColor lightGrayColor];
		[_toolView addSubview:lineView];
	}
	return self;
}

- (instancetype)initPickerViewWithInfo:(id)arrayOrPlistName andSelectedRows:(NSArray *)selectedRows
{
	self = [self init];
	if(self)
	{
		[self initDataWithInfo:arrayOrPlistName];

		self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kToolBarHeight, kScreenWidth, kPickerHeight)];
		self.pickerView.delegate = self;
		self.pickerView.dataSource = self;
		[self addSubview:_pickerView];

		for(NSInteger i=0 ; i < _dataDictionary.count ; i++)
		{
			[_pickerView selectRow:[selectedRows[i] integerValue] inComponent:i animated:YES];
		}
	}
	return self;
}

- (instancetype)initDatePickerWithDate:(NSDate *)date andDateMode:(UIDatePickerMode)mode
{
	self = [self init];
	if(self)
	{
		self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kToolBarHeight, kScreenWidth, kPickerHeight)];
		self.datePicker.date = date;
		self.datePicker.datePickerMode = mode;
		self.datePicker.timeZone = [NSTimeZone defaultTimeZone];
		[self addSubview:_datePicker];
	}
	return self;
}

- (void)initDataWithInfo:(id)info
{
	if([info isKindOfClass:[NSArray class]])
	{
		self.dataArray = [(NSArray *)info mutableCopy];
	}
	else if([info isKindOfClass:[NSString class]])
	{
		self.dataArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:info ofType:@"plist"]];
	}

	if(_dataArray)
	{
		for (NSInteger i= 0 ; i < _dataArray.count; i++)
		{
			if([_dataArray[i] isKindOfClass:[NSString class]])
			{
				_dataType = DataTypeString;
				[_dataDictionary setValue:_dataArray forKey:@(i).stringValue];
				return ;
			}
			else if([_dataArray[i] isKindOfClass:[NSArray class]])
			{
				_dataType = DataTypeArray;
				[_dataDictionary setValue:_dataArray[i] forKey:@(i).stringValue];
			}

			else if([_dataArray[i] isKindOfClass:[NSDictionary class]])
			{
				_dataType = DataTypeDictionary;
				NSString *key = [_dataArray[i] allKeys][0];
				[_proviceAndCity setValue:_dataArray[i][key] forKey:key ];
			}
		}
	}
}

- (void)done:(UIButton *)btn
{
	[self showOrHide];

	if(_dataType == DataTypeDictionary)
	{
		NSString *pro = _proviceAndCity.allKeys[[_chooedIndexs[0] integerValue]];
		NSString *city = _proviceAndCity[pro][[_chooedIndexs[1] integerValue]];
		self.chooedTexts = [@[pro,city] mutableCopy];
	}
	else
	{
		for (NSInteger i=0; i < _dataDictionary.count ; i++ )
		{
			[self.chooedTexts addObject:_dataDictionary[@(i).stringValue][[_chooedIndexs[i] integerValue]]];
		}
	}
}

#pragma mark UIPickerViewDelegate and UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	if(_dataType == DataTypeDictionary)
	{
		self.chooedIndexs = [@[@(0),@(0)] mutableCopy];
		return 2;
	}

	for (NSInteger i=0; i <_dataDictionary.count; i++)
	{
		[self.chooedIndexs addObject:@(0)];
	}

	return _dataDictionary.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(_dataType == DataTypeDictionary)
	{
		NSInteger selectedPro = [_pickerView selectedRowInComponent:0];
		NSArray *citys = _proviceAndCity[_proviceAndCity.allKeys[selectedPro]];
		return component % 2 == 0 ? _proviceAndCity.allKeys.count : citys.count ;
	}
	return [_dataDictionary[@(component).stringValue] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(_dataType == DataTypeDictionary)
	{
		NSInteger selectedPro = [_pickerView selectedRowInComponent:0];
		NSArray *citys = _proviceAndCity[_proviceAndCity.allKeys[selectedPro]];
		return component % 2 == 0 ? _proviceAndCity.allKeys[row] : citys[row] ;
	}

	return _dataDictionary[@(component).stringValue][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(_dataType == DataTypeDictionary && component % 2 == 0)
	{
		[pickerView reloadComponent:1];
		[pickerView selectRow:0 inComponent:1 animated:YES];
	}

	[self.chooedIndexs insertObject:@(row) atIndex:component];
}

- (void)showOrHide
{
	BOOL needShow = self.frame.origin.y == kScreenHeight ;
	if(needShow) { [[UIApplication sharedApplication].keyWindow addSubview:self]; }
	[UIView animateWithDuration:0.3 delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.alpha = needShow ? 1 : 0;
						 self.transform = needShow ? CGAffineTransformMakeTranslation(0, -KSelfHeight) : CGAffineTransformIdentity;
	} completion:^(BOOL finished) {
		if(!needShow){
			[self removeFromSuperview];
		}
	}];
}


@end
