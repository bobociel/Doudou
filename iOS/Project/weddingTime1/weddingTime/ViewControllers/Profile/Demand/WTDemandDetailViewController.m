//
//  emandDetailViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTDemandDetailViewController.h"
#import "WeddingTimeAppInfoManager.h"
#import "WTAlertView.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "WTOrderListViewController.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "ChatConversationManager.h"
#import "WTChatDetailViewController.h"
#import "MJRefresh.h"

#import "WTSupplierViewController.h"

#import "NotificationTopPush.h"


@interface WTDemandDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation WTDemandDetailViewController
{
    //    NSArray             *dataArr;
    UITableView *baseTableView;
    UIView      *headView;
    
    
    UILabel     *stateLabel;
    UILabel     *weddingTimeLabel;
    UILabel     *weddingTimeLabelOfNum;
    UILabel     *budgetLabel;
    UILabel     *budgetLabelOfNum;
    UILabel     *orderFormLabel;
    UILabel     *orderFormNumLabel;
    
    NSDictionary *dataDict;
    NSMutableArray *bidsArray;
    
    int page;
    int status;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(demandDidRibedAction:) name:DemandDidRibedNotification object:nil];
    [self initView];
    [self loadData];
}

-(void)demandDidRibedAction:(NSNotification*)notification
{
    int demandId=[notification.userInfo[@""] intValue];
    if (demandId ==_rewardId) {
        [self loadData];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:DemandDidRibedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    [WeddingTimeAppInfoManager instance].curid_demand_detail = [NSString stringWithFormat:@"%d", self.rewardId];
}


-(void)loadData{
    [self showLoadingView];
    
    [GetService getDemandDetailWithRewardId:self.rewardId WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [LWAssistUtil dealNetWorkServer:error customFailBlock:^NSString *(int status, NSString *msg) {
            return msg;
        } successBlock:^{
            dataDict=result[@"data"];
            [baseTableView reloadData];
            status=[dataDict[@"status"] intValue];
            self.title=dataDict[@"status_name"];
            
            if ([dataDict[@"can_close"] intValue]==0) {
                [self setRightBtnWithTitle:@"取消"];
            }
            page=1;
            [self loadMore];
        } defaultFailBlock:^(NSString *errorMsg) {
            
        }];
    }];
}

-(void)loadMore
{
    [self showLoadingView];
    [GetService getDemandRibedWithRewardId:self.rewardId WithPage:page WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [baseTableView.footer endRefreshing];
        [LWAssistUtil dealNetWorkServer:error customFailBlock:^NSString *(int status, NSString *msg) {
            return msg;
        } successBlock:^{
            if (page==1) {
                bidsArray=[NSMutableArray array];
            }
            NSDictionary *bidsDict=result[@"data"];
            NSArray *array=[NSArray arrayWithArray:bidsDict[@"bids"]];
            if (!array||array.count<10) {
                baseTableView.footer=nil;
            }
            else
            {
                [self initFooterRefresh];
            }
            
            if (array&&array.count>0) {
                [bidsArray addObjectsFromArray:array];
            }
            else
            {
                if (bidsArray.count>0) {
                    [WTProgressHUD ShowTextHUD:@"没有更多的了" showInView:self.view];
                }
                else
                {
                    [WTProgressHUD ShowTextHUD:@"暂时还没有商家接单哦，请耐心等待" showInView:self.view];
                }
            }
            [baseTableView reloadData];
            
            page++;
        } defaultFailBlock:^(NSString *errorMsg) {
            
        }];
    }];
}

