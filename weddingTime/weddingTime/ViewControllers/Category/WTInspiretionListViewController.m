//
//  InspiretionListViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTInspiretionListViewController.h"
#import "InspirationViewCell.h"
#import "GetService.h"
#import "PostDataService.h"
#import "MJRefresh.h"
#import "NetWorkingFailDoErr.h"
#import "WTProgressHUD.h"
#import "PhotoBroswerVC.h"
#import "CommAnimationForControl.h"
#import "WTSearchViewController.h"
#import "ChatMessageManager.h"
#define kNavBarHeight      64.0
#define kSegmentMentHeight 50.0
@interface WTInspiretionListViewController ()<InspirationViewCellDelegate,PhotoModelDelegate>
{
    int page;
    int maxPageCount;
    
    AFHTTPRequestOperation *lastRequest;
}
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation WTInspiretionListViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
	self.items = [NSMutableArray array];
	[self initView];
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)errWithView:(UIView*)view content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block
{
    if (self.isFromSearch) {
        UIFont *font = DefaultFont16;
        [NetWorkingFailDoErr errWithView:view frame:CGRectMake(0, 0, screenWidth, 160) backColor:defaultLineColor font:font textColor:[UIColor whiteColor] content:content tapBlock:block];
    }
    else
    {
        [NetWorkingFailDoErr errWithView:view content:content tapBlock:^{
        }];
    }
}

- (void)loadData {
    if (page<=1)
	{
        if (self.isFromSearch)
		{
            if ([self.items count]==0) {
                [NetWorkingFailDoErr removeAllErrorViewAtView:self.dataCollectionView];
                [self errWithView:self.dataCollectionView content:@"搜索中..." tapBlock:^{
                }];
            }
        }
        else
        {
            [self showLoadingView];
        }
    }
    if (self.showWithLike)
	{
        [GetService getLikeListWithTypeId:3 andPage:page WithBlock:^(NSDictionary *result, NSError *error) {
            [self doloadFinishBlock:result And:error];
        }];
        return;
    }

    if (lastRequest)
    {
        [lastRequest cancel];
    }
    if ([self.searchTag isNotEmptyCtg])
	{
        lastRequest= [GetService getSearchInspiretionTagWithPage:page andtag:self.searchTag WithBlock:^(NSDictionary *result, NSError *error) {
            [self doloadFinishBlock:result And:error];
        }];
    }
	else
	{
        lastRequest=[GetService getSearchInspiretionColorWithPage:page andColor:[self.searchColor[@"value"] stringByReplacingOccurrencesOfString:@"#" withString:@""] WithBlock:^(NSDictionary *result, NSError *error) {
            [self doloadFinishBlock:result And:error];
        }];
    }
}

- (void)doloadFinishBlock:(NSDictionary *)result And:(NSError *)error {
    [self hideLoadingView];
    [self.dataCollectionView.footer endRefreshing];
    [NetWorkingFailDoErr removeAllErrorViewAtView:self.dataCollectionView];
    NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
    if (errorType==NetWorkStatusTypeNone) {
        if (self.showWithLike) {
            NSMutableArray *array=[NSMutableArray arrayWithArray:result[@"data"]];
            for (int i=0;i<array.count; i++) {
                NSMutableDictionary *mDic=[NSMutableDictionary dictionaryWithDictionary:array[i]];
                [mDic setObject:@"1" forKey:@"is_like"];//喜欢列表不返回is_like字段
                [array replaceObjectAtIndex:i withObject:mDic];
            }
            NSMutableDictionary *resultDic=[NSMutableDictionary dictionaryWithDictionary:result];
            [resultDic setObject:array forKey:@"data"];
            result=resultDic;
        }
        
        page++;
        id pagedata=result[@"data"];
        [self.items addObjectsFromArray:pagedata];
        if ([pagedata count]<maxPageCount)
		{
			self.dataCollectionView.footer =nil;
        }
        else
        {
            [self initRefresh];
        }
        [self.dataCollectionView reloadData];
        
        if ([self.items count] == 0) {
            [self errWithView:self.dataCollectionView content:@"暂时没有灵感哦" tapBlock:^{
                [self loadData];
            }];
        }
    }
    else
    {
        NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@"暂时没有灵感哦"];
        [WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
        if (page<=1) {
            [self errWithView:self.dataCollectionView content:errorContent tapBlock:^{
                [self loadData];
            }];
        }
    }
}

#pragma mark PSCollectionView
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    if (index >= self.items.count) { return nil; }

    NSDictionary *item = [self.items objectAtIndex:index];

    InspirationViewCell *v = (InspirationViewCell *)[self.dataCollectionView InspirationViewCell];
    v.delegate=self;
    [v setInfo:item];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    return [InspirationViewCell heightForViewWithObject:item inColumnWidth:self.dataCollectionView.colWidth];;
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    [self networkImageShow:index];
}

- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

- (void)beginSearchWithsearchTag:(NSString *)searchTag {
    self.searchTag = searchTag;
    self.items = [NSMutableArray array];
    [self.dataCollectionView reloadData];
    page=1;
    [self loadData];
}

- (void)initRefresh
{
    self.dataCollectionView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadData];
    }];
}

