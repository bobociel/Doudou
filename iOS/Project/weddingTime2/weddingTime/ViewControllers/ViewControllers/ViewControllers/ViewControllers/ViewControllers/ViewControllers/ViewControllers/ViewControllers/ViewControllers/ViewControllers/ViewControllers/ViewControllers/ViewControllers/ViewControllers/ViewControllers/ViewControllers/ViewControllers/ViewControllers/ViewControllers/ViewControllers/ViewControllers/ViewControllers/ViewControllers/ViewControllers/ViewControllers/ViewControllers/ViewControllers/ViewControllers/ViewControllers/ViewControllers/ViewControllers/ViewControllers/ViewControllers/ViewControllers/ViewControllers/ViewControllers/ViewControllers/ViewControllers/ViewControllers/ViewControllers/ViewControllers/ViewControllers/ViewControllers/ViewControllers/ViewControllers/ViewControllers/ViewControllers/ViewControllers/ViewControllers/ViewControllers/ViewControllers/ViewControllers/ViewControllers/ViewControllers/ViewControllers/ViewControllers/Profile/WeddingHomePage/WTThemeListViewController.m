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
#define chooseImageBtnHeigh 44.f
#define margin 10.f
#define kBottomHeight 80.0
#define kTopHeight    124.0
#define kItemSpace    80.0
#define kItemLeftSpace (20.0 + (screenHeight == 480 ? 10 : 0) )
@interface WTThemeListViewController ()
<
    UIActionSheetDelegate,UICollectionViewDelegate,
    UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,
    FSMediaPickerDelegate, musicHasSelectDelegate,WTUploadDelegate,WTThemeCellDelegate
>

@end

@implementation WTThemeListViewController
{
    UIButton *chooseImageBtn;
    NSString *themeChoosedID;
	NSString *musicChoosedID;

	id  uploadInfo;
	NSString *uploadKey;
	WTUploadManager *uploadManager;

    UICollectionView *dataCollectionView;
    
    NSArray *themeArray;
	NSArray *musicArray;
    UIButton *musicSelect;
    UIButton *themeSelect;
    NSInteger curSelectIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    themeArray = [NSArray array];
	musicArray = [NSArray array];
	uploadManager = [WTUploadManager manager];
	uploadManager.delegate = self;

    [self initView];
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

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)initView {
	self.title = @"请柬设置";
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];

	curSelectIndex = curSelectIndex != 0 ? curSelectIndex : 0;

	[self setMusicUI];
	[self setThemeUI];

	DWFlowLayout *layout = [[DWFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(screenWidth - kItemSpace , screenHeight- kTopHeight - kNavBarHeight);

	dataCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopHeight, screenWidth, screenHeight - kNavBarHeight - kTopHeight) collectionViewLayout:layout];
	dataCollectionView.delegate = self;
	dataCollectionView.dataSource = self;
	dataCollectionView.showsHorizontalScrollIndicator = NO;
	dataCollectionView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:dataCollectionView];
	[dataCollectionView registerNib:[UINib nibWithNibName:@"WTThemeCell" bundle:nil] forCellWithReuseIdentifier:@"WTThemeCell"];

	[self setRightBtnWithTitle:@"请柬商店"];
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
		[musicSelect setTitle:musicName forState:UIControlStateNormal];
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

		CGPoint point = CGPointMake( (screenWidth - kItemSpace - kItemLeftSpace * [UIScreen mainScreen].scale) * themeSelectIndex, 0);
		[dataCollectionView setContentOffset:point animated:NO];
	};

    [self showLoadingView];
    [GetService getHomePageThemeWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:dataCollectionView];
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone)
		{
			themeChoosedID = [LWUtil getString:result[@"data"][@"choice"][@"theme_id"] andDefaultStr:@""] ;
			musicChoosedID = [LWUtil getString:result[@"data"][@"choice"][@"music_id"] andDefaultStr:@""]; ;
            themeArray = [NSArray modelArrayWithClass:[WTWeddingTheme class] json:result[@"data"][@"theme"]];
			musicArray = [NSArray modelArrayWithClass:[WTWeddingTheme class] json:result[@"data"][@"music"]] ;
			[dataCollectionView reloadData];
			WTMusicSelectButtonBlock();
			WTThemeSelectBlock();
            if (themeArray.count==0) {
                [NetWorkingFailDoErr errWithView:dataCollectionView content:@"暂时没有数据哦" tapBlock:^{
                    [self loadData];
                }];
            }
        }
        else
        {
            NSString * errorContent=[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil];
            [WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
            [NetWorkingFailDoErr errWithView:dataCollectionView content:errorContent tapBlock:^{
                [self loadData];
            }];
        }
    }];
}