-(void)initView {
    headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
    weddingTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(43, 54, 28, 14)];
    weddingTimeLabel.backgroundColor=[UIColor clearColor];
    weddingTimeLabel.text=@"婚期";
    weddingTimeLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    weddingTimeLabel.textColor=titleLableColor;
    weddingTimeLabel.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:weddingTimeLabel];
    weddingTimeLabelOfNum=[[UILabel alloc]initWithFrame:CGRectMake(13, weddingTimeLabel.bottom+10, 69, 21)];
    weddingTimeLabelOfNum.backgroundColor=[UIColor clearColor];
    
    weddingTimeLabelOfNum.centerX=weddingTimeLabel.centerX;
    weddingTimeLabelOfNum.font=[WeddingTimeAppInfoManager fontWithSize:14];
    weddingTimeLabelOfNum.textColor=titleLableColor;
    weddingTimeLabelOfNum.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:weddingTimeLabelOfNum];
    
    stateLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 14)];
    stateLabel.centerX=self.view.centerX;
    stateLabel.textColor=titleLableColor;
    stateLabel.textAlignment=NSTextAlignmentCenter;
    stateLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    [headView addSubview:stateLabel];
    
    budgetLabel=[[UILabel alloc]initWithFrame:CGRectMake(weddingTimeLabel.right+123, 54, 28, 14)];
    budgetLabel.backgroundColor=[UIColor clearColor];
    budgetLabel.text=@"预算";
    budgetLabel.centerX=self.view.centerX;
    budgetLabel.centerY=weddingTimeLabel.centerY;
    budgetLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    budgetLabel.textColor=titleLableColor;
    budgetLabel.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:budgetLabel];
    
    budgetLabelOfNum=[[UILabel alloc]initWithFrame:CGRectMake(weddingTimeLabelOfNum.right+55, budgetLabel.bottom+10, 119, 21)];
    budgetLabelOfNum.backgroundColor=[UIColor clearColor];
    
    budgetLabelOfNum.centerX=budgetLabel.centerX;
    budgetLabelOfNum.font=[WeddingTimeAppInfoManager fontWithSize:14];
    budgetLabelOfNum.textColor=titleLableColor;
    budgetLabelOfNum.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:budgetLabelOfNum];
    
    orderFormLabel=[[UILabel alloc]initWithFrame:CGRectMake(budgetLabel.right+115, 54, 28, 14)];
    orderFormLabel.right=screenWidth-49;
    orderFormLabel.backgroundColor=[UIColor clearColor];
    orderFormLabel.text=@"抢单";
    orderFormLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    orderFormLabel.textColor=titleLableColor;
    orderFormLabel.textAlignment=NSTextAlignmentLeft;
    [headView addSubview:orderFormLabel];
    
    orderFormNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(weddingTimeLabelOfNum.right+55, budgetLabel.bottom+10, 119, 21)];
    orderFormNumLabel.backgroundColor=[UIColor clearColor];
    
    orderFormNumLabel.centerX=orderFormLabel.centerX;
    orderFormNumLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    orderFormNumLabel.textColor=[[WeddingTimeAppInfoManager instance] baseColor];
    orderFormNumLabel.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:orderFormNumLabel];
    
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(0, orderFormNumLabel.bottom+28, screenWidth, 0.5)];
    lineView.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.5)];
    [headView addSubview:lineView];
    
    UIView *view=[[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:view];
    
    baseTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    baseTableView.dataSource=self;
    baseTableView.delegate=self;
    baseTableView.backgroundColor=[UIColor whiteColor];
    baseTableView.showsVerticalScrollIndicator=NO;
    baseTableView.separatorStyle=NO;
    [self.view addSubview:baseTableView];
}

- (void)initFooterRefresh
{
    __weak UIScrollView *scrollView = baseTableView;
    
    // 添加下拉刷新控件
    if (!scrollView.footer) {
        scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self loadMore];
        }];
    }
    // 如果是上拉刷新，就以此类推
}

