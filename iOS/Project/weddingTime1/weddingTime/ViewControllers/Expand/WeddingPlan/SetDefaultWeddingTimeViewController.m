//
//  SetDefaultWeddingTimeViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/6/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "SetDefaultWeddingTimeViewController.h"
#import "CommDatePickView.h"
#import "PostDataService.h"
#import "WeddingPlanContainerViewController.h"
#import "WTProgressHUD.h"
@interface SetDefaultWeddingTimeViewController ()<CommDatePickViewDelegate>

@end

@implementation SetDefaultWeddingTimeViewController
{
    int64_t wedding_time;
    UIButton *chooseWeddingTimeBtn;
    CommDatePickView *datePickView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didPickDataWithDate:(NSDate *)date andTag:(int)tag {
    
    wedding_time = [date timeIntervalSince1970];
    [self resetBtnWithDate:wedding_time];
}


- (void)resetBtnWithDate:(int64_t)date {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString * dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:date]];
    [chooseWeddingTimeBtn setTitle:[NSString stringWithFormat:@"   %@",dateStr] forState:UIControlStateNormal];
}
- (void)dateBtnEvent {
    datePickView.dataPickView.minimumDate = [NSDate dateWithTimeIntervalSince1970:-INT_MAX];
    [datePickView showWithTag:0];
}


- (void)rightNavBtnEvent {
    if (wedding_time<0) {
        [WTProgressHUD ShowTextHUD:@"还没有选择您的婚期哦" showInView:self.view];
        return;
    }
    [self showLoadingView];
    [PostDataService postSetWeddingTime:wedding_time WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            [WTProgressHUD ShowTextHUD:@"出错啦,请稍后再试" showInView:self.view];
        }else {
            [UserInfoManager instance].weddingTime = wedding_time;
            [[UserInfoManager instance] saveToUserDefaults];
            [WTProgressHUD ShowTextHUD:@"保存成功" showInView:KEY_WINDOW];
            
            if (self.isFromMain) {
                [self.navigationController pushViewController:[WeddingPlanContainerViewController new] animated:YES];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:DefaultWeddingTimeDidChangeNotify object:nil];
                [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
            }
            
        }
    }];
}

- (void)initView {
    self.title=@"设置婚期";
    wedding_time=-1;
    
    chooseWeddingTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,30, 200, 32)];
    [chooseWeddingTimeBtn setTitle:@"  设置婚期" forState:UIControlStateNormal];
    chooseWeddingTimeBtn.titleLabel.font=defaultFont16;
    chooseWeddingTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [chooseWeddingTimeBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    chooseWeddingTimeBtn.tag=0;
    [chooseWeddingTimeBtn setImage:[UIImage imageNamed:@"icon_setWeddingTime_pink"] forState:UIControlStateNormal];
    [chooseWeddingTimeBtn addTarget:self action:@selector(dateBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chooseWeddingTimeBtn];
    
    datePickView = [[CommDatePickView alloc] init];
    datePickView.delagate=self;
    
    if (self.isFromMain) {
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(10, chooseWeddingTimeBtn.bottom+10, screenWidth-20, 20)];
        subtitle.textColor=subTitleLableColor;
        subtitle.font=defaultFont12;
        subtitle.text =@"我们可以通过您设置的婚期为您提供默认的婚礼计划。";
        [self.view addSubview:subtitle];
    }
    
    if ([UserInfoManager instance].weddingTime>NSTimeIntervalSince1970) {
        [self resetBtnWithDate:[UserInfoManager instance].weddingTime];
    }
    
    [self setRightBtnWithTitle:@"完成"];
    
}

@end
