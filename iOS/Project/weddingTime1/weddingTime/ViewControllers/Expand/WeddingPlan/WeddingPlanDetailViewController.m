//
//  WeddingPlanDetailViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanDetailViewController.h"
#import "CommDatePickView.h"
#import "PostDataService.h"
#import "GetService.h"
#import "WTProgressHUD.h"
@interface WeddingPlanDetailViewController ()<UITextViewDelegate,CommDatePickViewDelegate>

@end

@implementation WeddingPlanDetailViewController
{
    UIScrollView *mainScrollView;
    int64_t close_time;
    int64_t remind_time;
    BOOL isFinish;
    UIButton *closeTimeBtn;
    UIButton *remindTimeBtn;
    UIButton *changeStatusBtn;
    UILabel *statusLable;
    UITextField *titleInput;
    UILabel *descriptionPlaceholder;
    UITextView *descriptionTextView;
    CommDatePickView *datePickView;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"婚礼计划";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
     if([self.data isKindOfClass:[NSNumber class]])
    {
        [self showLoadingView:self.view.superview];
        [GetService
         getWeddingDetailWithId:[self.data intValue] WithBlock:^(NSDictionary *result, NSError *error) {
             [self hideLoadingView];
             if (error) {
                 if (error.code == -1003 || error.code == 3840 || error.code == -1001) {
                     [WTProgressHUD ShowTextHUD:@"服务器开小差啦，请稍后再试吧" showInView:KEY_WINDOW];
                 } else if (error.code == -1009) {
                     [WTProgressHUD ShowTextHUD:@"网络情况不佳，请稍后再试吧" showInView:KEY_WINDOW];
                 } else if (error.code == 4004 || error.code == ERROR_NoresultCode) {
                     [WTProgressHUD ShowTextHUD:@"该计划不存在" showInView:KEY_WINDOW];
                 } else if (error.code == 403) {
                     [WTProgressHUD ShowTextHUD:@"token过期，请重新登陆后再试" showInView:KEY_WINDOW];
                 } else {
                     [WTProgressHUD ShowTextHUD:@"服务器开小差啦，请稍后再试吧" showInView:KEY_WINDOW];
                 }
                 
                 [self.navigationController popViewControllerAnimated:YES];
             } else {
                 
                 self.data= result;
                 [self initView];
             }

         }];
    }
    else
    {
        [self initView];
    }
}

- (void)didPickDataWithDate:(NSDate *)date andTag:(int)tag {
    if (tag==0) {
        close_time = [date timeIntervalSince1970];
    }else {
        remind_time = [date timeIntervalSince1970];
    }
    [self resetBtnWhileChooseTime ];
}

- (void)resetBtnWhileChooseTime {
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    if (close_time>0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:close_time];
        
        NSString * dateStr = [dateFormatter stringFromDate:date];
        [closeTimeBtn setTitle:dateStr forState:UIControlStateNormal];
        
    }
    if (remind_time>0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:remind_time];
        NSString * dateStr = [dateFormatter stringFromDate:date];
        [remindTimeBtn setTitle:dateStr forState:UIControlStateNormal];
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

- (void)navRightBtnEvent {
    [self tapBackGround];
    if (![titleInput.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"还没有输入标题哦" showInView:self.view];
        return;
    }
    if (close_time<0) {
        [WTProgressHUD ShowTextHUD:@"还没有选择计划时间哦" showInView:self.view];
        return;
    }
    
    NSString *descriptionText = [LWUtil getString:descriptionTextView.text andDefaultStr:@""];
    int matter_id = -1;
    
    
    if ([self.data count]) {
        matter_id = [[LWUtil getString:data[@"matter_id"] andDefaultStr:@"-1"] intValue];
    }
    [self showLoadingView];
    [PostDataService postWeddingPlanInfoWithMatterId:matter_id andTitle:titleInput.text andDescription:descriptionText andCloseTime:close_time andRemindTime:remind_time withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doloadFinishBlock:result And:error];
        
    }];
}

