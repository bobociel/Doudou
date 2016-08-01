//
//  WDStoryViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "WTStoryListViewController.h"
#import "WeddingHomePageStoryCell.h"
#import "WTImageSelectViewController.h"
#import "WTNoDataCell.h"
#import "WTWebViewCell.h"
#import "FSMediaPicker.h"
#import "WTProgressHUD.h"
#import "MJRefresh.h"
#import "WTAlertView.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTUploadManager.h"
#import "PostDataService.h"
#import "GetService.h"
#define kPageSize      10
#define kNavBarHeight  64.0
#define kAddBtnHright  44.0
#define kImageHeight   120.0
#define kSegmnetTop    8.0
#define kSegmentLeft   70.0
#define kSegmentHeight 27.0
#define kUploadImageString @"上传图片"
#define kUploadVideoString @"上传视频"
#define kAlertVideoString  @"修改视频"
#define kCancelVideoString @"取消上传"

@interface WTStoryListViewController ()
<
    UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,
    FSMediaPickerDelegate,WTUploadDelegate,WeddingHomePageStoryCellDelegate,WTWebViewCellDelegate
>
@end

@implementation WTStoryListViewController
{
    UISegmentedControl *segmentControl;
    UITableView *dataTableView;
    UIButton       *addButton;
    NSInteger     currentSegmentIndex;

    WTUploadManager *uploadManager;
	WTWeddingStory *uploadStory;
	NSMutableArray *uploadStorys;
	id uploadInfo;
    
    NSMutableArray *photoStoryList;
    WTWeddingStory *videoStory;
}

