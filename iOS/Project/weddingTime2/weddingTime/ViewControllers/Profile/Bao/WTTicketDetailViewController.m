//
//  WTTicketDetailViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTTicketDetailViewController.h"
#import "WTWithdrawInfoViewController.h"
#import "WTAboutBaoViewController.h"
#import "WTWithdrawView.h"
#import "GetService.h"
#define kHeadViewHeight     160.0
#define kWithdrawViewHeight 80.0
#define kLeftLabelWidth   80.0
#define kLeftLabelHeight  50.0
#define kRightLabelHeight 50.0
#define kGap 15
#define kLeft ( kGap + kLeftLabelWidth)
@interface WTTicketDetailViewController ()
@property (nonatomic,strong) WTWithdrawView *withdrawView;
@property (nonatomic,strong) UIView  *headView;
@property (nonatomic,strong) UILabel *priceLabel;
@property (nonatomic,strong) UILabel *stateLabel;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *codeImageView;
@property (nonatomic,strong) UILabel *companyLabel;
@property (nonatomic,strong) UILabel *descLabel;
@property (nonatomic,strong) UILabel *expireLabel;
@property (nonatomic,strong) UILabel *withdrawWay;
@property (nonatomic,strong) UILabel *withdrawAccount;
@property (nonatomic,strong) UIButton *withdrawBtn;
@property (nonatomic,strong) NSMutableArray *leftTitles;
@property (nonatomic,strong) WTTicket *ticket;
@end

@implementation WTTicketDetailViewController

+ (instancetype)instanceWithTicket:(WTTicket *)ticket
{
	WTTicketDetailViewController *VC = [WTTicketDetailViewController new];
	ticket.company = [LWUtil getString:ticket.company andDefaultStr:@""];
	ticket.avatar = [LWUtil getString:ticket.avatar andDefaultStr:@""];
	VC.ticket = ticket;
	return VC;
}

+ (instancetype)instanceWithTicketID:(NSString *)ticketID
{
	WTTicketDetailViewController *VC = [WTTicketDetailViewController new];
	VC.ticket = [[WTTicket alloc] init];
	VC.ticket.status = WTTicketStateNone;
	VC.ticket.ID = [LWUtil getString:ticketID andDefaultStr:@""];
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupView];
	[self loadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:CouponChange object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}

