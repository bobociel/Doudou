//
//  WeddingPlanDetailViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanDetailViewController.h"
#import "CommDatePickView.h"
#import "CommPickView.h"
#import "PostDataService.h"
#import "GetService.h"
#import "WTProgressHUD.h"

@interface WeddingPlanDetailViewController ()<UITextViewDelegate,CommDatePickViewDelegate,CommPickViewDelegate>

@end

@implementation WeddingPlanDetailViewController
{
    UIScrollView *mainScrollView;
    unsigned long long close_time;
    unsigned long long remind_time;
    BOOL isFinish;
    UIButton *closeTimeBtn;
    UIButton *remindTimeBtn;
    UIButton *changeStatusBtn;
    UILabel *statusLable;
    UITextField *titleInput;
    UILabel *descriptionPlaceholder;
    UITextView *descriptionTextView;
    CommDatePickView *datePickView;
	CommPickView     *pickerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"婚礼计划";
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
     if(_planId)
    {
        [self showLoadingView:self.view.superview];
        [GetService getWeddingDetailWithId:_planId WithBlock:^(NSDictionary *result, NSError *error) {
             [self hideLoadingView];
             if (error)
			 {
				 NSString *errStr = [LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:@"该计划不存在"];
				 [WTProgressHUD ShowTextHUD:errStr showInView:KEY_WINDOW];
                 [self.navigationController popViewControllerAnimated:YES];
             }
			 else
			 {
                 self.matter= [WTMatter modelWithDictionary:result];
                 [self initView];
             }
         }];
    }
    else
    {
        [self initView];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    descriptionPlaceholder.hidden=YES;
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.contentOffset.x, descriptionTextView.top) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (![textView.text isNotEmptyCtg]) {
        descriptionPlaceholder.hidden=NO;
    }
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.contentOffset.x, 0) animated:YES];
}

- (void)tapBackGround {
    [titleInput resignFirstResponder];
    [descriptionTextView resignFirstResponder];
}

- (void)rightNavBtnEvent
{
	[self tapBackGround];
	if (![titleInput.text isNotEmptyCtg]) {
		[WTProgressHUD ShowTextHUD:@"还没有输入标题哦" showInView:self.view];
		return;
	}
	if (close_time == 0) {
		[WTProgressHUD ShowTextHUD:@"还没有选择计划时间哦" showInView:self.view];
		return;
	}

	if(!self.matter)
	{
		self.matter = [[WTMatter alloc] init];
	}
	self.matter.close_time = close_time;
	self.matter.remind_time = remind_time;
	self.matter.title = [LWUtil getString:titleInput.text andDefaultStr:@""];
	self.matter.desc = [LWUtil getString:descriptionTextView.text andDefaultStr:@""];

	[self showLoadingView];
	[PostDataService postWeddingPlanInfoWithMatter:self.matter withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (!error)
		{
			[WTProgressHUD ShowTextHUD:self.matter ?@"修改成功":@"成功新建计划" showInView:KEY_WINDOW];
			[[NSNotificationCenter defaultCenter] postNotificationName:WeddingPlanShouldBeReloadNotify object:nil];

			self.matter.matter_id = result[@"id"];
			[[WTLocalNoticeManager manager] addNoticeWithObject:self.matter];

			NSString *title = self.matter.matter_id ? @"我修改了计划":@"我安排了一个计划";
			[[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
				if (ourCov) {
					NSDictionary *sendValue = @{@"id":_matter.matter_id,@"type":@"p",@"title":title,@"data":[self.matter modelToJSONString] };
					[ChatConversationManager sendCustomMessageWithPushName:title
													andConversationTypeKey:ConversationTypeInvitePlan
													  andConversationValue:sendValue
															   andCovTitle:title
															  conversation:ourCov
																	  push:YES
																   success:^{

					} failure:^(NSError *error) {

					}];
				}
			}];

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self.navigationController popViewControllerAnimated:YES];
			});
		}
		else
		{
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
		}
	}];
}

#pragma mark - Choose Time
- (NSString *)formatterDateWithTimestamp:(unsigned long long)aTimestamp
{
	double nowTimestamp = [[NSDate date] timeIntervalSince1970] ;
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
	return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:aTimestamp ?: nowTimestamp]] ;
}

- (void)showAlertViewWithText:(NSString *)text
{
	WTAlertView *alertView = [[WTAlertView alloc] initWithText:text centerImage:nil];
	[alertView setButtonTitles:@[@"关闭"]];
	[alertView show];
}

- (void)chooseCloseTime
{
    [self tapBackGround];
	[datePickView setCurrentTimeWith:close_time];
    [datePickView showWithType:PickerViewTypeDate];
}

- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type
{
	close_time = [date timeIntervalSince1970];
	[closeTimeBtn setTitle:[self formatterDateWithTimestamp:close_time] forState:UIControlStateNormal] ;

	if(remind_time > 0){
		remind_time = MAX([[NSDate date] dateByAddingHours:1].timeIntervalSince1970, remind_time);
		remind_time = MIN(remind_time, close_time);
		[remindTimeBtn setTitle:[self formatterDateWithTimestamp:remind_time] forState:UIControlStateNormal];
	}

	if (type == PickerViewTypeDate) {
		[datePickView setCurrentTimeWith:close_time];
		[datePickView showWithType:PickerViewTypeDateAndTime];
	}
}

- (void)chooseRemindTime
{
	[self tapBackGround];
	close_time == 0 ? [self showAlertViewWithText:@"请先设置完成时间"] : [pickerView showWithTag:0];
}

- (void)didPickObjectWithIndex:(int)index andTag:(int)tag
{
	if(index == PickViewTypeCurrentDay){
		remind_time = close_time;
	}else if (index == PickViewTypeBeforeOneDay){
		remind_time = close_time - kOneDay;
	}else if (index == PickViewTypeBeforeOneWeek){
		remind_time = close_time - kOneWeek;
	}

	[remindTimeBtn setTitle:[self formatterDateWithTimestamp:remind_time] forState:UIControlStateNormal];
}

- (void)changeStatusBtnEvent {
    if (!_matter) { return; }

    [self showLoadingView];
	[PostDataService postWeddingPlanChangeStatusWithMatterId:_matter.matter_id
												   andStatus:!isFinish ? WTMatterStatusFinished : WTMatterStatusUnFinished
												   withBlock:^(NSDictionary *result, NSError *error)
	{
        [self hideLoadingView];
        if (!error) {
            isFinish=!isFinish;
			changeStatusBtn.selected = isFinish;
			_matter.status = isFinish ? WTMatterStatusFinished : WTMatterStatusUnFinished;
            statusLable.text = isFinish?@"已完成":@"未完成";
			statusLable.textColor = isFinish ? WeddingTimeBaseColor : [UIColor lightGrayColor];
			isFinish ? [[WTLocalNoticeManager manager] removeNoticeWithClassType:[WTMatter class] andID:self.matter.matter_id] : [[WTLocalNoticeManager manager] addNoticeWithObject:self.matter];

            NSString *title=isFinish?@"完成计划":@"重置计划状态";
            [[ChatMessageManager instance] sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                if (ourCov) {
					NSDictionary *sendValue = @{@"id":_matter.matter_id,@"type":@"p",@"title":title,@"data":[self.matter modelToJSONString] };
                    [ChatConversationManager sendCustomMessageWithPushName:title
													andConversationTypeKey:ConversationTypeInvitePlan
													  andConversationValue:sendValue
															   andCovTitle:title
															  conversation:ourCov push:YES success:^{
                    } failure:^(NSError *error) {
                    }];
                }
            }];
			[[NSNotificationCenter defaultCenter] postNotificationName:WeddingPlanShouldBeReloadNotify object:nil];
        }
		else
		{
            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
        }
    }];
}


