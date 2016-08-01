//
//  WorksDetailViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTWorksDetailViewController.h"
#import "WTSupplierViewController.h"
#import "GetService.h"
#import "WorksDetailCell.h"
#import "WTProgressHUD.h"
#import "webViewCellTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "WTBookingnViewController.h"
@interface WTWorksDetailViewController ()<UITableViewDataSource, UITableViewDelegate, BottomViewDelegate>

@end

@implementation WTWorksDetailViewController
{
    NSMutableArray *array;
    NSDictionary *result;
    UIImageView *tempImage;
    int ImageHeight;
    int ImageWidth;
    UIImageView *topImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [WeddingTimeAppInfoManager instance].curid_work = [LWUtil getString:self.works_id andDefaultStr:@""];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [WeddingTimeAppInfoManager instance].curid_work = nil;
}

- (void)goSupplier
{
	NSArray *VCS = self.navigationController.viewControllers;
	if(VCS.count > 1 && [VCS[VCS.count-2] isKindOfClass:[WTSupplierViewController class]]){
		[self.navigationController popViewControllerAnimated:YES];
	}else{
		WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
		supplierVC.supplier_id = result[@"supplier_user_id"];
		[self.navigationController pushViewController:supplierVC animated:YES];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ImageHeight = 360 * Height_ato;
    ImageWidth = screenWidth;
    self.navigationController.navigationBar.translucent = NO;
    [self initView];
    [self loadData];
}

- (void)setBaseInfo
{
    self.bottom.type = 0;
    self.bottom.name = [LWUtil getString:result[@"supplier_company"] andDefaultStr:@""] ;
    self.bottom.supplier_avatar = [LWUtil getString:result[@"supplier_avatar"] andDefaultStr:@""];
    
    self.is_like = [result[@"is_like"] boolValue];
    self.bottom.is_like = self.is_like;
    [self.bottom changeLikeButtonStyle];
    self.name = result[@"supplier_company"];
    self.city = result[@"city"];
    self.cate = result[@"cate"];
    self.bottom.tel_num = result[@"tel"];
    self.supplier_id = result[@"supplier_user_id"];
    self.bottom.supplier_id = self.supplier_id;
    
}
- (void)loadData
{
    [GetService getWorkDetailWithPostId:_works_id Block:^(NSDictionary *dic, NSError *error) {
        [self hideLoadingView];
        if (error) {
            [WTProgressHUD ShowTextHUD:@"服务器出现问题，请稍候再试" showInView:self.view afterDelay:1];
        }
        result = dic;
        [self setBaseInfo];
        array = [NSMutableArray arrayWithArray:dic[@"post_image"]];
        self.dataTableView.tableHeaderView = [self getHeaderView];
        self.dataTableView.tableFooterView = [self getFooterView];
        NSString *str = dic[@"video"];
        if ([str isKindOfClass:[NSString class]]) {
            if ([str isNotEmptyCtg]) {
                
                [array insertObject:dic[@"video"] atIndex:0];
            }
        }
        
        [self.dataTableView reloadData];
    }];
}

- (void)initView
{
    self.view.backgroundColor = WHITE;
    self.dataTableView  =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    [self.view addSubview:self.dataTableView];
    
    tempImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 571 * Height_ato)];
    tempImage.image = [UIImage imageNamed:@""];
    self.dataTableView.tableHeaderView = tempImage;
    [self addBottom];
    
    [self showLoadingView];
//
    [self addTapButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.dataTableView.contentOffset.y;
    
    if (yOffset < 0) {
        
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
        topImage.frame = f;
    }
}

- (void)tapButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBottom
{
    self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
    [_bottom showFourButtons];
    _bottom.mainDelegate = self;
    [self.view addSubview:_bottom];
}

- (void)orderButtonHasSelect:(NSNumber *)supplier_id type:(isFromType)type
{
    WTBookingnViewController *book = [[WTBookingnViewController alloc] init];
    book.work_id = self.works_id;
    book.isfrom_type = isFrom_work;
    book.image_url = result[@"supplier_avatar"];
    book.name = self.name;
    book.location = self.city;
    book.cate = self.cate;
    book.supplier_id = result[@"supplier_user_id"];
    [self.navigationController pushViewController:book animated:YES];
//    [self presentViewController:book animated:YES completion:nil];
}


- (void)conversationButtonHasSelectType:(NSInteger)type
{
    [self conversationSelectType:type supplier_id:self.supplier_id hotelDic:nil name:self.name phone:self.bottom.tel_num avatar:self.bottom.supplier_avatar];
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
    id info = array[indexPath.row];
    if ([info isKindOfClass:[NSString class]]) {
        webViewCellTableViewCell *cell = [tableView webViewCell];
        [cell setInfo:info];
        return cell;
    }
    WorksDetailCell *cell = [tableView WorksDetailCell];
    [cell setInfo:info];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = array[indexPath.row];
    if([info isKindOfClass:[NSString class]]) {
        return 350;
    }
    NSString *height = info[@"height"];
    NSString *width = info[@"width"];
    return screenWidth / width.intValue * height.intValue + 10;
}

