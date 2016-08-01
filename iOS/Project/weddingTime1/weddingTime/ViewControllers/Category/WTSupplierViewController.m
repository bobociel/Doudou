//
//  SupplierViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSupplierViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTBookingnViewController.h"
#import "NetworkManager.h"
#import "SupplierDetailCell.h"
#import "UIImage+GaussianBlur.h"
#import "GetService.h"
#import "CircleImage.h"
#import "MJRefresh.h"
#import <UIImageView+WebCache.h>
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "BottomView.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "UIImage+Utils.h"
#import "UIImage+YYAdd.h"
@interface WTSupplierViewController ()<UITableViewDataSource, UITableViewDelegate,  BottomViewDelegate>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) UIImage *blimage;

@end

@implementation WTSupplierViewController
{
    int maxPageCount;
    int page;
    
    NSMutableArray *curArray;
    UIImageView *tempheader;
    UIImageView *imageView;
    UIImageView *blurImage;
    CGFloat ImageHeight ;
    CGFloat ImageWidth ;
    
    UIImage *tempImage;
}

- (void)dealloc
{
    if (_blimage) {
        _blimage = nil;
        blurImage = nil;
        [[SDImageCache sharedImageCache] clearMemory];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if([self.supplier_id isKindOfClass:[NSNumber class]]){
		[WeddingTimeAppInfoManager instance].curid_supplier = self.supplier_id.stringValue;
	}
	else if ([self.supplier_id isKindOfClass:[NSString class]]){
		[WeddingTimeAppInfoManager instance].curid_supplier = (NSString *)self.supplier_id;
	}
}

-(void)setNavWithHidden
{
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

- (void)viewDidLoad {
    self.navigationController.navigationBar.translucent = YES;
    ImageHeight = 368 * Height_ato;
    ImageWidth = screenWidth ;
    [super viewDidLoad];
    page = 0;
    [self.view addSubview:[UIView new]];
    [self initView];
    [self loadData];
}

- (void)secondBottomHasSelect:(NSNotification *)sender
{
    NSDictionary *userinfo = sender.userInfo;
    NSNumber *supplier_id = userinfo[@"supplier_id"];
    if (supplier_id.intValue != self.supplier_id.intValue) {
        return;
    }
    NSNumber *islike = userinfo[@"is_like"];
    BOOL is_like;
    if (islike.intValue == 0) {
        is_like = NO;
    } else {
        is_like = YES;
    }
    self.bottom.is_like = is_like;
    [self.bottom changeLikeButtonStyle];
}

- (void)initView
{
    self.view.backgroundColor = WHITE;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UIView *jrc1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 368 * Height_ato)];
    
    _tableView.tableHeaderView = jrc1;
    
    
    [self initBottomView];
    [self initRefresh];
    [self showLoadingView];
    [self addTapButton];
}

- (void)initBottomView
{
    self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
    _bottom.supplier_id = self.supplier_id;
    _bottom.is_like = self.is_like;
    _bottom.mainDelegate = self;
    [_bottom changeLikeButtonStyle];
    [self.bottom showFourButtons];
    [self.view addSubview:_bottom];
}

- (void)conversationButtonHasSelectType:(NSInteger)type
{
    [self conversationSelectType:type supplier_id:self.supplier_id hotelDic:nil name:_result[@"supplier_name"] phone:self.bottom.tel_num avatar:_result[@"supplier_avatar"]];
}

- (void)orderButtonHasSelect:(NSNumber *)supplier_id type:(isFromType)type
{
    WTBookingnViewController *book = [[WTBookingnViewController alloc] init];
    book.isfrom_type = isFrom_supplier;
    book.supplier_id = self.supplier_id;
    book.image_url = _result[@"supplier_avatar"];
    book.name = _result[@"supplier_name"];
    book.location = _result[@"city"];
    book.cate = _result[@"service_type"];
    //    [self presentViewController:book animated:YES completion:nil];
    [self.navigationController pushViewController:book animated:YES];
    
}

- (void)initRefresh
{
    WS(ws);
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [ws loadLocalData];
    }];
    //
    //    scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
    //        [self loadData];
    //    }];
}
-(void)removeRefresh
{
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer =nil;
}

