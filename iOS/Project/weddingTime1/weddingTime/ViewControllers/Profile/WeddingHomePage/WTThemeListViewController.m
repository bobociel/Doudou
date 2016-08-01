//
//  WDThemeListViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTThemeListViewController.h"
#import "WTHomeMusicViewController.h"
#import "DWFlowLayout.h"
#import "WTThemeCell.h"
#import "FSMediaPicker.h"
#import "QiniuSDK.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTProgressHUD.h"
#import "GetService.h"
#import "PostDataService.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "LWUtil.h"
#define chooseImageBtnHeigh 44.f
#define margin 10.f
#define kNavBarHeight 64.0
#define kBottomHeight 80.0
#define kTopHeight    124.0
@interface WTThemeListViewController ()
<
    UIActionSheetDelegate,UICollectionViewDelegate,
    UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,
    FSMediaPickerDelegate, musicHasSelectDelegate
>

@end

@implementation WTThemeListViewController
{
    UIButton *chooseImageBtn;
    NSInteger themeChoosedID;
	NSInteger musicChoosedID;
    
    UIImage *upLoadImage;
    NSString *upLoadImagekey;
    NSString *upLoadImagetoken;

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

- (void)initView {
	self.title = @"请柬设置";
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];

	curSelectIndex = curSelectIndex != 0 ? curSelectIndex : 0;

	[self setMusicUI];
	[self setThemeUI];

	DWFlowLayout *layout = [[DWFlowLayout alloc] init];
	dataCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopHeight, screenWidth, screenHeight - kNavBarHeight - kTopHeight) collectionViewLayout:layout];
	dataCollectionView.delegate = self;
	dataCollectionView.dataSource = self;
	dataCollectionView.showsHorizontalScrollIndicator = NO;
	dataCollectionView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:dataCollectionView];
	[dataCollectionView registerNib:[UINib nibWithNibName:@"WTThemeCell" bundle:nil] forCellWithReuseIdentifier:@"WTThemeCell"];
}

- (void)loadData {
	void(^WTMusicSelectButtonBlock)() = ^(){
		__block BOOL hasMusic = NO;
		__block NSString *musicName = @"";
		[musicArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
			if([obj[@"id"] integerValue] == musicChoosedID){
				hasMusic = YES;
				musicName = obj[@"name"];
				return ;
			}
		}];
		musicName = musicName.length == 0 ? @"选择背景音乐" : musicName ;
		[musicSelect setTitle:musicName forState:UIControlStateNormal];
	};

	void(^WTThemeSelectBlock)() = ^(){
		__block NSInteger themeSelectIndex;
		[themeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
			if([obj[@"id"] integerValue] == themeChoosedID){
				themeSelectIndex  = idx;
				return ;
			}
		}];

		CGPoint point = CGPointMake((screenWidth - 80 - 20 * [UIScreen mainScreen].scale) * themeSelectIndex, 0);
		[dataCollectionView setContentOffset:point animated:NO];
	};

    [self showLoadingView];
    [GetService getHomePageThemeWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:dataCollectionView];
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone) {
			themeChoosedID = [result[@"data"][@"choice"][@"theme_id"] integerValue];
			musicChoosedID = [result[@"data"][@"choice"][@"music_id"] integerValue];
            themeArray = [NSArray arrayWithArray:result[@"data"][@"theme"]];
			musicArray = [NSArray arrayWithArray:result[@"data"][@"music"]];
			[dataCollectionView reloadData];
			WTMusicSelectButtonBlock();
			WTThemeSelectBlock();

            if (themeArray.count==0) {
                [NetWorkingFailDoErr errWithView:dataCollectionView content:@"暂时没有数据哦" tapBlock:^{
                    [self loadData];
                }];
                return ;
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
        make.right.mas_equalTo(-11);
        make.size.mas_equalTo(CGSizeMake(100, 17));
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
    [self showChooseImage];
}

- (void)showChooseImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择婚礼主页背景图片"
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"拍照",@"从相册中选",@"使用默认主题" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	actionSheet.delegate = self;
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
    upLoadImage=mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
    [self getQiniuToken];
}

