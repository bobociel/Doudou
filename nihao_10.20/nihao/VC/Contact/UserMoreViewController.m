//
//  UserMoreViewController.m
//  nihao
//
//  Created by 吴梦婷 on 15/9/23.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//
#import "UserMoreViewController.h"
#import "ReportViewController.h"
#import "MyCustomSwitch.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "IChatManagerBuddy.h"
@interface UserMoreViewController ()<UITextFieldDelegate,EMChatManagerDelegate> {
    BlackListView *blackListView;
    RemarksView *remarksView;
    UILabel *nickNameLable;
    NSMutableArray *_ifSwitchONs;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSString *reNickname;

@end

@implementation UserMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleArray = @[@"Set Remarks",@"Don't Share My Moments",@"Hide His Moments",@"",@"Blacklist",@"Report"];
    _ifSwitchONs = [[NSMutableArray alloc] init];
    [_ifSwitchONs addObjectsFromArray:@[@"",@""]];
    if (1 == _contact.her_not_look_me) {
        [_ifSwitchONs insertObject:@"1" atIndex:1];
    }else{
        [_ifSwitchONs insertObject:@"0" atIndex:1];
    }
    if (1 == _contact.not_look_her) {
        [_ifSwitchONs insertObject:@"1" atIndex:2];
    }else{
        [_ifSwitchONs insertObject:@"0" atIndex:2];
    }
    
    [self addSettingMenu];
    [self getBlackList];
    [self initTableView];
    [self initTipViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//获取黑名单列表
-(void) getBlackList{
    EMError *error = nil;
    NSArray *blockedList = [[EaseMob sharedInstance].chatManager fetchBlockedList:&error];
    if (!error) {
        if ([blockedList containsObject: _contact.ci_username]) {
            [_ifSwitchONs insertObject:@"1" atIndex:4];
        }else{
            [_ifSwitchONs insertObject:@"0" atIndex:4];
        }
    }else{
        [self getBlackList];
    }
}

#pragma mark - init views
- (void) addSettingMenu {
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -20;
    self.navigationItem.rightBarButtonItems = @[spacerButton];
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 18)]  ;
    titleLable.font = FontNeveLightWithSize(18.0);
    titleLable.textColor = ColorWithRGB(255, 255, 255);
    titleLable.text = @"More";
    self.navigationItem.titleView = titleLable;
}
-(void) initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 600)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = ColorWithRGB(244, 244, 244);
    self.view.backgroundColor = ColorWithRGB(244, 244, 244);
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces=NO;
    [self.view addSubview:_tableView];
    MyCustomSwitch *btnSwitch = [[MyCustomSwitch alloc] init];
    btnSwitch.inactiveColor = ColorWithRGB(170, 170, 170);
    btnSwitch.borderColor = ColorWithRGB(170, 170, 170);
    btnSwitch.onColor = ColorWithRGB(63, 222, 179);
}

-(void) initTipViews{
    blackListView = [[BlackListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blackListView.hidden = YES;
    blackListView.delegate=self;
    [self.view addSubview:blackListView];
    remarksView = [[RemarksView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    remarksView.hidden = YES;
   // remarksView.textField.tag=100;
    remarksView.textField.delegate=self;
    remarksView.delegate = self;
    [self.view addSubview:remarksView];

}

#pragma mark - Table Delegate Methods（tableView代理方法）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        return 15;
    }
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"basis-cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (3 == indexPath.row) {
        cell.contentView.backgroundColor = ColorWithRGB(244, 244, 244);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (0 == indexPath.row|| 5 == indexPath.row) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cell_more"]];
    }else{
        MyCustomSwitch *btnSwitch = [[MyCustomSwitch alloc] init];
        btnSwitch.inactiveColor = ColorWithRGB(170, 170, 170);
        btnSwitch.borderColor = ColorWithRGB(170, 170, 170);
        btnSwitch.onColor = ColorWithRGB(63, 222, 179);
        btnSwitch.tag = indexPath.row;
        btnSwitch.on = [[_ifSwitchONs objectAtIndex:indexPath.row]boolValue];
        [btnSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = btnSwitch;
    }
    if (indexPath.row != 3 && indexPath.row != 4) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 1)];
        lineView.backgroundColor = SeparatorColor;
        [cell.contentView addSubview:lineView];
    }
    if (0 == indexPath.row) {
        nickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 50)];
        [cell.contentView addSubview:nickNameLable];
        nickNameLable.font = FontNeveLightWithSize(14.0);
        nickNameLable.textColor = ColorWithRGB(87, 87, 87);
        nickNameLable.textAlignment=NSTextAlignmentRight;
    }
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.font = FontNeveLightWithSize(14.0);
    cell.textLabel.textColor = ColorWithRGB(50, 50, 50);
    return cell;
}
//tableView点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //tableViewCell点击后返回正常状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        remarksView.hidden = NO;
    }
    if (indexPath.row == 5){
        ReportViewController *reportController = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
        [self.navigationController pushViewController:reportController animated:YES];
    }
}
- (void)switchChanged:(MyCustomSwitch *)sender {
    if (sender.on == YES) {
        if (sender.tag == 1) {
            [self setNoShowMyMomentToHer];
        }
        if (sender.tag == 2) {
            [self setNotLook];
        }
        if (sender.tag == 4) {
//            blackListView.hidden = NO;
//            sender.on = NO;
            [self putBlackList];
        }
    }else{
        if (sender.tag == 1) {
            [self cancelHerNotLookMe];
        }
        if (sender.tag == 2) {
            [self cancelNotLookHer];
        }
        if (sender.tag == 4) {
            [self outBlackList];
        }
    }
}

