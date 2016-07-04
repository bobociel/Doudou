//
//  CreateDemandViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTCreateDemandViewController.h"
#import "CommPickView.h"
#import "CommDatePickView.h"
#import "UserInfoManager.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "PostDataService.h"
#import "WTLoginViewController.h"
#import "UserInfoManager.h"
#import "LWAssistUtil.h"
#import "GetService.h"
#import "WTDemandListViewController.h"
#import "WTAlertView.h"
#import "WTProgressHUD.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "PushNotifyCore.h"
#define kDescMaxLength 300
#define kGap 8
#define kButtonWidth (screenWidth - 2 * kGap)
@interface WTCreateDemandViewController ()<CommPickViewDelegate,CommDatePickViewDelegate,UITextViewDelegate>

@end

@implementation WTCreateDemandViewController
{
    TPKeyboardAvoidingScrollView *scrollView;
    NSArray *listArray;
    NSArray *cityIdArray;
    NSArray *serviceTypeIdArray;
    UIButton *chooseServiceTypeBtn;
    UIButton *choosePriceBtn;
    UIButton *chooseCityBtn;
    UIButton *chooseWeddingTime;
    NSArray  *serviceTypePickArr;
    NSMutableArray  *priceArray;
    NSMutableArray  *priceIdArray;
    NSArray  *cityArray;
    int64_t   weddingDay_time;
    UITextView *noteTextView;
    UIButton *commitBtn;
    int cityIndex;
    int serviceTypeIndex;
    int priceRangeIndex;
    CommPickView *pickView;
    CommDatePickView *datePickView;
    UILabel *noteLabel;
    BOOL isFromCurCity;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

-(void)initView{
    self.title=@"创建需求";
	
    serviceTypeIndex = -1;
    cityIndex = -1;
    priceRangeIndex = -1;
    
    UIView *view=[[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:view];
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight - kNavBarHeight)];
    scrollView.clipsToBounds=NO;
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height + 10);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    cityIdArray=[[NSArray alloc]init];
    serviceTypeIdArray=[[NSArray alloc]init];
    priceIdArray=[[NSMutableArray alloc]init];
    priceArray=[[NSMutableArray alloc]init];
    serviceTypePickArr =@[@"婚礼策划",@"婚纱写真",@"婚礼摄影",@"婚礼摄像",@"婚纱礼服",@"新娘跟妆",@"婚礼主持",@"甜品婚品",@"海外婚礼"];
    serviceTypeIdArray=@[@"6",@"11",@"7",@"12",@"9",@"8",@"14",@"17",@"22"];
    cityArray=@[@"杭州",@"北京",@"上海",@"广州",@"南京",@"成都",@"天津",@"深圳",@"青岛",@"重庆",@"苏州",@"长沙",@"郑州",@"西安",@"武汉",@"福州",@"昆明",@"沈阳",@"大连",@"石家庄"];
    cityIdArray=@[@"141",@"504",@"506",@"255",@"128",@"351",@"505",@"257",@"190",@"507",@"132",@"241",@"206",@"404",@"224",@"169",@"381",@"73",@"74",@"39"];
    listArray =[NSArray arrayWithObjects:@"我要找",@"我的预算",@"我的婚期",@"婚礼举办城市", nil];
    for (int i = 0 ; i<listArray.count; i++) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, i*50, 96, 50)];
        label.text=listArray[i];
        label.textColor = rgba(122, 128, 137, 0.5);
        label.textColor=subTitleLableColor;
        label.font = DefaultFont16;
        label.adjustsFontSizeToFitWidth=YES;
        label.textAlignment=NSTextAlignmentLeft;
        [scrollView addSubview:label];
        
        UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(15,  50+i*50, screenWidth-15, 0.5)];
        lineView.backgroundColor=rgba(221, 221, 221, 1.0);;
        [scrollView addSubview:lineView];
    }
    chooseServiceTypeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseServiceTypeBtn.frame=CGRectMake(kGap, 0, kButtonWidth, 50);
    [chooseServiceTypeBtn setTitle:@"请选择服务类型" forState:UIControlStateNormal];
    [chooseServiceTypeBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    chooseServiceTypeBtn.titleLabel.font=DefaultFont16;
    chooseServiceTypeBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [chooseServiceTypeBtn addTarget:self action:@selector(chooseService) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:chooseServiceTypeBtn];
    
    choosePriceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    choosePriceBtn.frame=CGRectMake(kGap, 50, kButtonWidth, 50);
    [choosePriceBtn setTitle:@"请选择价位" forState:UIControlStateNormal];
    [choosePriceBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    choosePriceBtn.titleLabel.font=DefaultFont16;
    choosePriceBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [choosePriceBtn addTarget:self action:@selector(choosePrice) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:choosePriceBtn];
    
    chooseWeddingTime=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseWeddingTime.frame=CGRectMake(kGap, choosePriceBtn.bottom, kButtonWidth, 50);
    
    datePickView = [CommDatePickView viewWithStyle:PickerViewStyleDefault];
    datePickView.delagate=self;

	NSString *weddingTime = [UserInfoManager instance].weddingTime > 0 ? [[UserInfoManager instance] weddingTimeString ] :@"选择婚期" ;

    [chooseWeddingTime setTitle:weddingTime forState:UIControlStateNormal];
	[chooseWeddingTime setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    chooseWeddingTime.titleLabel.font=DefaultFont16;
    chooseWeddingTime.titleLabel.textAlignment=NSTextAlignmentRight;
    [chooseWeddingTime addTarget:self action:@selector(chooseWeddingTime) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:chooseWeddingTime];
    
    chooseCityBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseCityBtn.frame=CGRectMake(kGap, chooseWeddingTime.bottom, kButtonWidth, 50);
    
    if ([UserInfoManager instance].curCityId&&[UserInfoManager instance].curCityId!=0) {
        isFromCurCity = YES;
        [chooseCityBtn addTarget:self action:@selector(chooseCity) forControlEvents:UIControlEventTouchUpInside];
        [chooseCityBtn setTitle:[NSString stringWithFormat:@"%@",[UserInfoManager instance].city_name] forState:UIControlStateNormal];
        [chooseCityBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=DefaultFont16;
        chooseCityBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        [scrollView addSubview:chooseCityBtn];
    }else{
        [chooseCityBtn addTarget:self action:@selector(chooseCity) forControlEvents:UIControlEventTouchUpInside];
        [chooseCityBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
        [chooseCityBtn setTitle:@"请选择城市" forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=DefaultFont16;
        chooseCityBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        chooseCityBtn.titleLabel.adjustsFontSizeToFitWidth=YES;
        [scrollView addSubview:chooseCityBtn];
    }
    commitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    commitBtn.frame = CGRectMake(0, screenHeight- kNavBarHeight - kTabBarHeight, screenWidth, kTabBarHeight);
    commitBtn.backgroundColor = [[WeddingTimeAppInfoManager instance] baseColor];
	[commitBtn setTitle:@"创建" forState:UIControlStateNormal];
	[self.view addSubview:commitBtn];
    [commitBtn addTarget:self action:@selector(commiEvent) forControlEvents:UIControlEventTouchUpInside];
    
    noteTextView=[[UITextView alloc]initWithFrame:CGRectMake(13, chooseCityBtn.bottom+10, screenWidth-2*15, scrollView.height - chooseCityBtn.bottom - commitBtn.height)];
    noteTextView.textColor = rgba(122, 128, 137, 0.5);
    noteTextView.font=DefaultFont16;
    noteTextView.delegate=self;
    noteTextView.text = @"补充备注信息";
    noteTextView.returnKeyType=UIReturnKeyDone;
    noteTextView.layoutManager.allowsNonContiguousLayout = NO;
    [scrollView addSubview:noteTextView];
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    chooseServiceTypeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    chooseCityBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    chooseWeddingTime.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    choosePriceBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    chooseServiceTypeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    chooseCityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    choosePriceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    chooseWeddingTime.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"补充备注信息"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length<1) {
        textView.text = @"补充备注信息";
        textView.textColor = rgba(122, 128, 137, 0.5);
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	if(textView.text.length > kDescMaxLength && textView.markedTextRange == nil){
		textView.text = [textView.text substringToIndex:kDescMaxLength];
	}
}

- (void)tapBackGround {
    
	[self.view endEditing:YES];
}

-(void)chooseService
{
    pickView= [[CommPickView alloc] initWithDataArr:serviceTypePickArr];
    pickView.delagate=self;
    [pickView showWithTag:0];
}

-(void)choosePrice
{
    if ([chooseServiceTypeBtn.titleLabel.text isEqualToString:@"请选择服务类型"]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"请选择服务类型" centerImage:nil];
        alertView.buttonTitles=@[@"确定"];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            if (buttonIndex==0) {
                [alertView close];
            }
        }];
        [alertView show];
        return;
    }else{
        [self showLoadingView];
        [GetService getPriceRangeWithServiceId:[NSString stringWithFormat:@"%@",serviceTypeIdArray[serviceTypeIndex]] WithBlock:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
			[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""];
            [priceArray removeAllObjects];
            [priceIdArray removeAllObjects];
            NSArray *arr = [result objectForKey:@"data"];
            
            for (NSDictionary *dic in arr) {
                
                NSString *content = [dic objectForKey:@"content"];
                NSString *priceId = [dic objectForKey:@"id"];
                [priceArray addObject:content];
                [priceIdArray addObject:priceId];
            }
            if (priceArray.count==0) {
                [priceArray addObject:@"1-2000"];
                [priceIdArray addObject:@"4"];
                pickView=[[CommPickView alloc]initWithDataArr:priceArray];
                pickView.delagate=self;
                [pickView showWithTag:1];
            }else{
                pickView=[[CommPickView alloc]initWithDataArr:priceArray];
                pickView.delagate=self;
                [pickView showWithTag:1];
            }
        }];
    }
}
-(void)chooseWeddingTime{
	[datePickView setCurrentTimeWith:0];
    [datePickView showWithType:PickerViewTypeDateAndTime];
}

-(void)chooseCity{

    pickView=[[CommPickView alloc]initWithDataArr:cityArray];
    pickView.delagate=self;
    [pickView showWithTag:3];
}

- (void)didPickObjectWithIndex:(int)index andTag:(int)tag{
    if (tag==0) {
        
        [chooseServiceTypeBtn setTitle:serviceTypePickArr[index] forState:UIControlStateNormal];
        [chooseServiceTypeBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        chooseServiceTypeBtn.titleLabel.font = DefaultFont16;
        
        
        if (serviceTypeIndex != index) {
            choosePriceBtn.titleLabel.text = @"请选择价位";
            [choosePriceBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
            [choosePriceBtn setTitle:@"      请选择价位" forState:UIControlStateNormal] ;
            priceRangeIndex = -1;
        }
        
        serviceTypeIndex=index;
        
    }
    if (tag==1){
        
        [choosePriceBtn setTitle:priceArray[index] forState:UIControlStateNormal];
        
        [choosePriceBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        choosePriceBtn.titleLabel.font=DefaultFont16;

        priceRangeIndex=index;
        
    }
    if (tag==2) {
        [chooseWeddingTime setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        [chooseWeddingTime setTitle:[NSString stringWithFormat:@"%lld",weddingDay_time] forState:UIControlStateNormal];
        chooseWeddingTime.titleLabel.font=DefaultFont16;
    }
    if (tag==3){

        isFromCurCity = NO;
        [chooseCityBtn setTitle:cityArray[index] forState:UIControlStateNormal];
        [chooseCityBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=DefaultFont16;
        
        cityIndex=index;
    }
}

- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type {
    weddingDay_time = [date timeIntervalSince1970];
    
    [self resetBtnWhileChooseTime ];
}
- (void)resetBtnWhileChooseTime {
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (weddingDay_time>0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:weddingDay_time];
        NSString * dateStr = [dateFormatter stringFromDate:date];
        [chooseWeddingTime setTitle:dateStr forState:UIControlStateNormal];
        [chooseWeddingTime setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
    }
}
-(void)commiEvent{
    
    if ([chooseServiceTypeBtn.titleLabel.text isEqualToString:@"请选择服务类型"]|| serviceTypeIndex == -1) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"请选择服务类型" centerImage:nil];
        alertView.buttonTitles=@[@"确定"];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            if (buttonIndex==0) {
                [alertView close];
            }
        }];
        [alertView show];
        return;
    } else
        if ([choosePriceBtn.titleLabel.text isEqualToString:@"请选择价位"] || priceRangeIndex == -1){
            WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"请选择价位" centerImage:nil];
            alertView.buttonTitles=@[@"确定"];
            [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                if (buttonIndex==0) {
                    [alertView close];
                }
            }];
            [alertView show];
            return;
        } else
            if ([chooseWeddingTime.titleLabel.text isEqualToString:@"请选择婚期"]){
                WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"请选择婚期" centerImage:nil];
                alertView.buttonTitles=@[@"确定"];
                [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                    if (buttonIndex==0) {
                        [alertView close];
                    }
                }];
                [alertView show];
                return;
            } else
                if ([chooseCityBtn.titleLabel.text isEqualToString:@"请选择婚礼举办城市"]){
                    WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"请选择婚礼举办城市" centerImage:nil];
                    alertView.buttonTitles=@[@"确定"];
                    [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                        if (buttonIndex==0) {
                            [alertView close];
                        }
                    }];
                    [alertView show];
                    return;
                }
    [self showLoadingView];
    NSString *cityName;
    if (isFromCurCity) {
        cityName=[NSString stringWithFormat:@"%d",[UserInfoManager instance].curCityId];
    }else{
        if (cityIndex >= 0) {
            cityName=cityIdArray[cityIndex];
        }
        
    }
    
    [PostDataService postDemandWithServiceType:serviceTypeIdArray[serviceTypeIndex] andPriceRange:priceIdArray[priceRangeIndex] andWeddingTime:[NSString stringWithFormat:@"%lld",weddingDay_time] andCity:cityName andNote:(NSString *)noteTextView.text withBlock:^(NSDictionary *dic, NSError *error) {
		[self hideLoadingView];
        if (!error)
		{
			NSString *title=[NSString stringWithFormat:@"创建了 我要找%@需求",chooseServiceTypeBtn.titleLabel.text];
            NSString*resultId=dic[@"data"][@"id"];
            [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                if (ourCov) {
                    [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeCreateDemand andConversationValue:@{@"id":resultId,@"title":title} andCovTitle:title conversation:ourCov push:YES success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }];
			if(_refreshBlock) { self.refreshBlock(YES); }
			[self.navigationController popViewControllerAnimated:YES];
        }
		else
		{
            NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
            [WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


@end