#pragma mark - View Circle
- (void)viewDidLoad {
	[super viewDidLoad];
	photoStoryList = [NSMutableArray array];
	uploadStorys = [NSMutableArray array];
	[self initView];
	[self loadDataShowHUD:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[segmentControl removeFromSuperview];
}

- (void)initView {
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] ];

	dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-kNavBarHeight-kAddBtnHright)];
	dataTableView.backgroundColor = [UIColor whiteColor];
	dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	dataTableView.backgroundView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:dataTableView];
	dataTableView.delegate   = self;
	dataTableView.dataSource = self;

	addButton = [UIButton buttonWithType:UIButtonTypeSystem];
	addButton.frame = CGRectMake(0, screenHeight-kNavBarHeight-kAddBtnHright, screenWidth, kAddBtnHright);
	[addButton setTitle:kUploadImageString forState:UIControlStateNormal];
	[addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	addButton.backgroundColor = [[WeddingTimeAppInfoManager instance] baseColor];
	[self.view addSubview:addButton];
	[addButton addTarget:self action:@selector(showChooseImage:) forControlEvents:UIControlEventTouchUpInside];

	[self setupFooterRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];

    if(dataTableView.footer.hidden == YES){
        dataTableView.footer.hidden = YES;
    }
    
	uploadManager = [WTUploadManager manager];
	uploadManager.delegate = self;
	if([uploadManager hasCache]){
		currentSegmentIndex = SegmentTypeVideo;
		[self resumeUploadWithAlertViewComplectionBlock:^(BOOL isStop) {
			if(isStop){
				[self.navigationController popViewControllerAnimated:YES];
			}
		}];
	}

	segmentControl  = [[UISegmentedControl alloc] initWithItems:@[@"图片故事",@"视频故事"]];
	segmentControl.frame = CGRectMake(kSegmentLeft, kSegmnetTop, screenWidth-2*kSegmentLeft, kSegmentHeight);
	segmentControl.selectedSegmentIndex = currentSegmentIndex;
	segmentControl.tintColor = [[WeddingTimeAppInfoManager instance] baseColor];
	[self.navigationController.navigationBar addSubview:segmentControl];
	[segmentControl addTarget:self action:@selector(segmentChangeIndex:) forControlEvents:UIControlEventValueChanged];

	currentSegmentIndex == SegmentTypePhoto ? [self setRightBtnWithTitle:@"排序"] : [self setRightBtnWithTitle:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardFrameChanged:(NSNotification *)noti
{
	CGRect keyFrame =  [(NSValue *)noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	if(keyFrame.origin.y == screenHeight){
		dataTableView.frame = CGRectMake(0, 0, screenWidth, keyFrame.origin.y - kNavBarHeight -kAddBtnHright);
	}else{
		[UIView animateKeyframesWithDuration:0.25 delay:0 options:7 animations:^{
			dataTableView.frame = CGRectMake(0, 0, screenWidth, keyFrame.origin.y - kNavBarHeight);
		} completion:nil];
	}
}

- (void)back
{
	if(uploadManager.uploadState == WTUploadStatueUploading){
		[self stopUploadWithAlertViewComplectionBlock:^(BOOL isStop){
			 if(isStop){
				 [self.navigationController popViewControllerAnimated:YES];
			 }
		 }];
	}else{
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)segmentChangeIndex:(UISegmentedControl *)segment
{
	if(segmentControl.selectedSegmentIndex != currentSegmentIndex){
		if(uploadManager.uploadState == WTUploadStatueUploading){
			[self stopUploadWithAlertViewComplectionBlock:^(BOOL isStop) {
				if(isStop){
					currentSegmentIndex = segmentControl.selectedSegmentIndex;
					[dataTableView reloadData];
				}else{
					segment.selectedSegmentIndex = currentSegmentIndex;
				}
			}];
		}else{
			currentSegmentIndex = segmentControl.selectedSegmentIndex;
			[dataTableView reloadData];
		}
	}

	if(currentSegmentIndex == SegmentTypeVideo){
		dataTableView.footer.hidden = YES;
		NSString *addButtonTitle = [videoStory hasSource] ? kAlertVideoString : kUploadVideoString;
		[addButton setTitle:addButtonTitle forState:UIControlStateNormal];
		if(![videoStory hasSource]){
			[self loadVideoDataShowHUD:YES];
		}
	}

	if(currentSegmentIndex == SegmentTypePhoto){
		if(dataTableView.hidden){
			dataTableView.hidden = YES;
		}
		[addButton setTitle:kUploadImageString forState:UIControlStateNormal];
	}

	currentSegmentIndex == SegmentTypePhoto ? [self setRightBtnWithTitle:@"排序"] : [self setRightBtnWithTitle:nil];
}

- (void)rightNavBtnEvent
{
	if(!dataTableView.isEditing)
	{
		[dataTableView setEditing:YES animated:YES];
		[self setRightBtnWithTitle:@"完成"];
	}else
	{
		[dataTableView setEditing:NO animated:YES];
		[self setRightBtnWithTitle:@"排序"];
		[self doSortData];
	}
}

#pragma mark - Load Data
- (void)loadVideoDataShowHUD:(BOOL)show
{
	if(show){
		[self showLoadingView];
	}
	[GetService getHomePageStoryWithPage:0 andMediaType:@"video" WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error)
		{
			videoStory = [WTWeddingStory modelWithDictionary:result[@"data"]];
			[dataTableView reloadData];

			dataTableView.footer.hidden = YES;
			NSString *buttonTitle = [videoStory hasSource] ? kAlertVideoString : kUploadVideoString ;
			[addButton setTitle:buttonTitle forState:UIControlStateNormal];
		}else
		{
			dataTableView.footer.hidden = YES;
			NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@"暂时没有数据哦"];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
		}
	}];
}

- (void)loadDataShowHUD:(BOOL)isShow
{
	if(isShow){
		[self showLoadingView];
	}

	photoStoryList = [NSMutableArray array];
    dataTableView.footer.hidden = YES;
    [GetService getHomePageStoryWithPage:1 andMediaType:@"image" WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
        if (!error) {
			NSArray *storys = [NSArray modelArrayWithClass:[WTWeddingStory class] json:result[@"data"]];
            [photoStoryList addObjectsFromArray:storys];
            [dataTableView reloadData];
			dataTableView.footer.hidden = storys.count < kPageSize;
        }
        else
        {
            dataTableView.footer.hidden = YES;
            NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@"暂时没有数据哦"];
            [WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
        }
    }];
}