- (void) doloadFinishBlock:(NSDictionary *)result And:(NSError *)error {
    if (!error) {
        
        NSString *title=[self.data count]?@"我修改了计划":@"我安排了一个计划";
      
        
        [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
            if (ourCov) {
                 [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeInvitePlan andConversationValue:@{@"id":result[@"id"],@"type":@"p",@"title":title } andCovTitle:title conversation:ourCov push:YES success:^{
                     
                 } failure:^(NSError *error) {
                     
                 }];
            }
        }];

        [WTProgressHUD ShowTextHUD:[self.data count]?@"修改成功":@"成功新建计划" showInView:KEY_WINDOW];
        
        [self postNotify];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.f];
    }else {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
    }
    
}

- (void)dateBtnEvent:(UIButton *)sender {
    [self tapBackGround];
    datePickView.dataPickView.minimumDate = sender.tag==0?[NSDate dateWithTimeIntervalSince1970:-INT_MAX]:[NSDate dateWithTimeIntervalSinceNow:0];
    [datePickView showWithTag:(int)sender.tag];
}

- (void)postNotify {
    [[NSNotificationCenter defaultCenter] postNotificationName:WeddingPlanShouldBeReloadNotify object:nil];
}


- (void)changeStatusBtnEvent {
    if (![data count]) {
        return;
    }
    [self showLoadingView];
    [PostDataService postWeddingPlanChangeStatusWithMatterId:[self.data[@"matter_id"] intValue] andStatus:!isFinish?3:1 withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [self postNotify];
            isFinish=!isFinish;
            [changeStatusBtn setImage:isFinish?[UIImage imageNamed :@"icon_wedding_finish"]:[UIImage imageNamed :@"icon_wedding_unfinish"] forState:UIControlStateNormal];
            statusLable.text=isFinish?@"已完成":@"未完成";
            
            NSString *title=isFinish?@"完成计划":@"重置计划状态";
            
            [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                if (ourCov) {
                    [ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeInvitePlan andConversationValue:@{@"id":result[@"id"],@"type":@"p",@"title":title } andCovTitle:title conversation:ourCov push:YES success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }];
            
            if(isFinish)
            {
                statusLable.textColor = WeddingTimeBaseColor;
            }
            else
            {
                statusLable.textColor = [UIColor lightGrayColor];
            }
            
        }else {
            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
        }
    }];
}


- (void)initView {
    close_time=-1;
    remind_time=-1;
    
    float leftGap = 20;
    
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    mainScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width, mainScrollView.height+0.5);
    mainScrollView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:mainScrollView];
    titleInput = [[UITextField alloc] initWithFrame:CGRectMake(leftGap, 30, 0, 30)];
    titleInput.width=mainScrollView.width-2*titleInput.left;
    titleInput.placeholder = @"计划名称";
	titleInput.adjustsFontSizeToFitWidth = YES;
