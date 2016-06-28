//
//  WDThemeListViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTThemeListViewController.h"
#import "WTHomeMusicViewController.h"
#import "WTCardListViewController.h"
#import "WTCardDetailViewController.h"
#import "WTContactAsViewController.h"
#import "WTDeskViewController.h"
#import "WTProcessViewController.h"
#import "DWFlowLayout.h"
#import "WTThemeCell.h"
#import "FSMediaPicker.h"
#import "QiniuSDK.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTProgressHUD.h"
#import "GetService.h"
#import "PostDataService.h"
#import "LWUtil.h"
#import "WTUploadManager.h"
#import "UIImage+YYAdd.h"
#define kViewHeight  44.0
#define kLabelWidth  100.0
#define kTopView     142

@interface WTThemeListViewController ()
<
    UIActionSheetDelegate,UICollectionViewDelegate,
    UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,
    FSMediaPickerDelegate, musicHasSelectDelegate,WTUploadDelegate,WTThemeCellDelegate
>
@property (nonatomic,strong) UILabel *musicLabel;
@property (nonatomic,strong) UILabel *themeLabel;
@property (nonatomic,strong) UILabel *contactLabel;
@property (nonatomic,strong) UILabel *deskLabel;
@property (nonatomic,strong) UILabel *processLabel;
@property (nonatomic,strong) UICollectionView *dataCollectionView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) DWFlowLayout *layout;
@end

@implementation WTThemeListViewController
{
    NSString *themeChoosedID;
	NSString *musicChoosedID;

	id  uploadInfo;
	NSString *uploadKey;
	WTUploadManager *uploadManager;
    
    NSArray *themeArray;
	NSArray *musicArray;
    NSInteger curSelectIndex;
	BOOL showPhone;
	BOOL showDesk;
	BOOL showProcess;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"请柬设置";
    themeArray = [NSArray array];
	musicArray = [NSArray array];
	uploadManager = [WTUploadManager manager];
	uploadManager.delegate = self;

	curSelectIndex = curSelectIndex != 0 ? curSelectIndex : 0;
    [self setupView];
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
}