- (void)setupFooterRefresh
{
	//set up refresh
	dataTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		NSInteger addPageCount = photoStoryList.count % kPageSize == 0 ? 1 : 2;
		NSInteger page = photoStoryList.count/kPageSize + addPageCount;
		[GetService getHomePageStoryWithPage:page andMediaType:@"image" WithBlock:^(NSDictionary *result, NSError *error) {
			[dataTableView.footer endRefreshing];
			if(!error){
				NSArray *storys = [NSArray modelArrayWithClass:[WTWeddingStory class] json:result[@"data"]];
				[photoStoryList addObjectsFromArray:storys];
				[dataTableView reloadData];
				dataTableView.footer.hidden = storys.count < kPageSize;
			}else{
				NSString *errMsg = [LWAssistUtil getCodeMessage:error andDefaultStr:@""];
				[WTProgressHUD ShowTextHUD:errMsg showInView:self.view];
			}
		}];
	}];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (photoStoryList.count > 0 && currentSegmentIndex == SegmentTypePhoto) ? photoStoryList.count : 1 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( photoStoryList.count > 0 && currentSegmentIndex == SegmentTypePhoto ){
        WeddingHomePageStoryCell *cell = [tableView WeddingHomePageStoryCell];
        cell.stroy = photoStoryList[indexPath.row];
		cell.delegate = self;
        return cell;
    }
	if( [videoStory hasSource] && SegmentTypeVideo == currentSegmentIndex){
		WTWebViewCell *cell = [WTWebViewCell webCellWithTableView:tableView];
		cell.delegate = self;
		cell.story = videoStory;
		return cell;
	}
	else{
        WTNoDataCell *cell = [WTNoDataCell NoDataCellWithTableView:tableView];
        cell.noDataLabel.text = SegmentTypePhoto == currentSegmentIndex ? @"还没有上传图片故事":@"还没有上传视频故事" ;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return (photoStoryList.count > 0 && currentSegmentIndex == SegmentTypePhoto) ? kImageHeight : screenHeight - kNavBarHeight - kAddBtnHright ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<[photoStoryList count] && currentSegmentIndex == SegmentTypePhoto && photoStoryList.count > 0) {
//        WTStoryDetailViewController *WDDetailVC = [[WTStoryDetailViewController alloc] init];
//        WDDetailVC.story = photoStoryList[indexPath.row] ;
//        [self.navigationController pushViewController:WDDetailVC animated:YES];
    }
}

#pragma mark Cell Delegate
-(void)WTWebCellDidSelected:(WTWebViewCell *)cell andVideoURL:(NSURL *)videoURL
{
	if([WTUploadManager manager].reachebility.isReachableViaWiFi){
		MPMoviePlayerViewController *videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
		[self presentMoviePlayerViewControllerAnimated:videoVC];
	}else{
		WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"当前网络非wifi环境是否播放视频" centerImage:nil];
		[alertView setButtonTitles:@[@"取消",@"确定"]];
		[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
			[alertView close];
			if(buttonIndex == 1){
				MPMoviePlayerViewController *videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
				[self presentMoviePlayerViewControllerAnimated:videoVC];
			}
		}];
		[alertView show];
	}
}

- (void)WeddingHomePageStringDidBeignEdit:(WeddingHomePageStoryCell *)cell
{
	NSIndexPath *indexPath = [dataTableView indexPathForCell:cell];
	[dataTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)WeddingHomePageStringDidEndEdit:(WeddingHomePageStoryCell *)cell
{
//	cell.stroy.content = cell.textView.text;
//	[PostDataService postWeddingHomeModifyStoryWithStory:cell.stroy withBlock:^(NSDictionary *result, NSError *error) {
//		
//	}];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

#pragma mark - TableViewEdit
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return photoStoryList.count > 0 ;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *curData = [photoStoryList mutableCopy];
    [curData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    photoStoryList = [curData mutableCopy];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	return photoStoryList.count > 0 && currentSegmentIndex == SegmentTypePhoto;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  dataTableView.isEditing ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete){
         [self delegatePlan:indexPath];
     }
 }

- (void)delegatePlan:(NSIndexPath *)indexPath {
    
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]  initWithTitle:@"删除婚礼故事" message:@"确定删除该条婚礼故事?" ];
	alertView.delegate = self;
    [alertView addOtherButtonWithTitle:@"删除" onTapped:^{
         [self showLoadingView];
		__block WTWeddingStory *story = photoStoryList[indexPath.row];
         [PostDataService postWeddingHomeDelegate:story.ID withBlock:^(NSDictionary *result, NSError *error) {
             [self hideLoadingView];
             if (!error) {
				 [photoStoryList removeObjectAtIndex:indexPath.row];
				 [[SDImageCache sharedImageCache] removeImageForKey:story.media.length > 0 ? story.media : story.path ];
				 if(photoStoryList.count >0){
					 [dataTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
				 }else{
					 [dataTableView reloadData];
				 }

				 if(photoStoryList.count < 5){
					 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
						 [self loadDataShowHUD:NO];
					 });
				 }
             }else {
				 [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@"暂时没有数据哦"] showInView:self.view];
             }
         }];
     }];
    [alertView setCancelButtonWithTitle:@"取消" onTapped:^{
         [dataTableView reloadRowsAtIndexPaths:@[ indexPath] withRowAnimation:UITableViewRowAnimationRight];
     }];
    [alertView show];
}

