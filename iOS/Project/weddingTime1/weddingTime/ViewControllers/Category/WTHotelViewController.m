//
//  HotelViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTHotelViewController.h"
#import "GetService.h"
#import "BanquetTableViewCell.h"
#import "CommentListTableViewCell.h"
#import "ComboListTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+GaussianBlur.h"
#import "CircleImage.h"
#import "WTBanquetViewController.h"
#import "WTMealViewController.h"
#import "BottomView.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "UIImage+YYAdd.h"
@interface WTHotelViewController ()<UITableViewDataSource, UITableViewDelegate, BanquetCollectionDelegate, ComboCellDelegate, SecondBottomDelegate, BottomViewDelegate>

@end


@interface WTHotelViewController ()

@property (nonatomic, strong) BottomView *bottom;

@end
@implementation WTHotelViewController
{
    NSMutableArray *array;
    NSDictionary *_result;
    UIView *tempheader;
    UIImageView *blurImage;
    int ImageHeight;
    int ImageWidth;
    UIImage *tempImage;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [WeddingTimeAppInfoManager instance].curid_hotel_id = self.hotel_id.stringValue;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [WeddingTimeAppInfoManager instance].curid_hotel_id = nil;
}


- (void)dealloc
{
    if (blurImage) {
        [blurImage removeFromSuperview];
        blurImage = nil;
    }
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)secondBottomHasSelect:(BOOL)is_like
{
    self.bottom.is_like = is_like;
    [self.bottom changeLikeButtonStyle];
}

- (void)conversationButtonHasSelectType:(NSInteger)type
{
    [self conversationSelectType:type supplier_id:_hotel_id hotelDic:_result name:_result[@"hotel_name"] phone:self.bottom.tel_num avatar:_result[@"hotel_avatar"]];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewDidLoad {
    ImageHeight = 378 * Height_ato;
    ImageWidth = screenWidth + 20;
    [super viewDidLoad];
    [self.view addSubview:[UIView new]];
    [self initView];
    array = [NSMutableArray array];
    [self loadData];
}

- (void)initBottomView
{
    self.bottom = [[BottomView alloc] init];
    self.bottom.frame = CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato);
    //    self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
    _bottom.type = 1;
    _bottom.supplier_id = self.hotel_id;
    _bottom.is_like = self.is_like;
    _bottom.mainDelegate = self;
    [_bottom changeLikeButtonStyle];
    [self.bottom showThreeButtons];
    [self.view addSubview:_bottom];
}

- (void)banquetCollectHasSelectedWithBan_id:(NSNumber *)banquet_id
{
    WTBanquetViewController *ban = [[WTBanquetViewController alloc] init];
    ban.ballroom_id = banquet_id;
    ban.bottom = [[BottomView alloc] init];
    ban.bottom.frame = self.bottom.frame;
    ban.bottom.type = 1;
    ban.hotel_name = _result[@"hotel_name"];
    ban.hotel_id = self.hotel_id;
    ban.hotel_result = _result;
    ban.bottom.supplier_id  = self.bottom.supplier_id;
    ban.bottom.tel_num = self.bottom.tel_num;
    ban.bottom.supplier_avatar = self.bottom.supplier_avatar;
    ban.bottom.is_like = self.bottom.is_like;
    ban.bottom.delegate = self;
    ban.bottom.name = self.bottom.name;
    [ban.bottom changeLikeButtonStyle];
    [self.navigationController pushViewController:ban animated:YES];
}

- (void)comboCellHasSelectedWithMenu_id:(NSNumber *)menu_id
{
    WTMealViewController *ban = [[WTMealViewController alloc] init];
    ban.meal_id = menu_id;
    ban.bottom = [[BottomView alloc] init];
    ban.bottom.type = 1;
    ban.hotel_result = _result;
    ban.hotel_name = _result[@"hotel_name"];
    ban.hotel_id = self.hotel_id;
    ban.bottom.name = self.bottom.name;
    ban.bottom.frame = self.bottom.frame;
    ban.bottom.supplier_id  = self.bottom.supplier_id;
    ban.bottom.tel_num = self.bottom.tel_num;
    ban.bottom.is_like = self.bottom.is_like;
    [ban.bottom changeLikeButtonStyle];
    [self.navigationController pushViewController:ban animated:YES];
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
    
    
    [self initBottomView];
    [self showLoadingView];
    [self addTapButton];
}


