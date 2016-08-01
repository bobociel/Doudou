//
//  WDHomeMusicViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTHomeMusicViewController.h"
#import "WeddingHomePageMusicCell.h"
#import "WeddingTimeAppInfoManager.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "PostDataService.h"

@interface WTHomeMusicViewController ()<WeddingHomePageMusicCellDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation WTHomeMusicViewController
{
    int chooseindex;
    UITableView *dataTableView;
}
@synthesize musicArray;

- (void)viewDidLoad {
    [super viewDidLoad];
	if(!musicArray){
		musicArray = [NSArray array];
		[self loadData];
	}
    [self initView];
}

- (void)loadData {
    [self showLoadingView];
    [GetService getHomePageThemeWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:dataTableView];
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone) {
            
            musicArray = [NSArray arrayWithArray:result[@"data"][@"music"]];
            [dataTableView reloadData];
            if ([musicArray count]==0) {
                [NetWorkingFailDoErr errWithView:dataTableView content:@"暂时没有音乐哦" tapBlock:^{
                    [self loadData];
                }];
            }
        }
        else
        {
            NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
            [NetWorkingFailDoErr errWithView:dataTableView content:errorContent tapBlock:^{
                [self loadData];
            }];
        }
    }];
}

#pragma mark - tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeddingHomePageMusicCell *cell = [tableView WeddingHomePageMusicCell];
    [cell setInfo:musicArray[indexPath.row] withSelectedId:_musicChoosedID];
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return musicArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)didChooseMusicWithIndex:(int)index {
    chooseindex = index;
    _musicChoosedID = [musicArray[index][@"id"] intValue];
}

- (void)cancelChooseMusic {
    chooseindex = -1;
}

- (void)save {
    if (chooseindex<0||chooseindex>=[musicArray count]) {
        [WTProgressHUD ShowTextHUD:@"未选择任何音乐哦" showInView:self.view];
    }
    [self showLoadingView];
    [PostDataService POSTWeddingHomeChooseMusic:@"music" andId:[musicArray[chooseindex][@"id"]intValue] withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"保存音乐成功" showInView:self.view];
            [self.delegate selectMusicName:musicArray[chooseindex][@"name"]];
            [UserInfoManager instance].backMusicName = [LWUtil getString:musicArray[chooseindex][@"name"] andDefaultStr:@""];
            [[UserInfoManager instance] saveToUserDefaults];
            [[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
        }else {
            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,稍后再试"] showInView:self.view];
        }
        
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UUAVAudioPlayer sharedInstance] stopSound];
}

- (void)back {
    [super back];
}

- (void)initView {
    self.title = @"主题音乐";
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    dataTableView.backgroundColor = [UIColor clearColor];
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dataTableView];
    dataTableView.delegate   = self;
    dataTableView.dataSource = self;
    chooseindex = -1;
    [self setRightBtnWithTitle:@"保存"];
}

- (void)rightNavBtnEvent
{
    [self save];
}

@end