-(void)initView
{
    [self setRightBtnWithImage:[UIImage imageNamed:@"btn_search"]];

	CGFloat height = _showWithLike ? screenHeight - kNavBarHeight - kSegmentMentHeight : screenHeight - kNavBarHeight ;
    self.dataCollectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, height)];
    self.dataCollectionView.backgroundColor = [UIColor clearColor];
    self.dataCollectionView.collectionViewDelegate = self;
    self.dataCollectionView.collectionViewDataSource = self;
    self.dataCollectionView.numColsPortrait = 2;
    self.dataCollectionView.numColsLandscape = 3;
	self.dataCollectionView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_dataCollectionView];
    
    page=1;
    self.title = self.searchTag?self.searchTag:self.searchColor[@"name"]?self.searchColor[@"name"]:@"";
    maxPageCount = 30;
}

-(void)rightNavBtnEvent
{
    [self.navigationController pushViewController:[WTSearchViewController new] animated:YES];
}

#pragma mark InspirationViewCellDelegate
- (void)doFav:(int)listid :(UIButton*)btn{
    if (![LWAssistUtil isLogin]) {
        return;
    }
    
    [PostDataService postInspirationLikeWithImageId:listid withBlock:^(NSDictionary *result, NSError *error) {
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone) {
            BOOL isFav = false;
            InspirationViewCell *cell;
            NSMutableDictionary *mudic;
            for(int i=0;i<self.items.count;i++ ) {
                mudic = [self.items[i] mutableCopy];
                if ([mudic[@"cover_id"] intValue]==listid) {
                    isFav=[mudic[@"is_like"] boolValue];
                    isFav=!isFav;
                    mudic[@"is_like"]=@(isFav);
                    if (self.showWithLike) {
                        if (!isFav) {
                            [self.items removeObjectAtIndex:i];
                        }
                    }
                    else
                    {
                        [self.items replaceObjectAtIndex:i withObject:[mudic copy]];
                    }
                    
                    cell=(InspirationViewCell*)[self.dataCollectionView getCellWithIndex:i];
                    break;
                }
            }
            
            NSInteger num_like = [UserInfoManager instance].num_like.integerValue;
            if (isFav) {
                num_like++;
            } else {
                num_like--;
            }
            [UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num_like];
            [[UserInfoManager instance]saveToUserDefaults];
            [btn.layer  pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefaultWithCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                if (finished&&self.showWithLike&&!isFav) {
                    [self.dataCollectionView reloadData];
                }
            }] forKey:@"layerScaleAnimationDefault"];
            [self changeimage:isFav :btn];
            
            if (cell) {
                [self changeimage:isFav :cell.doFav];
            }
            
            if (isFav) {
                CGFloat targetWidth=cell.backImage.image.size.width*3.75;
                CGFloat targetHeight=cell.backImage.image.size.height*3.75;
                UIImage *newImage=[self resizeImageToSize:CGSizeMake(targetWidth, targetHeight) sizeOfImage:cell.backImage.image];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sendeImage.jpg"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:filePath error:NULL];
                [UIImageJPEGRepresentation(newImage, 0.6) writeToFile:filePath atomically:YES];
                
                NSDictionary *attributes=[[NSDictionary alloc]initWithObjectsAndKeys:mudic[@"cover"],@"imgUrl", nil];
                [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                    if(ourCov){
                        [ChatConversationManager sendImage:filePath text:mudic[@"title"] attributes:attributes conversation:ourCov push:NO  success:^{
                            
                        } failure:^(NSError *error) {
                            
                        }];
                    }
                }];
            }
        }
        else
        {
            NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
            [WTProgressHUD ShowTextHUD:errorContent showInView:KEY_WINDOW];
        }
    }];
}

-(UIImage*)resizeImageToSize:(CGSize)size sizeOfImage:(UIImage*)image
{
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

-(void)setBtn:(int)listid :(UIButton *)btn
{
    BOOL isFav = false;
    for(int i=0;i<self.items.count;i++ ) {
        NSMutableDictionary *mudic  = [self.items[i] mutableCopy];
        if ([mudic[@"cover_id"] intValue]==listid) {
            isFav=[mudic[@"is_like"] boolValue];
            
            break;
        }
    }
    [self changeimage:isFav :btn];
}

- (void)changeimage:(BOOL)isfav :(UIButton*)btn{
    [btn setImage:isfav?[UIImage imageNamed:@"like_yes"]:[UIImage imageNamed:@"like_no"] forState:UIControlStateNormal];
}

/*
 *  展示网络图片
 */
-(void)networkImageShow:(NSUInteger)index{
    [PhotoBroswerVC show:self needFav:YES type:PhotoBroswerVCTypePush index:index photoModelBlock:^NSArray *{
        NSMutableArray *networkImages=[[NSMutableArray alloc]init];
        for (NSDictionary *picdic in self.items) {
            [networkImages addObject:[LWUtil getString:picdic[@"cover"] andDefaultStr:@""]];
        }
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:networkImages.count];
        for (NSUInteger i = 0; i< networkImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = [self.items[i][@"cover_id"] intValue];
            pbModel.title = self.items[i][@"title"];
            pbModel.desc = [NSString stringWithFormat:@"来自 @%@",self.items[i][@"company"]];
            pbModel.image_HD_U = networkImages[i];
			pbModel.postID = self.items[i][@"post_id"] ;
            // pbModel.isFav=[self.items[i][@"is_like"] boolValue];
            pbModel.delegate=self;
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];
}
@end