- (void)banquetButtonAction
{
    NSNumber *num = _result[@"hotel_ballroom_num"];
    if (num.intValue > 0) {
        [self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}
- (void)commentButtonAction
{
    NSNumber *comment_num = _result[@"hotel_comment_num"];
    NSNumber *banquet_num = _result[@"hotel_ballroom_num"];
    NSNumber *combo_num = _result[@"hotel_menu_num"];
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
    NSNumber *combo_num = _result[@"hotel_menu_num"];
    NSNumber *banquet_num =_result[@"hotel_ballroom_num"];
    if (banquet_num.intValue > 0 && combo_num.intValue > 0) {
        [self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else if (banquet_num.intValue == 0 && combo_num.intValue > 0) {
        [self.dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else if (combo_num.intValue == 0) {
        return;
    }
    
}


- (void)tapButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData
{
    if (!_hotel_id) {
        _hotel_id = @(0);
    }
    [GetService getHotelDetailWithId:_hotel_id WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            [NetWorkingFailDoErr errWithView:self.view content:@"" tapBlock:^{
                [self loadData];
            }];
            NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
            [WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
            
            return ;
        }
        _result = result;
        tempheader = nil;
        self.dataTableView.tableHeaderView = [self getHeaderView];
        if (result[@"phone"]) {
            self.bottom.tel_num = result[@"phone"];
        }
        if (result[@"hotel_name"]) {
            self.bottom.name = result[@"hotel_name"];
        }
        if (result[@"is_like"]) {
            NSNumber *is_like = result[@"is_like"];
            if (is_like.intValue == 1) {
                self.bottom.is_like = YES;
            } else {
                self.bottom.is_like = NO;
            }
        }
        _result = result;
        if (result[@"hotel_ballroom"]) {
            [array addObject:result[@"hotel_ballroom"]];
        }
        if (result[@"hotel_menu"]) {
            [array addObject:result[@"hotel_menu"]];
        }
        if (result[@"hotel_comment"]) {
            [array addObject:result[@"hotel_comment"]];
        }
        [self.dataTableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
    if (indexPath.row == 0) {
        NSInteger banquetNum = info.count;
        if (banquetNum == 0) {
            return 0;
        }
        return (banquetNum +1) / 2 * 202 *Height_ato + 95 * Height_ato;
    } else if(indexPath.row == 1) {
        NSInteger comboNum = info.count;
        if (comboNum == 0) {
            return 0;
        }
        return comboNum *62 * Height_ato + 70 * Height_ato;
    } else {
        NSInteger commentNum = info.count;
        if (commentNum == 0) {
            return 0;
        }
        return commentNum *106 * Height_ato + 85 *Height_ato;
    }
}

- (UIView *)getFootView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60 * Height_ato)];
    view.backgroundColor = WHITE;
    return view;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (!_result) {
//        return 0;
//    }
//    return 495 * Height_ato;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self getHeaderView];
//}

- (UIView *)getHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 490 * Height_ato)];
    blurImage = [UIImageView new];
    [view addSubview:blurImage];
    
    //    UIImage *blur;
    //    __block UIImage *bl = blur;
    //    WS(WeakSelf);
    
    [blurImage sd_setImageWithURL:[NSURL URLWithString:_result[@"hotel_avatar"]] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        tempImage = image;
        UIImage *blImage = [image imageByBlurRadius:13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        //            //   UIImage *image =[mediaInfo.originalImage renderAtSize:KEY_WINDOW.bounds.size];
        //            UIImage *blimage=image;
        //          //  blimage=[UIImage blurryImage:image withBlurLevel:0.5];
        //            blimage=[UIImage imageWithBlurImage:image intputRadius:8];
        //            dispatch_async(dispatch_get_main_queue(), ^{ // 2
        //                blurImage.image = blimage;
        //                if (!isRemoveBlur) {
        //                    isRemoveBlur=YES;
        //                }
        //
        //               // [jcr removeFromSuperview];
        //                [WeakSelf hideLoadingView];
        //            });
        //        });
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
    [avatarImage.centerImage sd_setImageWithURL:[NSURL URLWithString:_result[@"hotel_avatar"]] placeholderImage:[UIImage imageNamed:@"supplier"]]; //todo
    [view addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(120 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(80 * Height_ato, 80 * Height_ato));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = [LWUtil getString:_result[@"hotel_name"] andDefaultStr:@""];
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
    NSString *cityStr = [LWUtil getString:_result[@"hotel_city"] andDefaultStr:@""];
    NSNumber *catenum = _result[@"hotel_star"];
    NSString *cateStr;
    switch (catenum.intValue) {
        case 1:
            cateStr = @"1星级酒店";
            break;
        case 2:
            cateStr = @"2星级酒店";
            break;
        case 3:
            cateStr = @"3星级酒店";
            break;
        case 4:
            cateStr = @"4星级酒店";
            break;
        case 5:
            cateStr = @"5星级酒店";
            break;
        default:
            break;
    }
    NSString *likeStr;
    if (!_result[@"like_num"]) {
        likeStr = @"";
    } else {
        likeStr = [NSString stringWithFormat:@"%@", _result[@"like_num"]];
    }
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text = [NSString stringWithFormat:@"%@·%@·%@人喜欢",  cityStr, cateStr, likeStr];
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
    workNum.text = [LWUtil getString:_result[@"hotel_ballroom_num"] andDefaultStr:@""];
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
    commentNum.text = [LWUtil getString:_result[@"hotel_comment_num"] andDefaultStr:@""];
    commentNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:commentNum];
    commentNum.font = [UIFont systemFontOfSize:26];
    commentNum.textAlignment = NSTextAlignmentCenter;
    [commentNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(70 * Width_ato, 34 * Height_ato));
    }];
    NSString *price_num;
    UILabel *priceNum = [UILabel new];
    priceNum.userInteractionEnabled = YES;
    [priceNum addGestureRecognizer:comboTap];
    price_num = [LWUtil getString:_result[@"hotel_price_start"] andDefaultStr:@""];
    
    priceNum.font = [UIFont systemFontOfSize:26];
    priceNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:priceNum];
    priceNum.textAlignment = NSTextAlignmentRight;
    priceNum.text = [LWUtil getString:price_num andDefaultStr:@""];
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
    
    if (yOffset < 0) {
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2 - 10, yOffset - 10, factor, ImageHeight+ABS(yOffset));
        blurImage.frame = f;
        
        UIImage *blImage = [tempImage imageByBlurRadius:(140 + yOffset) / 140 * 13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }
}

@end