- (void)loadData {
	void(^WTMusicSelectButtonBlock)() = ^(){
		__block BOOL hasMusic = NO;
		__block NSString *musicName = @"";
		[musicArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
			WTWeddingTheme *theme = (WTWeddingTheme *)obj;
			if([theme.ID isEqualToString:musicChoosedID]){
				hasMusic = YES;
				musicName = theme.name;
				return ;
			}
		}];
		musicName = musicName.length == 0 ? @"选择背景音乐" : musicName ;
		_musicLabel.text = musicName;
	};

	void(^WTThemeSelectBlock)() = ^(){
		__block NSInteger themeSelectIndex;
		[themeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
			WTWeddingTheme *theme = (WTWeddingTheme *)obj;
			if([theme.ID isEqualToString:themeChoosedID]){
				themeSelectIndex  = idx;
				return ;
			}
		}];

		CGPoint point = CGPointMake( (screenWidth + _layout.minimumLineSpacing) * themeSelectIndex, 0);
		[_dataCollectionView setContentOffset:point animated:NO];
	};

	[self showLoadingView];
	[GetService getHomePageThemeWithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:_dataCollectionView];
		NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
		if (errorType==NetWorkStatusTypeNone)
		{
			themeChoosedID = [LWUtil getString:result[@"data"][@"choice"][@"theme_id"] andDefaultStr:@""] ;
			musicChoosedID = [LWUtil getString:result[@"data"][@"choice"][@"music_id"] andDefaultStr:@""] ;
			themeArray = [NSArray modelArrayWithClass:[WTWeddingTheme class] json:result[@"data"][@"theme"]];
			musicArray = [NSArray modelArrayWithClass:[WTWeddingTheme class] json:result[@"data"][@"music"]];
			showPhone = [result[@"data"][@"choice"][@"enable_contact"] boolValue];
			showDesk = [result[@"data"][@"choice"][@"enable_seat"] boolValue];
			showProcess = [result[@"data"][@"choice"][@"enable_process"] boolValue];
			_contactLabel.text = showPhone ? @"已启用" : @"未启用";
			_deskLabel.text = showDesk ? @"已启用" : @"未启用";
			_processLabel.text = showProcess ? @"已启用" : @"未启用";
			[_dataCollectionView reloadData];
			WTMusicSelectButtonBlock();
			WTThemeSelectBlock();
			if (themeArray.count==0) {
				[NetWorkingFailDoErr errWithView:_dataCollectionView content:@"暂时没有数据哦" tapBlock:^{
					[self loadData];
				}];
			}
		}
		else
		{
			NSString * errorContent=[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
			[NetWorkingFailDoErr errWithView:_dataCollectionView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

- (void)setupView
{
	UILabel *(^ControlBlock)(CGFloat y,  WTThemeListType state,NSString *text) = ^(CGFloat y,  WTThemeListType state,NSString *text){
		UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, y, screenWidth, kViewHeight)];
		control.backgroundColor = [UIColor clearColor];
		control.tag = state;
		[self.scrollView addSubview:control];
		[control addTarget:self action:@selector(goListAction:) forControlEvents:UIControlEventTouchUpInside];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, kViewHeight-0.5, screenWidth-30, 0.5)];
		lineView.backgroundColor = rgba(220, 220, 220, 1);
		[control addSubview:lineView];

		UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, kLabelWidth, kViewHeight-12)];
		leftLabel.contentMode = UIViewContentModeBottom;
		leftLabel.font = DefaultFont16;
		leftLabel.textColor = rgba(170, 170, 170, 1);
		leftLabel.text = text;
		[control addSubview:leftLabel];

		UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+kLabelWidth, 12, screenWidth-30-kLabelWidth, kViewHeight-12)];
		rightLabel.font = DefaultFont16;
		rightLabel.textColor = WeddingTimeBaseColor;
		rightLabel.textAlignment = NSTextAlignmentRight;
		[control addSubview:rightLabel];

		return rightLabel;
	};

	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-kNavBarHeight)];
	[self.view addSubview:_scrollView];

	_musicLabel = ControlBlock(10,WTThemeListTypeMusic,@"主题音乐");
	_themeLabel = ControlBlock(10+kViewHeight,WTThemeListTypeTheme,@"自定义封面");
	_musicLabel.text = [[UserInfoManager instance].backMusicName isNotEmptyCtg] ? [UserInfoManager instance].backMusicName : @"选择背景音乐";
	_themeLabel.text = @"更改";

	self.layout = [[DWFlowLayout alloc] init];
	_dataCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10+kViewHeight*2, screenWidth, 500 *Height_ato) collectionViewLayout:_layout];
	_dataCollectionView.delegate = self;
	_dataCollectionView.dataSource = self;
	_dataCollectionView.showsHorizontalScrollIndicator = NO;
	_dataCollectionView.backgroundColor = [UIColor whiteColor];
	[self.scrollView addSubview:_dataCollectionView];
	[_dataCollectionView registerNib:[UINib nibWithNibName:@"WTThemeCell" bundle:nil] forCellWithReuseIdentifier:@"WTThemeCell"];

	_contactLabel = ControlBlock(_dataCollectionView.bottom, WTThemeListTypeContact, @"联系我们");
	_contactLabel.text = showPhone ? @"已启用" : @"未启用";
	_deskLabel = ControlBlock(kViewHeight+_dataCollectionView.bottom, WTThemeListTypeDesk, @"座位表");
	_deskLabel.text = showDesk ? @"已启用" : @"未启用";
	_processLabel=ControlBlock(kViewHeight*2+_dataCollectionView.bottom,WTThemeListTypeProcess,@"婚礼流程");
	_processLabel.text = showProcess ? @"已启用" : @"未启用";

	_scrollView.contentSize = CGSizeMake(screenWidth, _dataCollectionView.bottom + kViewHeight*3 + 60);
	[self setRightBtnWithTitle:@"请柬商店"];
}

-(void)rightNavBtnEvent
{
	WTCardListViewController *cardVC = [[WTCardListViewController alloc] init];
	[self.navigationController pushViewController:cardVC animated:YES];
}

