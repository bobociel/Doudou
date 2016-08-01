//
//  DemandViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTDemandListViewController.h"
#import "WTCreateDemandViewController.h"
#import "GetService.h"
#import "WTDemandDetailViewController.h"
#import "UserInfoManager.h"
#import "WTLoadingViewController.h"
#import "WTLoginViewController.h"
#import "WTProgressHUD.h"
@interface WTDemandListViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WTDemandListViewController
{
    UITableView *demandTableView;
    NSMutableDictionary *resultDic;
    NSArray      *dataArr;
    UILabel             *findTypeLabel;
    UILabel             *stateLabel;
    UILabel             *timeLabel;
    UILabel             *numLabel;
    NSDictionary        *serviceTypeId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
}

-(void)initView{
    self.title=@"需求";
    [self setRightBtnWithImage:[UIImage imageNamed:@"add_nav"]];
    serviceTypeId=[[NSDictionary alloc]initWithObjectsAndKeys:@"婚礼策划",@(6),@"婚纱写真",@(11),@"婚礼摄影",@(7),@"婚礼摄像",@(12),@"婚纱礼服",@(9),@"新娘跟妆",@(8),@"婚礼主持",@(14),@"其它",@(21),@"测试婚礼",@(23),@"甜品婚品",@(17),@"海外婚礼", @(22), nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:UserCommitDemandNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:DemandDidRibedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:keepRewardDateNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:DemandDidCanceledNotification object:nil];
    
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:[UIView new]];
    demandTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    demandTableView.dataSource=self;
    demandTableView.delegate=self;
    demandTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    demandTableView.backgroundColor=[UIColor whiteColor];
    demandTableView.tableFooterView=[[UIView alloc]init];
    [self.view addSubview:demandTableView];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:DemandDidCanceledNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:UserCommitDemandNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:DemandDidRibedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:keepRewardDateNotification object:nil];
}

-(void)reloadData{
    [self loadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 109;
    }else{
        return 98;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (dataArr.count==0) {
            tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        }
        
    }
    int height = 26;
    if (indexPath.row == 0) {
        height = height + 11;
    }
    //    [self initTableViewUI];
    findTypeLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, height, 140, 20)];
    findTypeLabel.font=[WeddingTimeAppInfoManager fontWithSize:18.f];
    findTypeLabel.textAlignment=NSTextAlignmentLeft;
    findTypeLabel.textColor=[UIColor blackColor];
    
    stateLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, findTypeLabel.bottom+10, 100, 16)];
    stateLabel.font=defaultFont16;
    stateLabel.textAlignment=NSTextAlignmentLeft;
    stateLabel.textColor=[[WeddingTimeAppInfoManager instance] baseColor];
    
    timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(stateLabel.right, stateLabel.top, 100, 20)];
    timeLabel.font=defaultFont16;
    timeLabel.textColor=[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    timeLabel.textAlignment=NSTextAlignmentLeft;
    
    numLabel=[[UILabel alloc]initWithFrame:CGRectMake(screenWidth-67, height - 4, 54, 57)];
    numLabel.right=screenWidth-10;
    numLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:48];
    numLabel.textColor=[[WeddingTimeAppInfoManager instance] baseColor];
    numLabel.textAlignment=NSTextAlignmentRight;
    if (indexPath.row==0) {
        findTypeLabel.top=37;
        stateLabel.top=findTypeLabel.bottom+10;
        timeLabel.top=stateLabel.top;
    }
    NSDictionary *dict = dataArr[indexPath.row];
    findTypeLabel.text=[NSString stringWithFormat:@"我要找%@",[serviceTypeId objectForKey:dict[@"service_id"]]];
    stateLabel.text=dataArr[indexPath.row][@"status_name"];
    NSDateComponents *time=[self residueTime:[dataArr[indexPath.row][@"expire_time"]doubleValue]];
    if ([time day]) {
        timeLabel.text=[NSString stringWithFormat:@"(剩余%ld天)",(long)[time day]];
    }else{
        timeLabel.text=[NSString stringWithFormat:@"(剩余%ld小时)",(long)[time hour]];
    }
    if (dataArr[indexPath.row][@"bidding_num"] == 0) {
        numLabel.text=@"0";
    }else{
        numLabel.text=[NSString stringWithFormat:@"%@",dataArr[indexPath.row][@"bidding_num"]];
    }
    if ([time hour]<0||[time day]<0) {
        timeLabel.hidden=YES;
    }
    if ([stateLabel.text isEqualToString:@"需求已关闭"]) {
        stateLabel.textColor=[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0];
        numLabel.textColor=[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0];
        timeLabel.hidden=YES;
    }
    if ([stateLabel.text isEqualToString:@"商家已接单"]) {
        timeLabel.hidden=YES;
        NSDictionary *chosenDic=dataArr[indexPath.row][@"chosen"];
        stateLabel.text=chosenDic[@"company"];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(findTypeLabel.left, stateLabel.top, 32, 24)];
        label.font=defaultFont16;
        label.textColor=subTitleLableColor;
        label.text=@"预定";
        [cell.contentView addSubview:label];
        stateLabel.frame=CGRectMake(label.right, label.top, 200, 24);
    }
    
    int line_height = 98;
    if (indexPath.row == 0) {
        line_height = 109;
    }
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(10, line_height - 0.5, screenWidth-10, 0.5)];
    lineView.image = [LWUtil imageWithColor:rgba(221, 221, 221, 1) frame:CGRectMake(0, 0, screenWidth, 0.5)];
    
    
    
    [cell.contentView addSubview:findTypeLabel];
    [cell.contentView addSubview:stateLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:numLabel];
    [cell.contentView addSubview:lineView];
    
    return cell;
    
}

- (NSDateComponents *)residueTime:(NSTimeInterval)timeInterval{
    NSTimeInterval second1 = timeInterval;
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:second1];
    NSDate *date2 = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *d = [cal components:unitFlags fromDate:date2 toDate:date1 options:0];
    return d;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WTDemandDetailViewController *detialVC=[WTDemandDetailViewController new];
    detialVC.rewardId =[dataArr[indexPath.row][@"id"]intValue];
    [self.navigationController pushViewController:detialVC animated:YES];
}

-(void)rightNavBtnEvent{
    WTCreateDemandViewController *next=[WTCreateDemandViewController new];
    next.isFromList=YES;
    [self.navigationController pushViewController:next animated:YES];
}

-(void)loadData{
    [self showLoadingView];
    [GetService getDemandListWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:demandTableView];
        [LWAssistUtil dealNetWorkServer:error customFailBlock:^NSString *(int status, NSString *msg) {
            return msg;
        } successBlock:^{
            NSMutableArray *array01=[[NSMutableArray alloc]init];
            array01=result[@"data"];
            dataArr=[[array01 reverseObjectEnumerator]allObjects];
            [demandTableView reloadData];
            if (!dataArr||dataArr.count<1){
                [NetWorkingFailDoErr errWithView:demandTableView content:@"点击创建婚礼需求" tapBlock:^{
                    [self rightNavBtnEvent];
                }];
            }
        } defaultFailBlock:^(NSString *errorMsg) {
            [NetWorkingFailDoErr errWithView:demandTableView content:errorMsg tapBlock:^{
                [self reloadData];
            }];
        }];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UserInfoManager instance].tokenId_self==nil) {
        WTLoginViewController *loginVC=[WTLoginViewController new];
        [self presentViewController:loginVC animated:YES completion:^{
            
        }];
        return;
    }
    
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
