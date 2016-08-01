//
//  WDHomeMusicViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTHomeMusicViewController.h"
#import "WTHomeViewController.h"
#import "WeddingHomePageMusicCell.h"
#import "WeddingTimeAppInfoManager.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "PostDataService.h"

@interface WTHomeMusicViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WTHomeMusicViewController
{
    NSInteger chooseindex;
    UITableView *dataTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.musicArray = [NSArray array];
    [self initView];
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UUAVAudioPlayer sharedInstance] stopSound];
	[[UUAVAudioPlayer sharedInstance] stopTask];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)loadData {
    [self showLoadingView];
	void(^WTMusicSelectedBlock)() = ^(){
		if(!self.musicArray) {return ;}
		for (int i=0; i < _musicArray.count ; i++)
		{
			WTWeddingTheme *theme = _musicArray[i];
			if([theme.ID isEqualToString:_musicChoosedID])
			{
				chooseindex = i;
				return ;
			}
		}
	};

    [GetService getHomePageThemeWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:dataTableView];
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone) {
			_musicArray = [NSArray modelArrayWithClass:[WTWeddingTheme class] json:result[@"data"][@"music"]];
            [dataTableView reloadData];
			WTMusicSelectedBlock();
            if ([_musicArray count]==0) {
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _musicArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	WTWeddingTheme *theme = _musicArray[indexPath.row];
	WeddingHomePageMusicCell *cell = [tableView WeddingHomePageMusicCell];
	[cell setInfo:theme withSelectedId:_musicChoosedID];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTWeddingTheme *theme = _musicArray[indexPath.row];
	chooseindex = indexPath.row == chooseindex ? NSNotFound : indexPath.row;
	_musicChoosedID = theme.ID == _musicChoosedID ? nil : theme.ID ;
	NSString *voiceURL = [LWUtil getString:theme.path andDefaultStr:@""];
	[dataTableView reloadData];

	[[UUAVAudioPlayer sharedInstance] stopSound];
	[[UUAVAudioPlayer sharedInstance] stopTask];
	[[UUAVAudioPlayer sharedInstance] cacheSongWithUrl:voiceURL callback:^(NSString *songURL, NSData *songData) {
		if([songURL isEqualToString:voiceURL] && chooseindex != NSNotFound && songData){
			[[UUAVAudioPlayer sharedInstance] playSongWithData:songData andType:AVFileTypeMPEGLayer3];
		}
	}];
}

- (void)save
{
    if (chooseindex < 0 || chooseindex == NSNotFound || chooseindex >= [_musicArray count]) {
        [WTProgressHUD ShowTextHUD:@"未选择任何音乐哦" showInView:self.view];
		return ;
    }

    [self showLoadingView];
	__block WTWeddingTheme *theme = _musicArray[chooseindex];
    [PostDataService POSTWeddingHomeChooseMusic:@"music" andId:theme.ID
									  withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            [WTProgressHUD ShowTextHUD:@"保存音乐成功" showInView:self.view];
            [self.delegate selectMusicName:theme.name andMusicId:_musicChoosedID];
            [UserInfoManager instance].backMusicName = [LWUtil getString:theme.name andDefaultStr:@""];
            [[UserInfoManager instance] saveToUserDefaults];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
        }else {
            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,稍后再试"] showInView:self.view];
        }
        
    }];
}

- (void)back
{
	UIViewController *VC ;
	for (UIViewController *aVC in self.navigationController.viewControllers) {
		if([aVC isKindOfClass:[WTHomeViewController class]]) { VC = aVC; }
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
	VC ? [self.navigationController popToViewController:VC animated:YES] : nil;
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
