//
//  CommPickView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommPickView.h"
#import "PostDataService.h"
#define CommPickViewTag  76347678
#define kPickerStyleHeight 250
#define kTableStyleHeight  380
#define kButtonHeight     50
@interface CommPickView() <UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) NSInteger showTag;
@property (nonatomic,strong) UIView    *backgroundView;
@property (nonatomic,strong) UIView    *contentView;
@property (nonatomic,strong) UILabel   *titleLabel;
@property (nonatomic,strong) UIButton  *doneBtn;
@property (nonatomic,strong) UIButton  *cancelBtn;
@property (nonatomic,strong) UIPickerView *pickView;
@property (nonatomic,strong) UITableView *tableView;
@end
@implementation CommPickView

+ (instancetype)instanceWithStyle:(PickViewStyle)style andTag:(NSInteger)tag andArray:(NSArray *)dataArray
{
	CommPickView *pickerView = [[CommPickView alloc] init];
	pickerView.showTag = tag;
	pickerView.dataArray = [NSMutableArray arrayWithArray:dataArray] ? : [NSMutableArray array];
	[pickerView initViewWithStyle:style];
	return pickerView;
}

- (void)initViewWithStyle:(PickViewStyle)style {
    self.tag=CommPickViewTag;
    self.frame=KEY_WINDOW.bounds;

    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor=[UIColor blackColor];
    _backgroundView.alpha=0.f;
    [self addSubview:_backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_backgroundView addGestureRecognizer:tap];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
	_contentView.backgroundColor=[UIColor whiteColor];
    [self addSubview:_contentView];

	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_titleLabel.font = DefaultFont12;
	_titleLabel.textColor = rgba(100, 100, 100, 1);
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	[_contentView addSubview:_titleLabel];

    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_contentView addSubview:_doneBtn];
    [_doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];

	_cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelBtn.backgroundColor = WeddingTimeBaseColor;
	[_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
	[_contentView addSubview:_cancelBtn];
	[_cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];

    if(style == PickViewStylePicker)
    {
		_titleLabel.frame = CGRectZero;
		_tableView.frame = CGRectZero;
		_cancelBtn.frame = CGRectZero;
		_pickView.hidden = NO;
		_contentView.frame = CGRectMake(0, screenHeight-kPickerStyleHeight, screenWidth, kPickerStyleHeight);
        _doneBtn.frame = CGRectMake(screenWidth-70-10, 0, 70, kButtonHeight);

		_pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kButtonHeight, screenWidth, kPickerStyleHeight-kButtonHeight)];
		_pickView.showsSelectionIndicator = YES;
		_pickView.dataSource = self;
		_pickView.delegate = self;
		[_contentView addSubview:_pickView];
		if (self.dataArray.count>=1) { [self.pickView selectRow:0 inComponent:0 animated:YES]; }
    }

    if(style == PickViewStyleTable)
    {
		_doneBtn.frame = CGRectZero;
		_pickView.hidden = YES;
		_titleLabel.text = @"可领取的婚礼宝补贴";
		_titleLabel.frame = CGRectMake(0, 0, screenWidth, kButtonHeight);
		_contentView.frame = CGRectMake(0, screenHeight-kTableStyleHeight, screenWidth, kTableStyleHeight);
		_cancelBtn.frame = CGRectMake(0, kTableStyleHeight-kButtonHeight, screenWidth, kButtonHeight);

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kButtonHeight, screenWidth, kTableStyleHeight-2*kButtonHeight)];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.tableFooterView = [[UIView alloc] init];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		[_contentView addSubview:_tableView];
    }
}

- (void)done {
    [self hide];
    if ([self.delagate respondsToSelector:@selector(didPickObjectWithIndex:andTag:)]) {
        [self.delagate didPickObjectWithIndex:(int)[self.pickView selectedRowInComponent:0] andTag:_showTag];
    }
}

- (void)show {
    if ([KEY_WINDOW viewWithTag:CommPickViewTag]) {
        [[KEY_WINDOW viewWithTag:CommPickViewTag] removeFromSuperview];
    }
    [KEY_WINDOW addSubview:self];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.bottom=self.height;
        _backgroundView.alpha=0.4f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.top=self.height;
        _backgroundView.alpha=0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - PickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataArray[row];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTTicket *ticket = _dataArray[indexPath.row];
	WTTicketCell *cell = [tableView WTTicketCell];
	cell.supplierTicket = ticket;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTTicket *ticket = _dataArray[indexPath.row];
	if(!ticket.has_obtain){
		MBProgressHUD *HUD = [WTProgressHUD showLoadingHUDWithTitle:@"" showInView:KEY_WINDOW];
		[PostDataService postGetTicketWithTicketID:ticket.ID block:^(NSDictionary *result, NSError *error) {
			[HUD hide:YES];
			if(!error && [result[@"success"] boolValue]){
				[WTProgressHUD ShowTextHUD:@"领取优惠券成功，请到婚礼宝查看" showInView:KEY_WINDOW];
			}else{
				[WTProgressHUD ShowTextHUD:result[@"error_message"] showInView:KEY_WINDOW];
			}
		}];
	}
	ticket.has_obtain = YES;
	[tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