- (void)reloadData
{
	[self.view removeAllSubviews];
	[self setupView];
	[self loadData];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getTicketDetailWithTicketID:_ticket.ID block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.scrollView];
		if(!error && [result[@"success"] boolValue]){
			WTTicket *ticket = [WTTicket modelWithDictionary:result[@"data"]];

			if(ticket.status != _ticket.status && _ticket.status != WTTicketStateNone){
				if(_ticket.status == WTTicketStateNoUsed && ticket.status != WTTicketStateNoUsed)
				{
					if(_usedBlock) { self.usedBlock(_ticket);}
					WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"该优惠券已使用" centerImage:nil];
					[alertView setButtonTitles:@[@"确认"]];
					[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
						[alertView close];
						[self.navigationController popViewControllerAnimated:YES];
					}];
					[alertView show];
				}
				else if (ticket.status == WTTicketStateWithdrew && _ticket.status != WTTicketStateWithdrew)
				{
					if(_refreshBlock) { self.refreshBlock(nil);}
					WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"该优惠券已提现" centerImage:nil];
					[alertView setButtonTitles:@[@"确认"]];
					[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
						[alertView close];
						[self.navigationController popViewControllerAnimated:YES];
					}];
					[alertView show];
				}
				else
				{
					_ticket = ticket;
					if(_refreshBlock) { self.refreshBlock(ticket); }
				}
			}else{
				_ticket = ticket;
			}
			[self updateInfo];
		}else{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@"网络出错，请稍后重试"];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.scrollView];
			[NetWorkingFailDoErr errWithView:self.scrollView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

- (void)updateInfo
{
	_priceLabel.text = [LWUtil stringWithPrice:_ticket.amount];
	_stateLabel.text = [LWUtil getString:_ticket.state_name andDefaultStr:@""];
    _expireLabel.text = [NSString stringWithFormat:@"过期时间%@",_ticket.expire_time];
    _companyLabel.text = [LWUtil getString:_ticket.company andDefaultStr:@""] ;
    _descLabel.text = [LWUtil getString:_ticket.desc andDefaultStr:@""] ;
    _withdrawWay.text = @"支付宝";
	_withdrawAccount.text = [LWUtil getString:_ticket.alipay_account andDefaultStr:@""];

	if((_ticket.status == WTTicketStateNoUsed)){
		CGSize descSize = [_descLabel.text sizeForFont:DefaultFont14 size:CGSizeMake(screenWidth-40, MAXFLOAT) mode:NSLineBreakByWordWrapping];
		_descLabel.height = ceil(descSize.height);
	}
}

#pragma mark - Action

- (void)answerAction:(UIButton *)sender
{
	[self.navigationController pushViewController:[WTAboutBaoViewController new] animated:YES];
}

- (void)withDrawAction
{
    WTWithdrawInfoViewController *VC = [WTWithdrawInfoViewController instanceWithTicket:_ticket];
    [VC setBlock:^(WTTicket *ticket) {
        if(self.refreshBlock){ self.refreshBlock(_ticket); }
        self.ticket = ticket;
        [self.view removeAllSubviews];
        [self setupView];
        [self updateInfo];
    }];
	[self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - View
- (void)setupView
{
	[self setupHeadView];
	[self addTapButtonWhite];

	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kHeadViewHeight, screenWidth, screenHeight - kHeadViewHeight)];
	_scrollView.backgroundColor = WHITE;
	[self.view addSubview:_scrollView];

	if(_ticket.status == WTTicketStateNoUsed){
		[self setupQRCodeView];
	}
	else if(_ticket.status == WTTicketStateNoWithdraw){
		[self setupWithdrawView];
	}else if(_ticket.status != WTTicketStateNone){
		[self setupWithdrawProView];
	}
	[self updateInfo];
}

//未使用界面
- (void)setupQRCodeView
{
	_scrollView.backgroundColor = WeddingTimeBaseColor;
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, screenWidth-30, 1)];
	lineView.backgroundColor = rgba(255, 255, 255, 0.4);
	[_scrollView addSubview:lineView];

	UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lineView.bottom+30, screenWidth, 18)];
	noteLabel.font = DefaultFont16;
	noteLabel.textColor = WHITE;
	noteLabel.textAlignment = NSTextAlignmentCenter;
	noteLabel.text = @"到店扫描二维码即可提现婚礼宝补贴";
	[_scrollView addSubview:noteLabel];

	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, noteLabel.bottom+15, screenWidth, 18)];
	_expireLabel.font = DefaultFont12;
	_expireLabel.textColor = WHITE;
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	[_scrollView addSubview:_expireLabel];

	_codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-200)/2.0, _expireLabel.bottom+50, 200, 200)];
	_codeImageView.image = [self setupQRCodeWithTicketID:_ticket.ID andSID:_ticket.supplier_user_id];
	[_scrollView addSubview:_codeImageView];

	_descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _codeImageView.bottom+15, screenWidth-40, 16)];
	_descLabel.numberOfLines = 0;
	_descLabel.font = DefaultFont14;
	_descLabel.textColor = WHITE;
	_descLabel.textAlignment = NSTextAlignmentCenter;
	[_scrollView addSubview:_descLabel];

	_companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _descLabel.bottom+15, screenWidth, 18)];
	_companyLabel.font = DefaultFont14;
	_companyLabel.textColor = WHITE;
	_companyLabel.textAlignment = NSTextAlignmentCenter;
	[_scrollView addSubview:_companyLabel];
	_scrollView.contentSize = CGSizeMake(screenWidth, MAX(_scrollView.height, _companyLabel.bottom + 15));
}

//申请提现界面
- (void)setupWithdrawView
{
	_leftTitles = [@[@"婚礼宝商家",@"详情"] mutableCopy];
	for (int i = 0; i < _leftTitles.count; i++) {
		NSString *title = _leftTitles[i];
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kGap, kGap + kLeftLabelHeight * i, kLeftLabelWidth, kLeftLabelHeight)];
		titleLabel.tag =i;
		titleLabel.textAlignment = NSTextAlignmentLeft;
		titleLabel.font = DefaultFont14;
		titleLabel.textColor = rgba(102, 102, 102, 1);
		titleLabel.text = title;
		[_scrollView addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kGap, titleLabel.bottom, screenWidth-kGap*2, 1)];
        lineView.backgroundColor = rgba(220, 220, 220, 1);
        [_scrollView addSubview:lineView];
	}

	_companyLabel = [self setupLaeblWithX:kLeft andY:kGap];
	_descLabel = [self setupLaeblWithX:kLeft andY:kGap + kLeftLabelHeight];
	_descLabel.numberOfLines = 0;
	_scrollView.contentSize = CGSizeMake(screenWidth, _descLabel.bottom + 15);

	_withdrawBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_withdrawBtn.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	_withdrawBtn.backgroundColor = WeddingTimeBaseColor;
	_withdrawBtn.titleLabel.font = DefaultFont18;
	[_withdrawBtn setTitleColor:WHITE forState:UIControlStateNormal];
	[_withdrawBtn setTitle:@"我要提现" forState:UIControlStateNormal];
	[self.view addSubview:_withdrawBtn];
	[_withdrawBtn addTarget:self action:@selector(withDrawAction) forControlEvents:UIControlEventTouchUpInside];
}

