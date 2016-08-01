//
//  HotelViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "WTHotelViewController.h"
#import "WTMealViewController.h"
#import "WTBanquetViewController.h"
#import "BanquetTableViewCell.h"
#import "CommentListTableViewCell.h"
#import "ComboListTableViewCell.h"
#import "CircleImage.h"
#import "BottomView.h"
#import "SharePopView.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "GetService.h"
#import "UIImage+YYAdd.h"
#import "WTHotel.h"
#define ImageHeight  (378 * Height_ato)
#define ImageWidth   (screenWidth + 20)
@interface WTHotelViewController ()
<
    UITableViewDataSource, UITableViewDelegate,
	BanquetCollectionDelegate, ComboCellDelegate,
	BottomViewDelegate
>
{
	NSMutableArray *array;
	UIView *tempheader;
	UIImageView *blurImage;
	UIImage *tempImage;
}
@property (nonatomic, strong) WTHotelDetail *hotelDetail;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) SharePopView   *shareView;
@end

@implementation WTHotelViewController

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[UIView new]];
	array = [NSMutableArray array];
    [self initView];
    [self loadData];
}

- (void)initView
{
	self.view.backgroundColor = WHITE;
	[self setDataTableViewAsDefault:CGRectMake(0, 0, screenWidth, screenHeight)];
	self.dataTableView.delegate = self;
	self.dataTableView.dataSource = self;
	self.dataTableView.tableFooterView = [self getFootView];
	tempheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 368 * Height_ato)];
	self.dataTableView.tableHeaderView = tempheader;

	[self showLoadingView];
	[self initBottomView];
	[self addTapButton];
}

- (void)initBottomView
{
    self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
    _bottom.mainDelegate = self;
	[self.bottom showThreeButtons];
    _bottom.hotel_id = self.hotel_id;
	_bottom.is_like = _hotelDetail.is_like;
	_bottom.name = _hotelDetail.hotel_name;
	_bottom.supplier_avatar = _hotelDetail.hotel_avatar;
	_bottom.tel_num = kServerPhone ;
    [self.view addSubview:_bottom];
}

- (void)addTapButton
{
	[super addTapButton];
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(screenWidth - 50, 10, 30, 30);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"homepage_invitecustom_white"] forState:UIControlStateNormal];
	[self.view addSubview:shareButton];
	[shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadData
{
	if (!_hotel_id) { _hotel_id = @"0" ; }
	[GetService getHotelDetailWithId:_hotel_id WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (error)
		{
			[NetWorkingFailDoErr errWithView:self.view content:@"" tapBlock:^{
				[self loadData];
			}];
			NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
			[WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
		}
		else
		{
			_hotelDetail = [WTHotelDetail modelWithDictionary:result];
			[array addObject:_hotelDetail.hotel_ballroom];
			[array addObject:_hotelDetail.hotel_menu];
			[array addObject:_hotelDetail.hotel_comment];
			tempheader = nil;
			[self initBottomView];
			self.dataTableView.tableHeaderView = [self getHeaderView];
			[self.dataTableView reloadData];
		}
	}];
}

#pragma mark - Action
- (void)tapButtonAction
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction
{
	self.shareView = [[SharePopView alloc] init];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kHotelURL,_hotel_id];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_hotelDetail.hotel_name
														andDescription:@""
															 andUrlStr:urlString
														   andImageURL:_hotelDetail.hotel_avatar];
}