-(void)RemarksDelegateBtnClick:(UIButton *)sender{
    //根据你的button的tag来实现不同的触发事件
    if (sender.tag == 122) {
        NSLog(@"备注取消键");
        [self viewGoBack];

    }
    if (sender.tag == 123) {
        NSLog(@"备注OK键");
        _reNickname = remarksView.textField.text;
        nickNameLable.text = remarksView.textField.text;
        remarksView.textField.text=nil;
        [self reqModifyNickName];
    }
    [remarksView.textField resignFirstResponder];
    remarksView.hidden = YES;
}

-(void)BlackListBtnDelegateBtnClick:(UIButton*)sender{
    //根据你的button的tag来实现不同的触发事件
    if (sender.tag == 122) {
        NSLog(@"黑名单取消键");
    }
    if (sender.tag == 123) {
        NSLog(@"黑名单OK键");
        [self putBlackList];
           }
    blackListView.hidden = YES;
}

//加入黑名单
-(void)putBlackList{
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    EMError *error = [[EaseMob sharedInstance].chatManager blockBuddy:_contact.ci_username	relationship:eRelationshipBoth];
    if (!error) {
        MyCustomSwitch *btnSwitch = [self.view viewWithTag:4];
        btnSwitch.on = YES;
    }
}
//移除黑名单
-(void)outBlackList{
    EMError *error = [[EaseMob sharedInstance].chatManager unblockBuddy:_contact.ci_username];
    if (!error) {
        MyCustomSwitch *btnSwitch = [self.view viewWithTag:4];
        btnSwitch.on = NO;
    }
}

#pragma mark - 键盘遮挡问题
//解决键盘覆盖
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //设置视图移动的位移
    if (self.view.frame.size.height == 480) {
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -160, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else if(SCREEN_HEIGHT == 568){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else{
  
    }
}

//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self viewGoBack];
}

//view复位
-(void)viewGoBack{
    //设置视图移动的位移
    if (SCREEN_HEIGHT == 480 && self.view.frame.origin.y!= 0 ){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 160, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else if(SCREEN_HEIGHT == 568 && self.view.frame.origin.y!= 0){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else{
        
    }
    
}

//return收起键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark-HttpRequest(网络请求)
- (void) reqModifyNickName{
    NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSDictionary *params = @{@"cr_by_ci_id":[NSString stringWithFormat:@"%ld",_uid],
                             @"cr_relation_ci_id":loginUid,
                             @"cr_remark_name":_reNickname};
    [HttpManager importNickNameByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"code"] integerValue] == 0) {
            NSLog(@"message == %@",responseObject[@"message"]);
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remarkNickNameFaild");
    }];
    }

-(void) setNotLook{
    static BOOL ifFinished = YES;
    NSLog(@"iffinished == %d",ifFinished);
    if (ifFinished){
        ifFinished = NO;
        NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSDictionary *params = @{@"da_ci_id":loginUid,@"da_scoundrel_id":[NSString stringWithFormat:@"%ld",_uid]};
        [HttpManager addNotLookByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject[@"code"] integerValue] == 0) {
                NSLog(@"message == %@",responseObject[@"message"]);
                NSDictionary *result = responseObject[@"result"];
                NSLog(@"result == %@",result);
                ifFinished = YES;
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"setNotLookFaild");
            ifFinished = YES;
        }];
    }
    else {
        NSLog(@"dont sent request");
    }
}

-(void) setNoShowMyMomentToHer{
    static BOOL ifFinished = YES;
    if (ifFinished){
        ifFinished = NO;
        NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSDictionary *params = @{@"da_ci_id":loginUid,@"da_scoundrel_id":[NSString stringWithFormat:@"%ld",_uid]};
        [HttpManager addNotShowMyMomenToHerByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            NSLog(@"message == %@",responseObject[@"message"]);
                NSDictionary *result = responseObject[@"result"];
                NSLog(@"result == %@",result);
                ifFinished = YES;
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"setNoShowFaild");
            ifFinished = YES;
        }];
    }
}
-(void)cancelNotLookHer{
    static BOOL ifFinished = YES;
    if (ifFinished) {
        ifFinished = NO;
        NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSDictionary *params = @{@"da_ci_id":loginUid,@"da_scoundrel_id":[NSString stringWithFormat:@"%ld",_uid]};
        [HttpManager canlcelNotLookHerByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"message == %@",responseObject[@"message"]);
            ifFinished = YES;
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"cancelNotLookHerFaild");
            ifFinished = YES;
        }];
    }
}
-(void)cancelHerNotLookMe{
    static BOOL ifFinished = YES;
    if (ifFinished) {
        ifFinished = NO;
        NSString *loginUid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSDictionary *params = @{@"da_ci_id":loginUid,@"da_scoundrel_id":[NSString stringWithFormat:@"%ld",_uid]};
        [HttpManager canlcelHerNotLookMeByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"message == %@",responseObject[@"message"]);
            ifFinished = YES;
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"cancelHerNotLookMeFaild");
            ifFinished = YES;
        }];
    }
}
@end