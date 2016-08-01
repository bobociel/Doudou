//
//  MealViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/4.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTMealViewController.h"
#import "GetService.h"
@interface WTMealViewController ()<BottomViewDelegate>

@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation WTMealViewController
{
    NSDictionary *result;
    NSArray *array;
    UILabel *titleLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
}

-(void)setNavWithHidden
{
      [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITE;
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.view addSubview:_scroll];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36 * Height_ato, screenWidth, 19)];
    titleLabel.textColor = rgba(51, 51, 51, 1);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:titleLabel];
    [self showLoadingView];

    [self loadData];
    [self addBottom];
    [self addTapButton];
    // Do any additional setup after loading the view.
}

- (void)addBottom
{
    [_bottom showTwoButtons];
    _bottom.mainDelegate = self;
    [self.view addSubview:_bottom];
}

- (void)conversationButtonHasSelectType:(NSInteger)type
{
    [self conversationSelectType:type supplier_id:self.hotel_id hotelDic:self.hotel_result name:self.hotel_name phone:self.bottom.tel_num avatar:self.bottom.supplier_avatar];
}

- (void)initView
{
    NSString *priceStr = [LWUtil getString:result[@"menu_price"] andDefaultStr:@""];
    NSString *desStr = [LWUtil getString:result[@"menu_name"] andDefaultStr:@""];
    titleLabel.text = [NSString stringWithFormat:@"%@元／%@", priceStr,desStr];
    _scroll.backgroundColor = WHITE;
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [UILabel new];
        label.font = [WeddingTimeAppInfoManager  fontWithSize:14];
        [_scroll addSubview:label];
        label.textColor = rgba(119, 119, 119, 1);
        NSString *str = [NSString stringWithFormat:@"%@", array[i]];
        label.text = str;
        
        label.textAlignment = NSTextAlignmentLeft;
        label.frame = CGRectMake(15, (94+ 28 * i) * Height_ato, screenWidth - 15, 28 * Height_ato);
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo((94+ 28 * i) * Height_ato);
//            make.left.mas_equalTo(15);
//            make.width.mas_equalTo(screenWidth - 15);
//            make.height.mas_equalTo(28 * Height_ato);
//        }];
    }
   
    NSDictionary *dic = @{NSFontAttributeName : [WeddingTimeAppInfoManager fontWithSize:14]};
    
    UILabel *bottomLabel = [UILabel new];
    [_scroll addSubview:bottomLabel];
    bottomLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    bottomLabel.textColor = rgba(119, 119, 119, 1);
    NSString * htmlString = [LWUtil getString:result[@"menu_description"] andDefaultStr:@"暂无套餐描述"];
    NSAttributedString *detail = [LWUtil returnAttributedStringWithHtml:htmlString];
    bottomLabel.text = detail.string;
    CGRect rect = [detail.string boundingRectWithSize:CGSizeMake(screenWidth - 15 * Width_ato, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
//    bottomLabel.attributedText = [LWUtil returnAttributedStringWithHtml:htmlString];
    if (htmlString.length == 0) {
        bottomLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
        bottomLabel.text = @"暂无套餐描述";
    }
    bottomLabel.numberOfLines = 0;
    if (array.count > 0) {
        bottomLabel.frame = CGRectMake(15, (94+30+ 28 * array.count) * Height_ato, screenWidth - 15, rect.size.height);
//        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo((94+30+ 28 * array.count) * Height_ato);
//            make.left.mas_equalTo(15 * Width_ato);
//            make.right.mas_equalTo(0);
//            make.height.mas_equalTo(rect.size.height);
//        }];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, (94+30+ 28 * array.count) * Height_ato, screenWidth, 50)];
        [self.scroll addSubview:view];
    } else {
        bottomLabel.frame = CGRectMake(15, 94 * Height_ato, screenWidth - 15, rect.size.height);
//        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo((94) * Height_ato);
//            make.left.mas_equalTo(15 * Width_ato);
//            make.right.mas_equalTo(0);
//            make.height.mas_equalTo(rect.size.height);
//        }];
    }
    
    _scroll.scrollEnabled = YES;
    _scroll.contentSize = CGSizeMake(screenWidth, (94+40+ 28 * array.count + rect.size.height + 80) * Height_ato);
//    _scroll.contentSize = CGSizeMake(screenWidth, 900);
}

- (void)loadData
{
    [GetService getMealDetailWithMealId:_meal_id Block:^(NSDictionary *dic, NSError *error){
        [self hideLoadingView];
        result = dic;
        array = dic[@"menu_menu"];
        [self initView];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
