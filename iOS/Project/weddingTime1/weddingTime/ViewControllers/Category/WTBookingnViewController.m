//
//  WTBookingnViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/16.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBookingnViewController.h"
#import <UIImageView+WebCache.h>
#import "CommPickView.h"
#import "CommDatePickView.h"
#import "WTProgressHUD.h"
#import "PostDataService.h"
#import "WTOrderDetailViewController.h"
#import "NotificationTopPush.h"
@interface WTBookingnViewController ()<CommPickViewDelegate, CommDatePickViewDelegate>


@end

@implementation WTBookingnViewController
{
    UIImageView *imageView;
    UILabel *nameLabel;
    UILabel *cateLabel;
    UIButton *payButton;
    UILabel *timeLabel;
    UILabel *cityLabel;
    NSArray *cityArray;
    NSArray *cityIdArray;
    int cityIndex;
    CommPickView *pickView;
    CommDatePickView *datePickView;
    int64_t   weddingDay_time;
    BOOL cityFlag;
    BOOL timeFlag;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)initView
{
    [self addPayButton];
    imageView = [UIImageView new];
    [self.view addSubview:imageView];
    imageView.layer.cornerRadius = 40 * Width_ato;
    imageView.layer.masksToBounds = YES;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * Height_ato);
//        make.centerX.mas_equalTo(ws);
        make.left.mas_equalTo(167 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(80 * Width_ato, 80 * Width_ato));
    }];
    [imageView sd_setImageWithURL:[NSURL URLWithString:_image_url] placeholderImage:[UIImage imageNamed:@"supplier"]];
    
    nameLabel = [UILabel new];
    [self.view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(130 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(23 * Height_ato);
    }];
    nameLabel.text = _name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = rgba(51, 51, 51, 1);
    nameLabel.font = [WeddingTimeAppInfoManager fontWithSize:18];
    
    cateLabel = [UILabel new];
    [self.view addSubview:cateLabel];
    cateLabel.textAlignment = NSTextAlignmentCenter;
    cateLabel.textColor = rgba(170, 170, 170, 1);
    [cateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(170 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(14 * Height_ato);
    }];
    cateLabel.text = [NSString stringWithFormat:@"%@·%@", _location, _cate];
    cateLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    
    
    UILabel *prob_time = [UILabel new];
    [self.view addSubview:prob_time];
    [prob_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(229 * Height_ato);
        make.left.mas_equalTo(15 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
        make.width.mas_equalTo(100 * Width_ato);
    }];
    prob_time.font = [WeddingTimeAppInfoManager fontWithSize:14];
    prob_time.textColor = rgba(102, 102, 102, 1);
    prob_time.text = @"预约的婚期";
    
    UILabel *prob_city = [UILabel new];
    [self.view addSubview:prob_city];
    [prob_city mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(279* Height_ato);
        make.left.mas_equalTo(15 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
        make.width.mas_equalTo(150 * Width_ato);
    }];
    prob_city.font = [WeddingTimeAppInfoManager fontWithSize:14];
    prob_city.textColor = rgba(102, 102, 102, 1);
    prob_city.text = @"婚礼举办城市";
    
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(15 * Width_ato, 255 * Height_ato, screenWidth - 15 * Width_ato, 0.5)];
    [LWAssistUtil imageViewSetAsLineView:levelImage color:rgba(221, 221, 221, 1)];
    [self.view addSubview:levelImage];
    UIImageView *levelImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(15 * Width_ato, 305 * Height_ato, screenWidth - 15 * Width_ato, 0.5)];
    [LWAssistUtil imageViewSetAsLineView:levelImage2 color:rgba(221, 221, 221, 1)];
    [self.view addSubview:levelImage2];
    
    timeLabel = [UILabel new];
    timeLabel.textColor = rgba(102, 102, 102, 1);
    timeLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.view addSubview:timeLabel];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(229 * Height_ato);
        make.left.mas_equalTo(150 * Width_ato);
        make.right.mas_equalTo(-20 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
    }];
    timeLabel.text = @"请选择婚期";
    timeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeTapAction)];
    [timeLabel addGestureRecognizer:tap];
    
    cityLabel = [UILabel new];
    cityLabel.userInteractionEnabled = YES;
    cityLabel.textColor = rgba(102, 102, 102, 1);
    cityLabel.text = @"请选择婚礼举办城市";
    cityLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.view addSubview:cityLabel];
    cityLabel.textAlignment = NSTextAlignmentRight;
    [cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(280 * Height_ato);
        make.left.mas_equalTo(150 * Width_ato);
        make.right.mas_equalTo(-20 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
    }];
    UITapGestureRecognizer *cityTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityTapAction)];
    [cityLabel addGestureRecognizer:cityTap];
    
}