- (void)initView
{
    float leftGap = 20;

    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:mainScrollView];
	[mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(self.view);
	}];
	mainScrollView.contentSize = CGSizeMake(screenWidth, screenHeight - kNavBarHeight + 1);

    titleInput = [[UITextField alloc] init];
    titleInput.textColor = titleLableColor;
	titleInput.adjustsFontSizeToFitWidth = YES;
	titleInput.placeholder = @"计划名称";
    [mainScrollView addSubview:titleInput];
	[titleInput mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(mainScrollView.mas_top).offset(30.0);
		make.left.equalTo(self.view.mas_left).offset(leftGap);
		make.right.equalTo(self.view.mas_right).offset(-leftGap);
		make.height.mas_equalTo(30.0);
	}];

    UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed :@"icon_setWeddingTime_pink"]];

    closeTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	closeTimeBtn.tag=0;
    closeTimeBtn.titleLabel.font = DefaultFont16;
    closeTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[closeTimeBtn setTitle:@"设置完成时间" forState:UIControlStateNormal];
    [closeTimeBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    [closeTimeBtn addTarget:self action:@selector(chooseCloseTime) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:closeImageView];
    [mainScrollView addSubview:closeTimeBtn];

	[closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(titleInput.mas_bottom).offset(20.0);
		make.left.equalTo(self.view.mas_left).offset(leftGap);
		make.size.mas_equalTo(CGSizeMake(16.0, 16.0));
	}];

	[closeTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(closeImageView.mas_centerY);
		make.left.equalTo(closeImageView.mas_right).offset(5.0);
		make.right.equalTo(self.view.mas_right).offset(-leftGap);
		make.height.mas_equalTo(32.0);
	}];
    
    UIImageView *remindImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed :@"icon_weddingClock_pink"]];
    remindTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    remindTimeBtn.tag=1;
    remindTimeBtn.titleLabel.font = DefaultFont16;
    remindTimeBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
	[remindTimeBtn setTitle:@"设置提醒时间" forState:UIControlStateNormal];
    [remindTimeBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    [remindTimeBtn addTarget:self action:@selector(chooseRemindTime) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:remindImageView];
    [mainScrollView addSubview:remindTimeBtn];

	[remindImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(closeTimeBtn.mas_bottom).offset(10.0);
		make.left.equalTo(self.view.mas_left).offset(leftGap);
		make.size.mas_equalTo(CGSizeMake(16.0, 16.0));
	}];

	[remindTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(remindImageView.mas_centerY);
		make.left.equalTo(remindImageView.mas_right).offset(5.0);
		make.right.equalTo(self.view.mas_right).offset(-leftGap);
		make.height.mas_equalTo(32.0);
	}];
    
    descriptionPlaceholder = [[UILabel alloc] init];
    descriptionPlaceholder.text = @"输入计划描述";
    descriptionPlaceholder.font = DefaultFont16;
    descriptionPlaceholder.textColor=[LWUtil colorWithHexString:@"#C6C6C6"];
    [mainScrollView addSubview:descriptionPlaceholder];

	[descriptionPlaceholder mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(remindTimeBtn.mas_bottom).offset(20.0);
		make.left.equalTo(self.view.mas_left).offset(leftGap);
		make.right.equalTo(self.view.mas_right).offset(-leftGap);
		make.height.mas_equalTo(30.0);
	}];
    
    descriptionTextView = [[UITextView alloc] init];
    descriptionTextView.backgroundColor=[UIColor clearColor];
    [mainScrollView addSubview:descriptionTextView];
    descriptionTextView.delegate=self;
    descriptionTextView.font = DefaultFont16;
    descriptionTextView.textColor=subTitleLableColor;

	[descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(remindTimeBtn.mas_bottom).offset(20.0);
		make.left.equalTo(self.view.mas_left).offset(leftGap);
		make.right.equalTo(self.view.mas_right).offset(-leftGap);
		make.height.mas_equalTo(100.0);
	}];

    if (self.matter)
	{
		self.title=@"计划详情";
		[self setRightBtnWithTitle:@"保存"];

		isFinish = _matter.status == WTMatterStatusUnFinished ? NO:YES;
		close_time = self.matter.close_time;
		remind_time = self.matter.remind_time ;
		titleInput.text=self.matter.title ;
		descriptionTextView.text = self.matter.desc;
		descriptionPlaceholder.hidden = self.matter.desc.length != 0;

		if(close_time > 0){
			[closeTimeBtn setTitle:[self formatterDateWithTimestamp:close_time] forState:UIControlStateNormal];
		}
		if(remind_time > 0){
			[remindTimeBtn setTitle:[self formatterDateWithTimestamp:remind_time] forState:UIControlStateNormal];
		}

        changeStatusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		changeStatusBtn.selected = isFinish;
		[changeStatusBtn setImage:[UIImage imageNamed :@"icon_wedding_unfinish"] forState:UIControlStateNormal];
		[changeStatusBtn setImage:[UIImage imageNamed :@"icon_wedding_finish"] forState:UIControlStateSelected];
        [changeStatusBtn addTarget:self action:@selector(changeStatusBtnEvent) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:changeStatusBtn];
		[changeStatusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.mas_centerX).offset(0);
			make.bottom.equalTo(self.view.mas_bottom).offset(-50.0);
			make.size.mas_equalTo(CGSizeMake(64, 64));
		}];

        statusLable = [[UILabel alloc] init];
        statusLable.textAlignment = NSTextAlignmentCenter;
		statusLable.textColor = [UIColor lightGrayColor];
        statusLable.font = DefaultFont16;
        statusLable.text = isFinish ? @"已完成":@"未完成";
		statusLable.textColor = isFinish ? [WeddingTimeAppInfoManager instance].baseColor : [UIColor lightGrayColor];
        [mainScrollView addSubview:statusLable];
		[statusLable mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.mas_centerX).offset(0);
			make.top.equalTo(changeStatusBtn.mas_bottom).offset(5.0);
			make.size.mas_equalTo(CGSizeMake(100.0, 20.0));
		}];
    }
	else
	{
        self.title=@"创建新计划";
		[self setRightBtnWithTitle:@"完成"];
    }
    
    datePickView = [CommDatePickView viewWithStyle:PickerViewStyleDefault];
	datePickView.dataPickView.date =  [NSDate date];
    datePickView.delagate = self;

	pickerView = [[CommPickView alloc] initWithDataArr:@[@"当天",@"提前一天",@"提前一周"]];
	pickerView.delagate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}


@end