- (void)banquetButtonAction
{
	if (_hotelDetail.hotel_ballroom_num > 0) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (void)commentButtonAction
{
	NSNumber *comment_num = @(_hotelDetail.hotel_comment_num);
	NSNumber *banquet_num = @(_hotelDetail.hotel_ballroom_num);
	NSNumber *combo_num = @(_hotelDetail.hotel_menu_num);
	if (comment_num.intValue > 0&&banquet_num.intValue>0&&combo_num.intValue >0) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if ((comment_num.intValue > 0 && banquet_num.intValue >0 && combo_num.intValue ==0)||(comment_num.intValue > 0 && combo_num.intValue > 0 && banquet_num.intValue == 0)) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (comment_num.intValue > 0 && combo_num.intValue ==0 && banquet_num.intValue == 0) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (comment_num.intValue == 0) {
		return;
	}

}
- (void)comboButtonAction
{
	NSNumber *banquet_num = @(_hotelDetail.hotel_ballroom_num);
	NSNumber *combo_num = @(_hotelDetail.hotel_menu_num);
	if (banquet_num.intValue > 0 && combo_num.intValue > 0) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (banquet_num.intValue == 0 && combo_num.intValue > 0) {
		[self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	} else if (combo_num.intValue == 0) {
		return;
	}
}

#pragma mark - BottomViewDelegate
- (void)bottomViewConversationSelected
{
	[self conversationSelectType:WTConversationTypeHotel
					 supplier_id:_hotel_id
				   sendToAskData:[_hotelDetail modelToJSONObject]
							name:_hotelDetail.hotel_name
						   phone:self.bottom.tel_num
						  avatar:_hotelDetail.hotel_avatar];
}

- (void)bottomViewLikeSelected:(BOOL)isLike
{
	_hotelDetail.is_like = isLike;
	if(_likeBlock) { self.likeBlock(isLike); }
}

#pragma mark - CellDelegate
- (void)banquetCollectHasSelectedWithBan_id:(NSString *)banquet_id
{
    WTBanquetViewController *ban = [[WTBanquetViewController alloc] init];
    ban.ballroom_id = banquet_id;
	ban.hotelDetail = _hotelDetail;
	ban.hotel_id = self.hotel_id;
    [self.navigationController pushViewController:ban animated:YES];
}

- (void)comboCellHasSelectedWithMenu_id:(NSString *)menu_id
{
    WTMealViewController *ban = [[WTMealViewController alloc] init];
    ban.meal_id = menu_id;
	ban.hotelDetail = _hotelDetail;
	ban.hotel_id = self.hotel_id;
	ban.is_like = self.bottom.is_like;
	[ban setLikeBlock:^(BOOL isLike){
		_hotelDetail.is_like = isLike;
		_bottom.is_like = isLike;
		if(_likeBlock){self.likeBlock(isLike);}
	}];
    [self.navigationController pushViewController:ban animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = array[indexPath.item];
    if (indexPath.item == 0) {
        BanquetTableViewCell *cell = [tableView banquetCell];
        cell.delegate = self;
        [cell setInfo:info];
        return cell;
    } else if (indexPath.item == 1) {
        ComboListTableViewCell *cell = [tableView comboCell];
        cell.delegate = self;
        [cell setInfo:info];
        return cell;
    } else {
        CommentListTableViewCell *cell = [tableView commentListCell];
        [cell setInfo:info];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *info = array[indexPath.item];
    if (indexPath.row == 0)
	{
		return info.count == 0 ? 0 : (info.count +1) / 2 * 202 *Height_ato + 95 * Height_ato;
    }
	else if(indexPath.row == 1)
    {
		return info.count == 0 ? 0 : info.count *62 * Height_ato + 70 * Height_ato;
    }
	else
	{
		return info.count == 0 ? 0 : info.count *106 * Height_ato + 85 *Height_ato;
    }
}

- (UIView *)getFootView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60 * Height_ato)];
    view.backgroundColor = WHITE;
    return view;
}

- (UIView *)getHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 490 * Height_ato)];
    blurImage = [UIImageView new];
    [view addSubview:blurImage];

    [blurImage sd_setImageWithURL:[NSURL URLWithString:_hotelDetail.hotel_avatar] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        tempImage = image;
        UIImage *blImage = [image imageByBlurRadius:13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }];
	
    [blurImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    blurImage.contentMode = UIViewContentModeScaleToFill;
    blurImage.clipsToBounds = YES;
    
    [blurImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-10);
        make.left.mas_equalTo(-10 * Width_ato);
        make.right.mas_equalTo(+10 * Width_ato);
        make.height.mas_equalTo(378 * Height_ato);
    }];
    CircleImage *avatarImage = [CircleImage new];
    [avatarImage.centerImage sd_setImageWithURL:[NSURL URLWithString:_hotelDetail.hotel_avatar] placeholderImage:[UIImage imageNamed:@"supplier"]]; //todo
    [view addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(120 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(80 * Height_ato, 80 * Height_ato));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = _hotelDetail.hotel_name;
    titleLabel.textColor = WHITE;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(240 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(28 * Height_ato);
    }];
    UILabel *detailLabel = [UILabel new];
    detailLabel.textColor = WHITE;
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text = [NSString stringWithFormat:@"%@·%@星级酒店·%.f人喜欢",_hotelDetail.hotel_city, _hotelDetail.hotel_star, _hotelDetail.like_num];
    [view addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(284 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 360 * Height_ato, screenWidth, 130 * Height_ato)];
    [view addSubview:whiteView];
    whiteView.backgroundColor = WHITE;
    UITapGestureRecognizer *worktap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(banquetButtonAction)];
    UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentButtonAction)];
    UITapGestureRecognizer *comboTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comboButtonAction)];
    UILabel *worksLabel = [UILabel new];
    worksLabel.userInteractionEnabled = YES;
    [worksLabel addGestureRecognizer:worktap];
    worksLabel.text = @"宴会厅";
    worksLabel.textColor = rgba(102, 102, 102, 1);
    worksLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    [view addSubview:worksLabel];
    worksLabel.textAlignment = NSTextAlignmentCenter;
    [worksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.left.mas_equalTo(65 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(62 * Width_ato, 16));
    }];
    
    UILabel *commentLabel = [UILabel new];
    commentLabel.userInteractionEnabled = YES;
    [commentLabel addGestureRecognizer:commentTap];
    commentLabel.text = @"评论";
    commentLabel.textColor = rgba(102, 102, 102, 1);
    [view addSubview:commentLabel];
    
    commentLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(52 * Width_ato, 16));
    }];
    
    UILabel *priceLabel = [UILabel new];
    priceLabel.userInteractionEnabled = YES;
    [priceLabel addGestureRecognizer:comboTap];
    priceLabel.text = @"报价";
    priceLabel.textColor = rgba(102, 102, 102, 1);
    [view addSubview:priceLabel];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.right.mas_equalTo(-72 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16));
    }];
    
    UILabel *workNum = [UILabel new];
    workNum.userInteractionEnabled = YES;
    [workNum addGestureRecognizer:worktap];
    workNum.font = [UIFont systemFontOfSize:26];
	workNum.text = [NSString stringWithFormat:@"%.f",_hotelDetail.hotel_ballroom_num];
    workNum.textAlignment = NSTextAlignmentCenter;
    workNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:workNum];
    [workNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.left.mas_equalTo(67 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(52 * Width_ato, 34 * Width_ato));
    }];
    UILabel *commentNum = [UILabel new];
    commentNum.userInteractionEnabled = YES;
    [commentNum addGestureRecognizer:commentTap];
	commentNum.text = [NSString stringWithFormat:@"%.f",_hotelDetail.hotel_comment_num];
    commentNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:commentNum];
    commentNum.font = [UIFont systemFontOfSize:26];
    commentNum.textAlignment = NSTextAlignmentCenter;
    [commentNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(70 * Width_ato, 34 * Height_ato));
    }];

    UILabel *priceNum = [UILabel new];
	priceNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    priceNum.userInteractionEnabled = YES;
	priceNum.font = [UIFont systemFontOfSize:26];
	priceNum.textAlignment = NSTextAlignmentRight;
    [priceNum addGestureRecognizer:comboTap];
    [view addSubview:priceNum];
	priceNum.text = _hotelDetail.hotel_price_start;
    [priceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.right.mas_equalTo(-67 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(100 * Width_ato, 34 * Height_ato));
    }];
    UILabel *qiLabel = [UILabel new];
    qiLabel.text = @"桌／起";
    qiLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    qiLabel.textColor = rgba(153, 153, 153, 1);
    [view addSubview:qiLabel];
    [qiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(432 * Height_ato);
        make.right.mas_equalTo(-10 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(52 * Width_ato, 14 * Width_ato));
    }];
    
    UIView *shadowView = [UIView new];
    shadowView.backgroundColor = rgba(230, 230, 230, 230);
    
    [view addSubview:shadowView];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5 * screenHeight / 736.0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(5 * screenHeight / 736.0);
    }];
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.dataTableView.contentOffset.y;
    
    if (yOffset < 0)
	{
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2 - 10, yOffset - 10, factor, ImageHeight+ABS(yOffset));
        blurImage.frame = f;
        
        UIImage *blImage = [tempImage imageByBlurRadius:(140 + yOffset) / 140 * 13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