- (void)goListAction:(UIButton *)button
{
	if(button.tag == WTThemeListTypeMusic){
		WTHomeMusicViewController *musicVC = [[WTHomeMusicViewController alloc] init];
		musicVC.delegate = self;
		musicVC.musicArray = musicArray;
		musicVC.musicChoosedID = musicChoosedID;
		[self.navigationController pushViewController:musicVC animated:YES];
	}
	else if (button.tag == WTThemeListTypeTheme){
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择婚礼主页背景图片"
																 delegate:self
														cancelButtonTitle:@"取消"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"拍照",@"从相册中选",@"使用默认主题" ,nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[actionSheet showInView:self.view];
	}else if (button.tag == WTThemeListTypeContact){
		WTContactAsViewController *VC = [WTContactAsViewController instanceWithContact:showPhone];
		[VC setRefreshBlock:^(BOOL refresh) {
			_contactLabel.text = refresh ? @"已启用" : @"未启用" ;
		}];
		[self.navigationController pushViewController:VC animated:YES];
	}else if(button.tag == WTThemeListTypeDesk){
		WTDeskViewController *VC = [WTDeskViewController instanceWithShow:showDesk];
		[VC setRefreshBlock:^(BOOL refresh) {
			_deskLabel.text = refresh ? @"已启用" : @"未启用" ;
		}];
		[self.navigationController pushViewController:VC animated:YES];
	}else if(button.tag == WTThemeListTypeProcess){
		WTProcessViewController *VC = [WTProcessViewController instanceWithShow:showProcess];
		[VC setRefreshBlock:^(BOOL refresh) {
			_processLabel.text = refresh ? @"已启用" : @"未启用" ;
		}];
		[self.navigationController pushViewController:VC animated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.mediaType      = FSMediaTypePhoto;
    mediaPicker.editMode        = FSEditModeNone;
    mediaPicker.delegate       = self;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    } else if(buttonIndex == 2){
		[PostDataService postUpdateHomepageBackgroudWithImageKey:@"" withBlock:^(NSDictionary *result, NSError *error) {
			[self hideLoadingView];
			[self doloadFinishAddStory:result And:error];
		}];
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    UIImage *upLoadImage=mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
	upLoadImage = [upLoadImage imageByResizeToSize:CGSizeMake(screenWidth, screenHeight) contentMode:UIViewContentModeScaleAspectFill];
	uploadInfo = UIImageJPEGRepresentation(upLoadImage, 1.f);
	[self uploadImage];
}

#pragma mark - Upload Image
- (void)uploadImage
{
	[self showLoadingView];
	self.loadingHUD.mode = MBProgressHUDModeDeterminate;
	self.loadingHUD.progress=0.f;
	[uploadManager uploadFileWithFileInfo:uploadInfo fileType:WTFileTypeImage fileBucket:@"mt-card"];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didChangeProgress:(CGFloat)percent
{
	self.loadingHUD.progress = percent;
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFailedUpload:(NSError *)error
{
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"无法连接服务器"
																				message:@"需要重试吗?"];
	alertView.delegate = self;
	[alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
		[self uploadImage];
	}];
	[alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
	[alertView show];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFinishedUploadWithKey:(NSString *)key
{
	uploadKey = key;
	[self upLoadImageSucceed];
}

- (void)upLoadImageSucceed {
    [PostDataService postUpdateHomepageBackgroudWithImageKey:uploadKey withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doloadFinishAddStory:result And:error];
    }];
}

- (void)doloadFinishAddStory:(NSDictionary *)result And:(NSError *)error {
    [self hideLoadingView];
    if (!error) {
        [WTProgressHUD ShowTextHUD:@"修改成功" showInView:KEY_WINDOW];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
        [[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
    }else {
		[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
        AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]  initWithTitle:@"无法连接服务器" message:@"需要重试吗?"];
        [alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
             [self showLoadingView];
             [self upLoadImageSucceed];
             
         }];
        [alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
        [alertView show];
    }
}

#pragma mark - Delegate

- (void)selectMusicName:(NSString *)name andMusicId:(NSString *)musicId
{
	musicChoosedID = musicId;
	_musicLabel.text = name;
}

- (void)WTThemeCell:(WTThemeCell *)cell didSeledtedOpenCard:(UIControl *)sender
{
	[self.navigationController pushViewController:[WTCardDetailViewController instanceWithCardId:cell.theme.goods_id] animated:YES];
}

#pragma mark CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return themeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WTWeddingTheme *theme = themeArray[indexPath.row];

	WTThemeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WTThemeCell" forIndexPath:indexPath];
	cell.delegate = self;
	cell.theme = theme;
	cell.selectedButton.selected = [theme.ID isEqualToString:themeChoosedID];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return  CGSizeMake(screenWidth, 500 * Height_ato);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	WTWeddingTheme *theme = themeArray[indexPath.row];
	if ([theme.ID isEqualToString:themeChoosedID]) { return; }
	WTThemeCell *cell = (WTThemeCell *)[_dataCollectionView  cellForItemAtIndexPath:indexPath];
	cell.selectedButton.highlighted = !cell.selectedButton.highlighted;

	[self showLoadingView];
	[PostDataService POSTWeddingHomeChooseMusic:@"theme" andId:theme.ID withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (!error) {
			[UserInfoManager instance].themeSelected = [theme modelToJSONString];
			[[UserInfoManager instance] saveOtherToUserDefaults];
			[WTProgressHUD ShowTextHUD:@"选择模板成功" showInView:self.view];
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
			[self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
		}else {
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
		}
	}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