//提现界面
- (void)setupWithdrawProView
{
    _scrollView.frame = CGRectMake(0, kHeadViewHeight + kWithdrawViewHeight, screenWidth, screenHeight - kHeadViewHeight - kWithdrawViewHeight);
	_withdrawView = [[WTWithdrawView alloc] initWithFrame:CGRectMake(0, kHeadViewHeight, screenWidth, kWithdrawViewHeight)];
	_withdrawView.state = _ticket.status;
	[self.view addSubview:_withdrawView];

	_leftTitles = [@[@"婚礼宝商家",@"详情",@"提现方式",@"提现账号"] mutableCopy];

	for (int i = 0; i < _leftTitles.count; i++) {
		NSString *title = _leftTitles[i];
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kGap, kGap + kLeftLabelHeight * i, kLeftLabelWidth, kLeftLabelHeight)];
		titleLabel.tag =i;
		titleLabel.textAlignment = NSTextAlignmentLeft;
		titleLabel.font = DefaultFont14;
		titleLabel.textColor = rgba(102, 102, 102, 1);
		titleLabel.text = title;
		[_scrollView addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kGap, titleLabel.bottom, screenWidth-kGap*2, 1)];
        lineView.backgroundColor = rgba(220, 220, 220, 1);
        [_scrollView addSubview:lineView];
	}

	_companyLabel = [self setupLaeblWithX:kLeft andY:kGap];
	_descLabel = [self setupLaeblWithX:kLeft andY:kGap + kLeftLabelHeight];
	_withdrawWay = [self setupLaeblWithX:kLeft andY:kGap + kLeftLabelHeight * 2];
	_withdrawAccount = [self setupLaeblWithX:kLeft andY:kGap + kLeftLabelHeight * 3];
	_scrollView.contentSize = CGSizeMake(screenWidth, MAX(_scrollView.height, _withdrawAccount.bottom + 15));
}

- (void)setupHeadView
{
	_headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kHeadViewHeight)];
	_headView.backgroundColor = WeddingTimeBaseColor;
	[self.view addSubview:_headView];

	UIButton *answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	answerBtn.frame = CGRectMake(screenWidth-22-17, 32, 22, 22);
	[answerBtn setImage:[UIImage imageNamed:@"icon_answer"] forState:UIControlStateNormal];
	[_headView addSubview:answerBtn];
	[answerBtn addTarget:self action:@selector(answerAction:) forControlEvents:UIControlEventTouchUpInside];

	_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 68, screenWidth, 32)];
	_priceLabel.font = DefaultFont30;
	_priceLabel.textColor = [UIColor whiteColor];
	_priceLabel.textAlignment = NSTextAlignmentCenter;
	[_headView addSubview:_priceLabel];

	_stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _priceLabel.bottom + 10, screenWidth, 20)];
	_stateLabel.font = DefaultFont18;
	_stateLabel.textColor = [UIColor whiteColor];
	_stateLabel.textAlignment = NSTextAlignmentCenter;
	[_headView addSubview:_stateLabel];
}

- (UILabel *)setupLaeblWithX:(CGFloat)x andY:(CGFloat)y
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y,(screenWidth - kGap - x), kRightLabelHeight)];
	label.font = DefaultFont14;
	label.textColor = rgba(102, 102, 102, 1);
	label.textAlignment = NSTextAlignmentRight;
	[_scrollView addSubview:label];

	return label;
}

//生成二维码
- (UIImage *)setupQRCodeWithTicketID:(NSString *)ID andSID:(NSString *)SID
{
	NSString *content = [[@{@"user_id":[UserInfoManager instance].userId_self,@"receive_id":ID,@"supplier_user_id":SID} modelToJSONString] base64EncodedString];
	
	CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
	[filter setValue:[content dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];

	CIImage *transformImage = [filter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
	return [UIImage imageWithCIImage:transformImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