- (void)getQiniuToken {
    [self showLoadingView];
    [GetService getQiniuTokenWithBucket:@"mt-card"  WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error||![result[@"uptoken"] isNotEmptyCtg]) {
            AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"无法连接服务器"
																						message:@"需要重试吗?"];
            [alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
                 [self getQiniuToken];
             }];
            [alertView setCancelButtonWithTitle:@"取消" onTapped:^{
             }];
            [alertView show];
        }else {
            upLoadImagetoken = result[@"uptoken"];
            [self upLoadImageWithToken:result[@"uptoken"]];
        }
    }];
    
}

- (void)upLoadImageWithToken:(NSString *)token {
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [self showLoadingView];
    self.loadingHUD.mode = MBProgressHUDModeDeterminate;
    self.loadingHUD.progress=0.f;
    QNUploadOption  *option = [[QNUploadOption alloc] initWithMime:@"image/jpeg" progressHandler:^(NSString *key, float percent) {
        self.loadingHUD.progress=percent;
    } params:nil checkCrc:NO cancellationSignal:nil];
    
    int64_t timeSince  = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSince];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    NSData *imageData = UIImageJPEGRepresentation(upLoadImage, 1.f);
    
    NSString *key = [NSString stringWithFormat:@"%@/%lu%@",dateStr,(unsigned long)[imageData hash],[LWUtil randomStringWithLength:15]];
    
    [upManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (!resp) {
            [self hideLoadingView];
            AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"无法连接服务器" message:@"需要重试吗?"];
            [alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
                 [self upLoadImageWithToken:upLoadImagetoken];
             }];
            [alertView setCancelButtonWithTitle: @"取消" onTapped:nil];
            [alertView show];
        }else {
            upLoadImagekey =  resp[@"key"];
            [self upLoadImageSucceed];
        }
    } option:option];
}

- (void)upLoadImageSucceed {
    [PostDataService postUpdateHomepageBackgroudWithImageKey:upLoadImagekey withBlock:^(NSDictionary *result, NSError *error) {
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
        AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]  initWithTitle:@"无法连接服务器" message:@"需要重试吗?"];
        [alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
             [self showLoadingView];
             [self upLoadImageSucceed];
             
         }];
        [alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
        [alertView show];
    }
}

#pragma mark MusicDelegate

- (void)selectMusicName:(NSString *)name
{
    [musicSelect setTitle:name forState:UIControlStateNormal];
}

#pragma mark CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return themeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WTThemeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WTThemeCell" forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	cell.selectedButton.selected = [themeArray[indexPath.row][@"id"]intValue]==themeChoosedID;

	NSString *imageURL = [LWUtil getString:themeArray[indexPath.row][@"path"] andDefaultStr:@""];
	cell.imageView.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	[cell.imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
										placeholderImage:nil
												 options:SDWebImageRetryFailed
												progress:nil
											   completed:nil
									ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
								  ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												Diameter:50];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([themeArray[indexPath.row][@"id"]intValue]==themeChoosedID) {
		return;
	}
	WTThemeCell *cell = (WTThemeCell *)[dataCollectionView  cellForItemAtIndexPath:indexPath];
	cell.selectedButton.highlighted = !cell.selectedButton.highlighted;

	[self showLoadingView];
	[PostDataService POSTWeddingHomeChooseMusic:@"theme" andId:[themeArray[indexPath.row][@"id"]intValue] withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (!error) {
			[WTProgressHUD ShowTextHUD:@"选择模板成功" showInView:self.view];
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
			[self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
		}else {
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
		}

	}];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(screenWidth - 80, screenHeight- kTopHeight - kNavBarHeight);
}

@end