- (void)setMusicUI
{
    UILabel *musicPromt = [UILabel new];
    musicPromt.text = @"主题音乐";
    musicPromt.textColor = rgba(170, 170, 170, 170);
    [self.view addSubview:musicPromt];
    musicPromt.font = [WeddingTimeAppInfoManager fontWithSize:16];
    [musicPromt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(34);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(100, 17));
    }];
    
    musicSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:musicSelect];
    [musicSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(34);
		make.left.mas_equalTo(musicPromt.mas_right).with.offset(2.0);
        make.right.mas_equalTo(-11);
		make.height.mas_equalTo(17);
    }];

    musicSelect.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    musicSelect.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    musicSelect.contentMode = UIViewContentModeRight;

    if ([[UserInfoManager instance].backMusicName isNotEmptyCtg]) {
        [musicSelect setTitle:[UserInfoManager instance].backMusicName forState:UIControlStateNormal];
    } else {
		[musicSelect setTitle:@"选择背景音乐" forState:UIControlStateNormal];
    }

    [musicSelect setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    [musicSelect addTarget:self action:@selector(chooseMusic:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 123 - 64, screenWidth - 15, 1)];
    levelImage.image = [LWUtil imageWithColor:rgba(221, 221, 221, 1) frame:CGRectMake(0, 0, screenWidth, 0.3)];
    [self.view addSubview:levelImage];
}

- (void)setThemeUI
{
    UILabel *themePromt = [UILabel new];
    themePromt.text = @"自定义封面";
    themePromt.textColor = rgba(170, 170, 170, 170);
    [self.view addSubview:themePromt];
    themePromt.font = [WeddingTimeAppInfoManager fontWithSize:16];
    [themePromt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(149 - 64 );
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(100, 17));
    }];
    themeSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:themeSelect];
    [themeSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(149 - 64);
        make.right.mas_equalTo(-11);
        make.size.mas_equalTo(CGSizeMake(100, 17));
    }];
    themeSelect.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    themeSelect.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    themeSelect.contentMode = UIViewContentModeRight;
    [themeSelect setTitle:@"更改" forState:UIControlStateNormal];
    [themeSelect setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    [themeSelect addTarget:self action:@selector(showChooseImage) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 173 - 64, screenWidth - 15, 1)];
    levelImage.image = [LWUtil imageWithColor:rgba(221, 221, 221, 1) frame:CGRectMake(0, 0, screenWidth, 0.3)];
    [self.view addSubview:levelImage];
}

-(void)rightNavBtnEvent
{
	WTCardListViewController *cardVC = [[WTCardListViewController alloc] init];
	[self.navigationController pushViewController:cardVC animated:YES];
}

- (void)showChooseImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择婚礼主页背景图片"
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"拍照",@"从相册中选",@"使用默认主题" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)chooseMusic:(UIButton *)button
{
    WTHomeMusicViewController *musicVC = [[WTHomeMusicViewController alloc] init];
    musicVC.delegate = self;
	musicVC.musicArray = musicArray;
	musicVC.musicChoosedID = musicChoosedID;
    [self.navigationController pushViewController:musicVC animated:YES];
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
    [musicSelect setTitle:name forState:UIControlStateNormal];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	WTWeddingTheme *theme = themeArray[indexPath.row];
	if ([theme.ID isEqualToString:themeChoosedID]) { return; }
	WTThemeCell *cell = (WTThemeCell *)[dataCollectionView  cellForItemAtIndexPath:indexPath];
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

@end