- (void)addPayButton
{
    payButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    payButton.frame = CGRectMake(0, screenHeight - 50 * Height_ato , screenWidth, 50 * Height_ato);
    [self.view addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50 * Height_ato);
    }];
    [payButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [payButton setTitleColor:WHITE forState:UIControlStateNormal];
    [payButton setTitle:@"预约" forState:UIControlStateNormal];
    payButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    [payButton setBackgroundColor:rgba(210, 210, 210, 1)];
//    [payButton setBackgroundColor:WeddingTimeBaseColor];
}



- (void)loadData{
    datePickView = [[CommDatePickView alloc] init];
    datePickView.delagate = self;
    cityArray=@[@"杭州",@"北京",@"上海",@"广州",@"南京",@"成都",@"天津",@"深圳",@"青岛",@"重庆",@"苏州",@"长沙",@"郑州",@"西安",@"武汉",@"福州",@"昆明",@"沈阳",@"大连",@"石家庄"];

    cityIdArray=@[@"141",@"504",@"506",@"255",@"128",@"351",@"505",@"257",@"190",@"507",@"132",@"241",@"206",@"404",@"224",@"169",@"381",@"73",@"74",@"39"];
    pickView=[[CommPickView alloc]initWithDataArr:cityArray];
    pickView.delagate=self;
}

- (void)orderAction
{
   
   [PostDataService postReserveSupplier_id:self.supplier_id order_source:@(2) weddingCityId:cityIdArray[cityIndex] time:weddingDay_time type:self.isfrom_type source_id:self.work_id WithBlock:^(NSDictionary *result, NSError *error) {
       if (!error) {
           [WTProgressHUD ShowTextHUD:@"预约成功" showInView:KEY_WINDOW];
           NSString *str = [UserInfoManager instance].num_order;
           int num_order = str.intValue;
           num_order++;
           [UserInfoManager instance].num_order = [NSString stringWithFormat:@"%d", num_order];
           [[UserInfoManager instance] saveToUserDefaults];
           WTOrderDetailViewController *detail = [[WTOrderDetailViewController alloc] init];
           NSString *order_id=[LWUtil getString:result[@"out_trade_no"] andDefaultStr:@""];
           detail.order_id =order_id;
           NSString *title=[NSString stringWithFormat:@"我预定了 %@",_name];
           
           [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
               if (ourCov) {
                   [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeCreateOrder andConversationValue:@{@"id":order_id,@"title":title} andCovTitle:title conversation:ourCov push:YES success:^{
                       
                   } failure:^(NSError *error) {
                       
                   }];
               }
           }];
           
           if ([order_id isNotEmptyCtg]) {
               [self.navigationController setNavigationBarHidden:NO animated:YES];
               [self.navigationController pushViewController:detail animated:YES];
//               [self.navigationController pushViewController:detail animated:YES];
           }
           
       } else if (error.code == -1011) {
           [WTProgressHUD ShowTextHUD:@"您已经预约过该商家了" showInView:KEY_WINDOW];
       }
       else if(error){
           [WTProgressHUD ShowTextHUD:@"网络问题预约失败" showInView:KEY_WINDOW];
       }
       
   }];
}
- (void)buttonAction
{
    if (timeFlag && cityFlag) {
        [self orderAction];
        
    } else {
        [WTProgressHUD ShowTextHUD:@"请填写婚期与举办城市" showInView:KEY_WINDOW];
    }
    
}

- (void)timeTapAction
{
    
    
    datePickView.dataPickView.minimumDate = [NSDate dateWithTimeIntervalSince1970:-INT_MAX];
    [datePickView showWithTag:2];
    
}

- (void)cityTapAction
{
    
    [pickView showWithTag:3];
}

- (void)didPickDataWithDate:(NSDate *)date andTag:(int)tag {
    timeFlag = YES;
    weddingDay_time = [date timeIntervalSince1970];
    
    [self resetBtnWhileChooseTime ];
    [self changePayButtonStyle];
}
- (void)resetBtnWhileChooseTime {
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (weddingDay_time>0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:weddingDay_time];
        NSString * dateStr = [dateFormatter stringFromDate:date];

        timeLabel.text = dateStr;
        timeLabel.textColor = WeddingTimeBaseColor;
    }
}

- (void)didPickObjectWithIndex:(int)index andTag:(int)tag{
        if (tag==2) {
            timeFlag = YES;
        timeLabel.textColor = WeddingTimeBaseColor;
        
            timeLabel.text = [NSString stringWithFormat:@"%lld",weddingDay_time];
        
    }
    if (tag==3){
        cityFlag = YES;
        cityLabel.text = cityArray[index];
        
        cityLabel.textColor = WeddingTimeBaseColor;
        cityIndex=index;
    }
    [self changePayButtonStyle];
    
    
}

- (void)changePayButtonStyle
{
    if (timeFlag && cityFlag) {
        [payButton setBackgroundColor:WeddingTimeBaseColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