- (void)doSortData {
    NSMutableArray *sortIds = [[NSMutableArray alloc] initWithCapacity:50];
    for(WTWeddingStory *story in photoStoryList) {
        [sortIds addObject:@(story.ID)];
    }
    [PostDataService postWeddingHomeStorySortWithSortArr:[sortIds mutableCopy] withBlock:^(NSDictionary *result, NSError *error) {

    }];
}

#pragma mark  - AlertView And Picker View
- (void)showChooseImage:(UIButton *)btn {
    if([btn.currentTitle isEqualToString:kCancelVideoString]){
        [self stopUploadWithAlertViewComplectionBlock:^(BOOL isStop) {
        }];
    }else{
        NSString *title = currentSegmentIndex == SegmentTypePhoto ? @"选择故事照片" : @"选择故事视频";
        NSString *takeTitle = currentSegmentIndex == SegmentTypePhoto ? @"拍照" : @"拍摄";
        NSString *selectTitle = currentSegmentIndex == SegmentTypePhoto ? @"从相册中选": @"从视频中选" ;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
																 delegate:self
														cancelButtonTitle:@"取消"
												   destructiveButtonTitle:nil
														otherButtonTitles:takeTitle,selectTitle ,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0)
	{
		FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
        mediaPicker.mediaType = currentSegmentIndex == SegmentTypePhoto ? FSMediaTypePhoto : FSMediaTypeVideo;
		mediaPicker.editMode = FSEditModeNone;
		mediaPicker.delegate = self;
		currentSegmentIndex == SegmentTypePhoto ? [mediaPicker takePhotoFromCamera] : [mediaPicker takeVideoFromCamera] ;
    }
	else if (buttonIndex==1 )
	{
		WTImageSelectViewController *selectVC = [[WTImageSelectViewController alloc] init];
		selectVC.fileType =  currentSegmentIndex == SegmentTypePhoto ? WTFileTypeImage :WTFileTypeVideo ;
		[selectVC setBlock:^(WTFileType fileType,NSArray *array, NSString *filePath) {
			uploadInfo = array.count > 0 ? array : filePath;
			[self uploadWithFileOrData];
		}];
		[self.navigationController pushViewController:selectVC animated:YES];
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    if(SegmentTypeVideo == currentSegmentIndex)
    {
		[WTUploadManager saveMediaWith:mediaInfo callback:^(BOOL saved, NSString *filePath) {
			dispatch_async(dispatch_get_main_queue(), ^{
				uploadInfo = filePath;
				[self uploadWithFileOrData];
			});
		}];
    }else{
        UIImage *uploadImage = mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
         uploadInfo = UIImageJPEGRepresentation(uploadImage, 1.f);
    }
    [self uploadWithFileOrData];
}

#pragma mark - WTUploadDelegate Upload
- (void)uploadWithFileOrData
{
    currentSegmentIndex == SegmentTypePhoto ? [self showLoadingView] : [self showLoadingView:dataTableView];
    self.loadingHUD.progress=0.f;
    self.loadingHUD.mode = currentSegmentIndex == SegmentTypePhoto ? MBProgressHUDModeDeterminate : MBProgressHUDModeAnnularDeterminate;
    self.loadingHUD.mode = [uploadInfo isKindOfClass:[NSArray class]] ? MBProgressHUDModeIndeterminate : self.loadingHUD.mode ;

    WTFileType fileType = currentSegmentIndex == SegmentTypePhoto ? WTFileTypeImage : WTFileTypeVideo;
	[uploadManager uploadFileWithFileInfo:uploadInfo fileType:fileType];
}

- (void)stopUploadWithAlertViewComplectionBlock:(StopUploadBlock )block{
    uploadManager.isCancelUpload = YES;
    self.loadingHUD.hidden = YES;
    WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"确定放弃本次上传" centerImage:nil];
    [alertView setButtonTitles:@[@"取消",@"确定"]];
    [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
        [alertView close];
        if(buttonIndex == 1){
            [self hideLoadingView];
			[uploadManager deleteCache];
            block(YES);
        }else{
            self.loadingHUD.hidden = NO;
            [uploadManager resumeUploadCache];
            block(NO);
        }
    }];
    [alertView show];
}