- (void)loadData
{
    page = 0;
    curArray = [NSMutableArray array];
    if (!_supplier_id) {
        _supplier_id = @(0);
    }
    [GetService getSupplierDetailWithId:_supplier_id WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            
            NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
            [NetWorkingFailDoErr errWithView:self.tableView content:errorContent tapBlock:^{
                [self loadData];
            }];
        } else{
            
            self.bottom.tel_num = result[@"phone"];
            self.bottom.supplier_avatar = result[@"supplier_avatar"];
            self.bottom.name =  result[@"supplier_name"];
            NSNumber *is_like = result[@"is_like"];
            if (is_like.intValue == 1) {
                self.bottom.is_like = YES;
            } else {
                self.bottom.is_like = NO;
            }
            [self.bottom changeLikeButtonStyle];
            self.array = result[@"supplier_post"];
            self.result = [NSDictionary dictionaryWithDictionary:result];
            tempheader = nil;
            _tableView.tableHeaderView = [self getHeaderView];
            [self loadLocalData];
        }
    }];
    
    
}

- (void)loadLocalData
{
    page++;
    if (page * 5 == _array.count) {
        if (page == 1) {
            [self.tableView.header endRefreshing];
        }
        curArray = [NSMutableArray array];
        [curArray addObjectsFromArray:_array];
        [self.tableView.footer endRefreshing];
        [self removeRefresh];
        [self.tableView reloadData];
        return;
    } else if(page * 5 > _array.count) {
        if (page == 1) {
            [self.tableView.header endRefreshing];
        }
        curArray = [NSMutableArray array];
        [curArray addObjectsFromArray:_array];
        [self.tableView.footer endRefreshing];
        [self removeRefresh];
        [self.tableView reloadData];
        return;
    } else{
        for (int i = (page - 1) * 5; i < page * 5; i++) {
            NSDictionary *dic = _array[i];
            [curArray addObject:dic];
        }
    }
    if (page == 1) {
        [self.tableView.header endRefreshing];
    }
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return curArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SupplierDetailCell *cell = [tableView supplerDetailCell];
    NSDictionary *info = curArray[indexPath.row];
    [cell setInfo:info];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    NSNumber *width = info[@"width"];
    NSNumber *height = info[@"heigth"];
    NSString *nameStr = [LWUtil getString:info[@"post_name"] andDefaultStr:@""];;
    NSDictionary *dic = @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18]};
    CGRect rect = [nameStr boundingRectWithSize:CGSizeMake(screenWidth - 50, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return  (screenWidth / width.floatValue * height.floatValue)+37*Height_ato + rect.size.height + 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = curArray[indexPath.row];
    NSNumber *work_id = info[@"post_id"];
    WTWorksDetailViewController *ban = [[WTWorksDetailViewController alloc] init];
    ban.works_id = work_id;
    ban.supplier_id = self.supplier_id;
    ban.bottom = [[BottomView alloc] init];
    ban.bottom.frame = self.bottom.frame;
    ban.bottom.supplier_id  = self.bottom.supplier_id;
    ban.bottom.tel_num = self.bottom.tel_num;
    ban.bottom.is_like = self.bottom.is_like;
    //    ban.bottom.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(secondBottomHasSelect:) name:SecondBottomPush object:nil];
    ban.bottom.tel_num = self.bottom.tel_num;
    ban.bottom.supplier_avatar = self.bottom.supplier_avatar;
    ban.bottom.name = self.bottom.name;
    [ban.bottom changeLikeButtonStyle];
    ban.city = _result[@"city"];
    ban.cate = _result[@"service_type"];
    ban.name = _result[@"supplier_name"];
    [self.navigationController pushViewController:ban animated:YES];
}

- (UIView *)getHeaderView
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 490 * Height_ato)];
    
    blurImage = [UIImageView new];
    //    UIImage *blur;
    //    __block UIImage *bl = blur;
    [view addSubview:blurImage];
    
    NSString *backgroundStr = _result[@"supplier_banner"];
    if (![backgroundStr isNotEmptyCtg]) {
        backgroundStr = _result[@"supplier_avatar"];
    }
    __weak UIImageView *tempImageView = blurImage;
    [tempImageView sd_setImageWithURL:[NSURL URLWithString:backgroundStr] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        tempImageView.image = image;
        CGSize size = image.size;

        if (image.size.height > 1104) {
            image = [image renderAtSize:CGSizeMake(size.width / size.height * 1104, 1104)];
            blurImage.image = image;
        }
        tempImage = image;
        UIImage *blImage = [image imageByBlurRadius:13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }];
    
    [blurImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(368 * Height_ato);
    }];
    blurImage.contentMode = UIViewContentModeScaleAspectFill;
    CircleImage *avatarImage = [CircleImage new];
    [avatarImage.centerImage sd_setImageWithURL:[NSURL URLWithString:_result[@"supplier_avatar"]] placeholderImage:[UIImage imageNamed:@"supplier"]];
    [view addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(120 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(80 * Height_ato, 80 * Height_ato));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = [LWUtil getString:_result[@"supplier_name"] andDefaultStr:@""];
    titleLabel.textColor = WHITE;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
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
    NSString *cityStr = [LWUtil getString:_result[@"city"] andDefaultStr:@""];
    NSString *cateStr = [LWUtil getString:_result[@"service_type"] andDefaultStr:@""];
    NSString *likeStr;
    if (!_result[@"like_num"]) {
        likeStr = @"";
    } else {
        likeStr = [NSString stringWithFormat:@"%@人喜欢", _result[@"like_num"]];
    }
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text = [NSString stringWithFormat:@"%@·%@·%@",  cityStr, cateStr, likeStr];
    [view addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(284 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 368 * Height_ato, screenWidth, 122 * Height_ato)];
    whiteView.backgroundColor = WHITE;
    [view addSubview:whiteView];
    UILabel *worksLabel = [UILabel new];
    worksLabel.text = @"作品";
    worksLabel.textColor = rgba(102, 102, 102, 1);
    worksLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [view addSubview:worksLabel];
    [worksLabel sizeToFit];
    worksLabel.textAlignment = NSTextAlignmentCenter;
    [worksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.left.mas_equalTo(70 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16));
    }];
    
    UILabel *commentLabel = [UILabel new];
    commentLabel.text = @"评论";
    commentLabel.textColor = rgba(102, 102, 102, 1);
    [view addSubview:commentLabel];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    commentLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16 ));
    }];
    
    UILabel *priceLabel = [UILabel new];
    priceLabel.text = @"报价";
    priceLabel.textColor = rgba(102, 102, 102, 1);
    [view addSubview:priceLabel];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.right.mas_equalTo(-72 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16 ));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(workButtonAction)];
    UILabel *workNum = [UILabel new];
    workNum.userInteractionEnabled = YES;
    [workNum addGestureRecognizer:tap];
    workNum.font = [UIFont systemFontOfSize:26];
    NSString *workNum_str;
    if (_result[@"supplier_post_num"]) {
        workNum_str = [NSString stringWithFormat:@"%@", _result[@"supplier_post_num"]];
    } else {
        workNum_str = @"";
    }
    if (![workNum_str isNotEmptyCtg]) {
        workNum_str = @"0";
    }
    workNum.text = workNum_str;
    workNum.textAlignment = NSTextAlignmentCenter;
    workNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:workNum];
    [workNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.left.mas_equalTo(50 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(84 * Width_ato, 34 * Width_ato));
    }];
    UILabel *commentNum = [UILabel new];
    NSString *commentNum_str;
    if (!_result[@"comment_num"]) {
        commentNum_str = [NSString stringWithFormat:@"%@", _result[@"comment_num"]];
    } else {
        commentNum_str = @"";
    }
    if (![commentNum_str isNotEmptyCtg]) {
        commentNum_str = @"0";
    }
    commentNum.text = commentNum_str;
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
    
    price_num = [NSString stringWithFormat:@"%@", _result[@"start_price"]];
    if (!_result[@"start_price"]) {
        price_num = @"";
    }
    priceNum.textAlignment = NSTextAlignmentRight;
    int width = 100;
    int rightWidth = 53;
    if (price_num.intValue < 10000) {
        rightWidth = 64;
    }
    if (price_num.intValue < 1000) {
        priceNum.textAlignment = NSTextAlignmentCenter;
        width = 44;
        rightWidth = 67;
    }
    if (![price_num isNotEmptyCtg]) {
        price_num = @"0";
        priceNum.textAlignment = NSTextAlignmentCenter;
        width = 44;
        rightWidth = 67;
    }
    priceNum.font = [UIFont systemFontOfSize:26];
    priceNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [view addSubview:priceNum];
    priceNum.text = [LWUtil getString:price_num andDefaultStr:@""];
    [priceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.right.mas_equalTo(-rightWidth * Width_ato);
        make.size.mas_equalTo(CGSizeMake(width * Width_ato + 10, 34 * Height_ato));
    }];
    UILabel *qiLabel = [UILabel new];
    qiLabel.text = @"起";
    qiLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    qiLabel.textColor = rgba(153, 153, 153, 1);
    [view addSubview:qiLabel];
    [qiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(432 * Height_ato);
        make.right.mas_equalTo(-(rightWidth - 18) * Width_ato);
        make.size.mas_equalTo(CGSizeMake(14,14));
    }];
    
    UIView *shadowView = [UIView new];
    shadowView.backgroundColor = rgba(230, 230, 230, 1);
    [view addSubview:shadowView];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(490 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(5 * Height_ato);
    }];
    return view;
    
}

- (void)workButtonAction
{
    if (self.array.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.tableView.contentOffset.y;
    
    if (yOffset < 0) {
        
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
        blurImage.frame = f;
        
        UIImage *blImage = [tempImage imageByBlurRadius:(140 + yOffset) / 140 * 13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