- (void)jumpToSupplierDetail:(UITapGestureRecognizer *)tap
{
    UIView *sender = tap.view;
    WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
    supplier.supplier_id = bidsArray[sender.tag-2015][@"supplier_user_id"];
    [self.navigationController pushViewController:supplier animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return bidsArray.count;
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 252;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.contentView removeAllSubviews];
    UIImageView *serviceHeadImage;
    UILabel     *serviceNameLabel;
    UILabel     *likeNumLabel;
    if (indexPath.row>=bidsArray.count) {
        return cell;
    }
    NSDictionary *dataDic=bidsArray[indexPath.row];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToSupplierDetail:)];
    serviceHeadImage=[[UIImageView alloc]init];
    serviceHeadImage.tag = 2015 + indexPath.row;
    serviceHeadImage.userInteractionEnabled = YES;
    [serviceHeadImage addGestureRecognizer:tap];
    [serviceHeadImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:dataDic[@"avatar"]]  andPlaceholder:[UIImage imageNamed:@"male_default"]];
    serviceHeadImage.backgroundColor=[UIColor clearColor];
    serviceHeadImage.layer.cornerRadius=32.f;
    serviceHeadImage.layer.masksToBounds=YES;
    serviceHeadImage.frame=CGRectMake((screenWidth-64)/2, 30, 64, 64);
    [cell.contentView addSubview:serviceHeadImage];
    
    serviceNameLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-220)/2, serviceHeadImage.bottom+20, 220, 20)];
    serviceNameLabel.backgroundColor=[UIColor clearColor];
    serviceNameLabel.text=dataDic[@"company"] ;
    serviceNameLabel.textAlignment=NSTextAlignmentCenter;
    serviceNameLabel.textColor=[UIColor blackColor];
    serviceNameLabel.font=[WeddingTimeAppInfoManager fontWithSize:20];
    [cell.contentView addSubview:serviceNameLabel];
    
    likeNumLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-127)/2, serviceNameLabel.bottom+10, 127, 12)];
    likeNumLabel.backgroundColor=[UIColor clearColor];

	NSString *works_count = [dataDic[@"post_num"] integerValue] == 0 ? [LWUtil getString:dataDic[@"works_count"] andDefaultStr:@"0"] : [LWUtil getString:dataDic[@"post_num"] andDefaultStr:@"0"] ;
	likeNumLabel.text=[NSString stringWithFormat:@"作品%@･喜欢%@",works_count ,dataDic[@"like_num"]];

    likeNumLabel.textAlignment=NSTextAlignmentCenter;
    likeNumLabel.textColor=[UIColor blackColor];
    likeNumLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    [cell.contentView addSubview:likeNumLabel];
    UIButton    *onLineChatBtn;
    UIButton    *saveDateBtn;
    onLineChatBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    onLineChatBtn.frame=CGRectMake((screenWidth-300)/2, likeNumLabel.bottom+20, 140, 46);
    [onLineChatBtn setTitle:@"在线咨询" forState:UIControlStateNormal];
    [onLineChatBtn setTitleColor:rgba(173, 173, 173, 1) forState:UIControlStateNormal];
    onLineChatBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    onLineChatBtn.backgroundColor=[UIColor whiteColor];
    onLineChatBtn.layer.cornerRadius=onLineChatBtn.height/2.0;
    onLineChatBtn.layer.borderWidth=1.0f;
    onLineChatBtn.layer.borderColor=rgba(221, 221, 221, 1).CGColor;
    [onLineChatBtn addTarget:self action:@selector(onlineChatEvent:) forControlEvents:UIControlEventTouchUpInside];
    onLineChatBtn.tag=indexPath.row+1314;
    [cell.contentView addSubview:onLineChatBtn];
    
    saveDateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    saveDateBtn.frame=CGRectMake(onLineChatBtn.right+20, likeNumLabel.bottom+20, 140, 46);
    [saveDateBtn setTitle:@"保留档期" forState:UIControlStateNormal];
    //[NSLayoutConstraint constraintsWithVisualFormat:@"H:||" options:0 metrics:nil views:NSDictionaryOfVariableBindings(saveDateBtn)];
    if (status==-1||status==1||status==2||status==3) {
        [saveDateBtn setTitleColor:rgba(173, 173, 173, 1) forState:UIControlStateNormal];
        saveDateBtn.layer.borderColor=rgba(221, 221, 221, 1).CGColor;
    }else{
        [saveDateBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
        saveDateBtn.layer.borderColor=[WeddingTimeAppInfoManager instance].baseColor.CGColor;
    }
    saveDateBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    saveDateBtn.backgroundColor=[UIColor whiteColor];
    [saveDateBtn.layer setMasksToBounds:YES];
    saveDateBtn.layer.cornerRadius=saveDateBtn.height/2.0;
    saveDateBtn.layer.borderWidth=1.0f;
    
    saveDateBtn.tag = indexPath.row + 10000;
    [saveDateBtn addTarget:self action:@selector(saveDateEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:saveDateBtn];
    
    UILabel     *alreadyReceiveLabel;
    alreadyReceiveLabel=[[UILabel alloc]initWithFrame:CGRectMake(screenWidth-58, 0, 58, 57)];
    alreadyReceiveLabel.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"receive_order"]];
    
    if ([dataDic[@"status"] integerValue]==2) {//被选中状态
        [cell.contentView addSubview:alreadyReceiveLabel];
    }
    tableView.separatorStyle=NO;
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(0, saveDateBtn.bottom+29, screenWidth, 0.5)];
    lineView.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.5)];
    [cell.contentView addSubview:lineView];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (dataDict) {
        orderFormNumLabel.text=[NSString stringWithFormat:@"%@",dataDict[@"bidding_num"]];
        budgetLabelOfNum.text=dataDict[@"price_range"];
        NSTimeInterval time=[dataDict[@"wedding_time"]doubleValue];
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yy-MM-dd"];
        weddingTimeLabelOfNum.text=[dateFormatter stringFromDate:date];
        stateLabel.text=[NSString stringWithFormat:@"%@到期",weddingTimeLabelOfNum.text];
    }
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 127;
}