- (UIView *)getHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 571 * Height_ato)];
    topImage = [UIImageView new];
    [view addSubview:topImage];
    
    [topImage sd_setImageWithURL:[NSURL URLWithString:result[@"post_avatar"]] placeholderImage:[UIImage imageNamed:@"placelolder_detail"]];
    topImage.clipsToBounds = YES;      [topImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    topImage.contentMode =  UIViewContentModeScaleAspectFill;
//    topImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    topImage.frame = CGRectMake(0, 0, screenWidth, 360 * Height_ato);
    
    UIImageView *avatarImage = [UIImageView new];
	avatarImage.userInteractionEnabled = YES;
    [view addSubview:avatarImage];
    avatarImage.layer.borderColor = WHITE.CGColor;
    avatarImage.layer.borderWidth = 2;
    avatarImage.image = [UIImage imageNamed:result[@"supplier_avatar"]];
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:result[@"supplier_avatar"] ]placeholderImage:[UIImage imageNamed:@"supplier"]];
    avatarImage.layer.cornerRadius = 65 * Width_ato / 2.0;
    avatarImage.layer.masksToBounds = YES;
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(327 * Height_ato);
        make.centerX.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(65 * Width_ato, 65 * Width_ato));
    }];

	UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSupplier)];
	[avatarImage addGestureRecognizer:headerTap];

    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
   
    nameLabel.numberOfLines = 0;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    NSString *str = [LWUtil getString:result[@"post_title"] andDefaultStr:@""];
    nameLabel.text = str;
    nameLabel.textColor = rgba(60, 60, 60, 1);
    CGRect rect = [str boundingRectWithSize:CGSizeMake(screenWidth - 200 * Width_ato, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:16]} context:nil];
    nameLabel.frame = CGRectMake(100 * Width_ato, 412 * Height_ato, screenWidth - 200 * Width_ato, rect.size.height);

    UILabel *priceLabel = [UILabel new];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    NSString *price_str = [LWUtil getString:result[@"price"] andDefaultStr:@""];
    if (price_str.length > 0) {
        priceLabel.text = [NSString stringWithFormat:@"￥%@", price_str];
    } else {
        priceLabel.text = @"报价详询商家";
    }
    priceLabel.frame = CGRectMake(0, 422 * Height_ato + rect.size.height, screenWidth, 15);
    priceLabel.textColor = rgba(170, 170, 170, 1);
    [view addSubview:priceLabel];
    
    UILabel *detailLabel = [UILabel new];
    detailLabel.textColor = rgba(153, 153, 153, 1);
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    NSString * htmlString = [LWUtil getString:result[@"post_description"] andDefaultStr:@""];

    detailLabel.numberOfLines = 0;
    NSAttributedString *detail = [LWUtil returnAttributedStringWithHtml:htmlString];

    NSString *tempStr = detail.string;
    int height;
    if ([tempStr isNotEmptyCtg]) {
        detailLabel.text = tempStr;
        CGRect rect1 = [tempStr boundingRectWithSize:CGSizeMake(382 * Width_ato, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:14]} context:nil];
        [view addSubview:detailLabel];
        detailLabel.frame = CGRectMake(16 * Width_ato, 422 * Height_ato + 15 + rect.size.height + 45 * Height_ato, screenWidth - 32 * Width_ato, rect1.size.height);
        height =( 422 + 50 +45) * Height_ato + 15 + rect.size.height +rect1.size.height;
    }
    
    else {
     height = 15 + (422 + 50)* Height_ato +rect.size.height;
    }
    view.frame = CGRectMake(0, 0, screenWidth, height);
    return view;
}


- (UIView *)getFooterView
{
    NSArray *destArray = result[@"sku"];
    UIView *view;
    if (destArray.count > 0) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, (76 + 28 * destArray.count + 28) * Height_ato)];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    for (int i = 0; i < destArray.count; i++) {
        NSDictionary *dic = destArray[i];
        UILabel *label = [UILabel new];
        label.font = [WeddingTimeAppInfoManager fontWithSize:14];
        [view addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = rgba(102, 102, 102, 1);
        NSString *str = [NSString stringWithFormat:@"%@: %@", dic[@"name"], dic[@"value"]];
        label.text = str;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo((38 + 28 * i) * Height_ato);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(28 * Height_ato);
        }];
    }
    return view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
