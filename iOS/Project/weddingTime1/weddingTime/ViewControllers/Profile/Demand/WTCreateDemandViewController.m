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
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.clipsToBounds=NO;
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
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
        label.font=defaultFont16;
        label.adjustsFontSizeToFitWidth=YES;
        label.textAlignment=NSTextAlignmentLeft;
        [scrollView addSubview:label];
        
        UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(15,  50+i*50, screenWidth-15, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [scrollView addSubview:lineView];
    }
    chooseServiceTypeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseServiceTypeBtn.frame=CGRectMake(screenWidth-130, 0, 130, 50);
    [chooseServiceTypeBtn setTitle:@"请选择服务类型" forState:UIControlStateNormal];
    [chooseServiceTypeBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    chooseServiceTypeBtn.titleLabel.font=defaultFont16;
    chooseServiceTypeBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [chooseServiceTypeBtn addTarget:self action:@selector(chooseService) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:chooseServiceTypeBtn];
    
    choosePriceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    choosePriceBtn.frame=CGRectMake(screenWidth-130, 50, 130, 50);
    [choosePriceBtn setTitle:@"请选择价位" forState:UIControlStateNormal];
    [choosePriceBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    choosePriceBtn.titleLabel.font=defaultFont16;
    choosePriceBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [choosePriceBtn addTarget:self action:@selector(choosePrice) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:choosePriceBtn];
    
    chooseWeddingTime=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseWeddingTime.frame=CGRectMake(screenWidth-130, choosePriceBtn.bottom, 130, 50);
    
    datePickView = [[CommDatePickView alloc] init];
    datePickView.delagate=self;


	NSString *weddingTime = [UserInfoManager instance].weddingTime > 0 ? [[UserInfoManager instance] weddingTimeString ] :@"选择婚期" ;

    [chooseWeddingTime setTitle:weddingTime forState:UIControlStateNormal];
	[chooseWeddingTime setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
    chooseWeddingTime.titleLabel.font=defaultFont16;
    chooseWeddingTime.titleLabel.textAlignment=NSTextAlignmentRight;
    [chooseWeddingTime addTarget:self action:@selector(chooseWeddingTime) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:chooseWeddingTime];
    
    chooseCityBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseCityBtn.frame=CGRectMake(screenWidth-130, chooseWeddingTime.bottom, 130, 50);
    
    if ([UserInfoManager instance].curCityId&&[UserInfoManager instance].curCityId!=0) {
        isFromCurCity = YES;
        [chooseCityBtn addTarget:self action:@selector(chooseCity) forControlEvents:UIControlEventTouchUpInside];
        [chooseCityBtn setTitle:[NSString stringWithFormat:@"        %@",[UserInfoManager instance].city_name] forState:UIControlStateNormal];
        [chooseCityBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=defaultFont16;
        chooseCityBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        [scrollView addSubview:chooseCityBtn];
    }else{
        [chooseCityBtn addTarget:self action:@selector(chooseCity) forControlEvents:UIControlEventTouchUpInside];
        [chooseCityBtn setTitleColor:rgba(122, 128, 137, 0.5) forState:UIControlStateNormal];
        [chooseCityBtn setTitle:@"请选择城市" forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=defaultFont16;
        chooseCityBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        chooseCityBtn.titleLabel.adjustsFontSizeToFitWidth=YES;
        [scrollView addSubview:chooseCityBtn];
    }
    commitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    commitBtn.frame=CGRectMake(0, screenHeight-64-50, screenWidth, 50);
    [commitBtn setTitle:@"创建" forState:UIControlStateNormal];
    commitBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [commitBtn addTarget:self action:@selector(commiEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
    
    noteTextView=[[UITextView alloc]initWithFrame:CGRectMake(13, chooseCityBtn.bottom+10, screenWidth-2*15, screenHeight-chooseCityBtn.bottom-commitBtn.height-50)];
    
    noteTextView.textColor=[UIColor colorWithRed:122.0f/255.0f green:128.0f/255.0f blue:137.0f/255.0f alpha:0.5];
    noteTextView.font=defaultFont16;
    noteTextView.delegate=self;
    noteTextView.text=@"补充备注信息";
    noteTextView.returnKeyType=UIReturnKeyDone;
    noteTextView.delegate=self;
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
        textView.textColor = [UIColor colorWithRed:122.0f/255.0f green:128.0f/255.0f blue:137.0f/255.0f alpha:0.5];
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
- (void)tapBackGround {
    
    for(UITextView *textView in scrollView.subviews) {
        if ([textView isKindOfClass:[UITextView class]]) {
            [textView resignFirstResponder];
        }
    }
}
-(void)chooseService{
    
    
    pickView= [[CommPickView alloc] initWithDataArr:serviceTypePickArr];
    pickView.delagate=self;
    [pickView showWithTag:0];
    
    
}
-(void)choosePrice{
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
    datePickView.dataPickView.minimumDate = [NSDate dateWithTimeIntervalSince1970:-INT_MAX];
    [datePickView showWithTag:2];
}


-(void)chooseCity{
    //    NSArray *cityArr=[LWAssistUtil defaultSearchCitys];
    //    NSMutableArray *citys=[NSMutableArray array];
    //    NSDictionary *cityDic=[[NSDictionary alloc]init];
    //    for (int i = 0 ; i<cityArr.count; i++) {
    //        cityDic=cityArr[i];
    //        [citys addObject:cityDic[@"name"]];
    //    }
    pickView=[[CommPickView alloc]initWithDataArr:cityArray];
    pickView.delagate=self;
    [pickView showWithTag:3];
}



- (void)didPickObjectWithIndex:(int)index andTag:(int)tag{
    if (tag==0) {
        
        [chooseServiceTypeBtn setTitle:serviceTypePickArr[index] forState:UIControlStateNormal];
        [chooseServiceTypeBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        chooseServiceTypeBtn.titleLabel.font=defaultFont16;
        
        
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
        choosePriceBtn.titleLabel.font=defaultFont16;
        
        
        priceRangeIndex=index;
        
    }
    if (tag==2) {
        [chooseWeddingTime setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        [chooseWeddingTime setTitle:[NSString stringWithFormat:@"%lld",weddingDay_time] forState:UIControlStateNormal];
        chooseWeddingTime.titleLabel.font=defaultFont16;
    }
    if (tag==3){

        isFromCurCity = NO;
        [chooseCityBtn setTitle:cityArray[index] forState:UIControlStateNormal];
        [chooseCityBtn setTitleColor:[[WeddingTimeAppInfoManager instance] baseColor] forState:UIControlStateNormal];
        chooseCityBtn.titleLabel.font=defaultFont16;
        
        cityIndex=index;
    }
    
    
}
- (void)didPickDataWithDate:(NSDate *)date andTag:(int)tag {
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
        if (!error) {
            NSString *num_demand = [UserInfoManager instance].num_demand;
            int demandNum = num_demand.intValue;
            demandNum++;
            [UserInfoManager instance].num_demand = [NSString stringWithFormat:@"%d", demandNum];
            [[UserInfoManager instance]saveToUserDefaults];
            [[NSNotificationCenter defaultCenter]postNotificationName:UserCommitDemandNotification object:nil];
            [self hideLoadingView];
            WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"发布成功" centerImage:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:UserDidCreateNewDemaind object:nil];
            alertView.buttonTitles=@[@"确定"];
            [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                if (buttonIndex==0) {
                    [alertView close];
                }
            }];
            NSString *title=[NSString stringWithFormat:@"创建了 我要找%@需求",chooseServiceTypeBtn.titleLabel.text];
            
            NSString*resultId=dic[@"data"][@"id"];
            [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                if (ourCov) {
                    [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeCreateDemand andConversationValue:@{@"id":resultId,@"title":title} andCovTitle:title conversation:ourCov push:YES success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }];
            if (self.isFromList) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self.navigationController pushViewController:[WTDemandListViewController new] animated:YES];
            }
        }if (error) {
            NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
            [WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
        }
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


@end