-(void)rightNavBtnEvent{
    if (status==-1||status==2||status==3) {
        [WTProgressHUD ShowTextHUD:@"该需求已经关闭了" showInView:self.view];
    }else{
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"确定要关闭该需求吗?" centerImage:nil];
        alertView.buttonTitles=@[@"取消",@"确定"];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            if (buttonIndex==1) {
                //确认
                [loadingHUD hide:NO];
                [self showLoadingView];
                [GetService getRewardCloseWithRewardId:self.rewardId WithBlock:^(NSDictionary *result, NSError *error) {
                    [self hideLoadingView];
                    if (!error&&result) {
                        [WTProgressHUD ShowTextHUD:@"取消成功" showInView:self.view afterDelay:1];
                        [[NSNotificationCenter defaultCenter]postNotificationName:DemandDidCanceledNotification object:nil];
                        [self performSelector:@selector(back) withObject:nil afterDelay:1];
                    }else{
                        NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
                        [WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
                    }
                }];
            }else{
                
            }
        }];
        
        [alertView show];
    }
}
-(void)onlineChatEvent:(UIButton *)sender{
    
    [self conversationSelectType:0 supplier_id:bidsArray[sender.tag-1314][@"supplier_user_id"] hotelDic:nil name:bidsArray[sender.tag-1314][@"company"] phone:bidsArray[sender.tag-1314][@"phone"] avatar:bidsArray[sender.tag-1314][@"avatar"]];
    
    
}
-(void)saveDateEvent:(UIButton *)sender{
    if (status==1) {
        sender.enabled=NO;
        [WTProgressHUD ShowTextHUD:@"已经有商家接单了" showInView:self.view];
    }else if (status==-1||status==2||status==3){
        sender.enabled=NO;
        [WTProgressHUD ShowTextHUD:@"需求已经关闭了" showInView:self.view];
    }else if (status==0||status==4){
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:bidsArray[sender.tag-10000][@"avatar"]]];
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:[NSString stringWithFormat:@"预定%@服务商的档期",bidsArray[sender.tag-10000][@"company"]] centerImage:imageView.image];
        alertView.buttonTitles=@[@"取消",@"确定"];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            if (buttonIndex==1) {
                //需求选标
                [self showLoadingView];
                sender.enabled=NO;
                int supplier_id= [bidsArray[sender.tag-10000][@"supplier_id"] intValue];
                [GetService getRewardSelectWithRewardId:self.rewardId WithSupplierId:supplier_id WithBlock:^(NSDictionary *result, NSError *error) {
                    [self hideLoadingView];
                    sender.enabled=YES;
                    if (!error&&result) {
                        sender.enabled=NO;
                        [self loadData];
                        [[NSNotificationCenter defaultCenter]postNotificationName:keepRewardDateNotification object:nil];
                        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"保留档期成功" centerImage:nil];
                        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                            //                            [NotificationTopPush pushToOrderDetailWtihOrder_id:@(supplier_id)];
                            [self.navigationController pushViewController:[WTOrderListViewController new] animated:YES];
                        }];
                        [alertView show];
                    }else{
                        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"保留档期失败,请重试" centerImage:nil];
                        [alertView show];
                    }
                }];
            }
        }];
        
        [alertView show];
    }
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