- (void)resumeUploadWithAlertViewComplectionBlock:(StopUploadBlock )block{
    uploadManager.isCancelUpload = YES;
    self.loadingHUD.hidden = YES;
    WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"视频上传被中断是否续传？" centerImage:nil];
    [alertView setButtonTitles:@[@"取消",@"确定"]];
    [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
        [alertView close];
        if(buttonIndex == 0){
            [self hideLoadingView];
			//时时更新界面
			NSString *buttonTitle = [videoStory hasSource] ? kAlertVideoString : kUploadVideoString ;
			[addButton setTitle:buttonTitle forState:UIControlStateNormal];

            [uploadManager deleteCache];
            block(YES);
        }else{
			[self showLoadingView:dataTableView];
			self.loadingHUD.progress=0.f;
			self.loadingHUD.mode = MBProgressHUDModeAnnularDeterminate;
            [uploadManager resumeUploadCache];
            block(NO);
        }
    }];
    [alertView show];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didChangeUploadState:(WTUploadStatue)statue
{
    if(currentSegmentIndex == SegmentTypeVideo){
        if(statue == WTUploadStatueUploading){
            [addButton setTitle:kCancelVideoString forState:UIControlStateNormal];
        }else if (statue == WTUploadStatueFinished){
            [addButton setTitle:kAlertVideoString forState:UIControlStateNormal];
        }else{
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *buttonTitle = [videoStory hasSource] ? kAlertVideoString : kUploadVideoString ;
				[addButton setTitle:buttonTitle forState:UIControlStateNormal];
			});
        }
    }
}

- (void)uploadManager:(WTUploadManager *)uploadManager didChangeProgress:(CGFloat)percent
{
    self.loadingHUD.progress= percent;
    currentSegmentIndex == SegmentTypeVideo ? self.loadingHUD.labelText = [NSString stringWithFormat:@"%0.f%%",percent*100] : @"" ;
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFinishedUploadWithKey:(NSString *)key
{
	//上传服务器,图片统一上传
	if([uploadInfo isKindOfClass:[NSArray class]] ){
		WTWeddingStory *story = [[WTWeddingStory alloc] init];
		story.media = key;
		story.media_type = WTFileTypeImage;
		[uploadStorys addObject:story];
		if([(NSArray *)uploadInfo count] == uploadStorys.count && uploadStorys.count > 0){
			[self uploadStory];
		}
	}
	else{
		uploadStory = [[WTWeddingStory alloc] init];
		uploadStory.media = key;
		uploadStory.ID = currentSegmentIndex == SegmentTypePhoto ? 0 : videoStory.ID  ;
		uploadStory.media_type = currentSegmentIndex == SegmentTypePhoto ? WTFileTypeImage : WTFileTypeVideo;
		[self uploadStory];
	}
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFailedUpload:(NSError *)error
{
    [self hideLoadingView];
    if(error.code == File_Not_Exist){
        WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"上传文件不存在" centerImage:nil];
        [alertView setButtonTitles:@[@"关闭"]];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            [alertView close];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertView show];
    }else{
        WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"无法连接服务器,需要重试吗？" centerImage:nil];
        [alertView setButtonTitles:@[@"取消",@"重新上传"]];
        [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
            [alertView close];
            if(buttonIndex == 1){
                [self uploadWithFileOrData];
            }
        }];
        [alertView show];
    }
}

#pragma mark - Upload To Server
- (void)uploadStory
{
	[PostDataService postWeddingHomeUpadateStoryWithStory:uploadStory orStorys:(NSArray *)uploadStorys withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (!error) {
			if(SegmentTypePhoto == currentSegmentIndex){
				[self loadDataShowHUD:YES];
			}else{
				[self loadVideoDataShowHUD:NO];
			}

			uploadStory = nil;
			uploadStorys = [NSMutableArray array];
			[WTProgressHUD ShowTextHUD:[photoStoryList count]?@"修改成功":@"成功新建故事" showInView:KEY_WINDOW];
		}else {
			WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"无法连接服务器,需要重试吗？" centerImage:nil];
			[alertView setButtonTitles:@[@"取消",@"重新上传"]];
			[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
				[alertView close];
				if(buttonIndex == 1){
					[self uploadWithFileOrData];
				}
			}];
		}
	}];
}


@end

