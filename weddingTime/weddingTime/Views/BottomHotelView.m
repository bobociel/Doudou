//
//  BottomHotelView.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BottomHotelView.h"
#import "CommDatePickView.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
#import "PostDataService.h"
#define kRightGap 188.0
#define kRightGapB 40.0
@interface BottomHotelView () <CommDatePickViewDelegate>
@property (nonatomic, strong) CommDatePickView *datePicker;
@end
@implementation BottomHotelView

+ (instancetype)bootomViewInView:(UIView *)superView
{
	BottomHotelView *view = (BottomHotelView *)[[NSBundle mainBundle] loadNibNamed:@"BottomHotelView" owner:self options:nil][0];
	view.frame = CGRectMake(0, superView.frame.size.height - kBottomViewHeight , screenWidth, kBottomViewHeight);
	return view;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (IBAction)telAction
{
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView mp_setImageWithURL:self.supplier_avatar placeholderImage:[UIImage imageNamed:@"male_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:@"是否拨打该商家电话" centerImage:image];
        alert.buttonTitles = @[@"取消", @"拨打"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            [alert close];
			if (index == 1) {
                if ([self.tel_num isNotEmptyCtg]) {
                    NSString *str = [NSString stringWithFormat:@"tel://%@", _tel_num];
                    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]) {
                        [WTProgressHUD ShowTextHUD:@"号码无效" showInView:KEY_WINDOW];
                        return;
                    }
                } else {
                    [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
                }
            }
        };
        [alert show];
    }];
}

- (IBAction)covAction
{
	if (![LWAssistUtil isLogin]) { return; }
	if([self.mainDelegate respondsToSelector:@selector(bottomHotelViewConversationSelected)]){
		[self.mainDelegate bottomHotelViewConversationSelected];
	}
}

- (IBAction)checkAction:(UIControl *)sender
{
	if (![LWAssistUtil isLogin]) { return; }
	_datePicker = [CommDatePickView viewWithStyle:PickerViewStyleRedSure];
	_datePicker.delagate = self;
	[_datePicker showWithType:PickerViewTypeDefault];
}

- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type
{
	NSString *messgaeS = @"";
	if(type == PickerViewTypeDefault)
	{
		[LWUtil getString:@"" andDefaultStr:@""];
		messgaeS = [NSString stringWithFormat:@"请问%@有%@的档期吗？",
					[LWUtil getString:_supplier_name andDefaultStr:@""],
					[LWUtil getDateSringCYMD:date]];
		[PostDataService postSetWeddingTime:[date timeIntervalSince1970]
								  WithBlock:^(NSDictionary *result, NSError *error) { }];
	}
	else if (type == PickerViewTypeCate)
	{
		messgaeS = _datePicker.resultString;
	}
	if([self.mainDelegate respondsToSelector:@selector(bottomHotelViewCheckSelectedWithDateString:)]){
		[self.mainDelegate bottomHotelViewCheckSelectedWithDateString:messgaeS];
	}
}

@end