//    titleInput.font=defaultFont24;
    titleInput.textColor = titleLableColor;
    [mainScrollView addSubview:titleInput];
    
    
    UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftGap, titleInput.bottom+20, 16, 16)];
    [closeImageView setImage:[UIImage imageNamed :@"icon_setWeddingTime_pink"]];
    
    closeTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(closeImageView.right+5,0, 0, 32)];
    closeTimeBtn.width=mainScrollView.width-2*closeTimeBtn.left;
    closeTimeBtn.centerY =closeImageView.centerY;
    [closeTimeBtn setTitle:@"设置完成时间" forState:UIControlStateNormal];
    closeTimeBtn.titleLabel.font=defaultFont16;
    closeTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [closeTimeBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    closeTimeBtn.tag=0;
    [closeTimeBtn addTarget:self action:@selector(dateBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainScrollView addSubview:closeImageView];
    [mainScrollView addSubview:closeTimeBtn];
    
    
    UIImageView *remindImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, closeTimeBtn.bottom+10, 16, 16)];
    [remindImageView setImage:[UIImage imageNamed :@"icon_weddingClock_pink"]];
    remindTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(remindImageView.right+5,0, 0, 32)];
    remindTimeBtn.centerY=remindImageView.centerY;
    remindTimeBtn.width=mainScrollView.width-2*remindTimeBtn.left;
    [remindTimeBtn setTitle:@"设置提醒时间" forState:UIControlStateNormal];
    remindTimeBtn.titleLabel.font=defaultFont16;
    remindTimeBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    [remindTimeBtn setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    remindTimeBtn.tag=1;
    [remindTimeBtn addTarget:self action:@selector(dateBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainScrollView addSubview:remindImageView];
    [mainScrollView addSubview:remindTimeBtn];
    
    
    
    descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(leftGap, remindTimeBtn.bottom+20, 0, 30)];
    descriptionPlaceholder.width=mainScrollView.width-2*descriptionPlaceholder.left;
    descriptionPlaceholder.text = @"输入计划描述";
    descriptionPlaceholder.font=defaultFont14;
    descriptionPlaceholder.textColor=[LWUtil colorWithHexString:@"#C6C6C6"];
    [mainScrollView addSubview:descriptionPlaceholder];
    
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(leftGap, remindTimeBtn.bottom+20, 0, 100)];
    descriptionTextView.width=mainScrollView.width-2*descriptionTextView.left;
    descriptionTextView.backgroundColor=[UIColor clearColor];
    [mainScrollView addSubview:descriptionTextView];
    descriptionTextView.delegate=self;
    descriptionTextView.font=defaultFont14;
    descriptionTextView.textColor=subTitleLableColor;
    
    UIButton * saveBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50,30)];
    [saveBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    saveBtn.titleLabel.font=defaultFont16;
    [saveBtn addTarget:self action:@selector(navRightBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightAddPlanItem=[[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem=rightAddPlanItem;
    
    
    if ([self.data count]) {
        if (data[@"close_time"]) {
            close_time = [data[@"close_time"] longLongValue];
        }
        if (data[@"remind_time"]) {
            remind_time = [data[@"remind_time"]longLongValue];
        }
        if ([self.data[@"title"] isNotEmptyCtg]) {
            titleInput.text=self.data[@"title"];
        }
        if ([self.data[@"description"] isNotEmptyCtg]) {
            descriptionTextView.text=self.data[@"description"];
            descriptionPlaceholder.hidden=YES;
        }
        
        isFinish = [self.data[@"status"] intValue]==1?NO:YES;
        changeStatusBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        [changeStatusBtn setImage:isFinish?[UIImage imageNamed :@"icon_wedding_finish"]:[UIImage imageNamed :@"icon_wedding_unfinish"] forState:UIControlStateNormal];
        changeStatusBtn.centerX=mainScrollView.width/2.f;
        changeStatusBtn.bottom= mainScrollView.height-50;
        [changeStatusBtn addTarget:self action:@selector(changeStatusBtnEvent) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:changeStatusBtn];
        statusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        statusLable.top           = changeStatusBtn.bottom+5;
        statusLable.centerX       = mainScrollView.centerX;
        statusLable.font          = defaultFont12;
        
        statusLable.textAlignment = NSTextAlignmentCenter;
        statusLable.text          = isFinish?@"已完成":@"未完成";
        if(isFinish)
        {
            statusLable.textColor     = [WeddingTimeAppInfoManager instance].baseColor;
        }
        else
        {
            statusLable.textColor     = [UIColor lightGrayColor];
        }
        [mainScrollView addSubview:statusLable];
        
        self.title=@"计划详情";
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [self resetBtnWhileChooseTime];
        
    }else {
        
        self.title=@"创建新计划";
        [saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    
    datePickView = [[CommDatePickView alloc] init];
    datePickView.delagate=self;
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}


@end
