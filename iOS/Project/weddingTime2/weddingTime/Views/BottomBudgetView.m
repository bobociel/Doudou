//
//  BottomView.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BottomBudgetView.h"
#import "CommDatePickView.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
#import "PostDataService.h"
#define kRightGap 188.0
#define kRightGapB 40.0
@interface BottomBudgetView ()
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;
@property (weak, nonatomic) IBOutlet UIButton *budgetBtn;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *price;
@end
@implementation BottomBudgetView

+ (instancetype)bootomViewInView:(UIView *)superView
{
	BottomBudgetView *view = (BottomBudgetView *)[[NSBundle mainBundle] loadNibNamed:@"BottomBudgetView" owner:self options:nil][0];
	view.backgroundColor = WeddingTimeBaseColor;
	view.frame = CGRectMake(0, superView.frame.size.height - kBottomViewHeight , screenWidth, kBottomViewHeight);
	return view;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.backgroundColor = WeddingTimeBaseColor;
	_companyLabel.text = @"";
	_priceLabel.text = @"";
	_companyLabel.font = DefaultFont18;
	_priceLabel.font = DefaultFont14;
}

- (void)setCate:(WTWeddingType)cate
{
	_company = [LWAssistUtil defaultCategory][@(cate).stringValue];
	_price = [UserInfoManager instance].budgetInfo[@(cate).stringValue];
	if([LWUtil getString:_company andDefaultStr:@""].length > 0){
		_companyLabel.text = [NSString stringWithFormat:@"我的%@预算",_company];
	}
	_priceLabel.text = _price.intValue == 0 ? @"暂未设置预算" : [NSString stringWithFormat:@"￥%@",_price] ;
}

- (IBAction)budgetAction:(UIButton *)sender
{
	if (![LWAssistUtil isLogin]) { return; }
	if([self.mainDelegate respondsToSelector:@selector(bottomBudgetViewBudgetSelected)])
	{
		[self.mainDelegate bottomBudgetViewBudgetSelected];
	}
}
@end
