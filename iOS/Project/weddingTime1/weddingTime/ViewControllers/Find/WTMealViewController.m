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
{
	UILabel *titleLabel;
}
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) WTHotelMenu *menu;
@end

@implementation WTMealViewController

-(void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITE;
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	_scroll.backgroundColor = WHITE;
	_scroll.scrollEnabled = YES;
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
}

- (void)addBottom
{
	self.bottom = [BottomView bootomViewInView:self.view];
	_bottom.price = _menu.menu_price;
	_bottom.mainDelegate = self;
	_bottom.tel_num = kServerPhone;
    [self.view addSubview:_bottom];
}

- (void)bottomViewLikeSelected:(BOOL)isLike
{
	if(_likeBlock){ self.likeBlock(isLike); }
}

- (void)bottomViewConversationSelected
{
    [self conversationSelectType:WTConversationTypeHotel
					 supplier_id:self.hotel_id
				   sendToAskData:[_hotelDetail modelToJSONObject]
							name:self.hotelDetail.hotel_name
						   phone:self.hotelDetail.phone
						  avatar:self.hotelDetail.hotel_avatar];
}

- (void)initView
{
    titleLabel.text = [NSString stringWithFormat:@"%.f元／%@", _menu.menu_price,_menu.menu_name];
    for (int i = 0; i < _menu.menu_menu.count; i++){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, (94+ 28 * i) * Height_ato, screenWidth - 15, 28 * Height_ato)];
		label.font = [WeddingTimeAppInfoManager  fontWithSize:14];
		label.textColor = rgba(119, 119, 119, 1);
		label.textAlignment = NSTextAlignmentLeft;
        [_scroll addSubview:label];
        NSString *str = [NSString stringWithFormat:@"%@", _menu.menu_menu[i]];
        label.text = str;
    }

    UILabel *bottomLabel = [UILabel new];
    bottomLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    bottomLabel.textColor = rgba(119, 119, 119, 1);
	bottomLabel.numberOfLines = 0;
	[_scroll addSubview:bottomLabel];

    NSString * htmlString = [LWUtil getString:_menu.menu_description andDefaultStr:@"暂无套餐描述"];
    NSAttributedString *detail = [LWUtil returnAttributedStringWithHtml:htmlString];
    bottomLabel.text = detail.string;
    CGRect rect = [detail.string boundingRectWithSize:CGSizeMake(screenWidth - 15 * Width_ato, 10000)
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:@{NSFontAttributeName : [WeddingTimeAppInfoManager fontWithSize:14]}
											  context:nil];
    if (htmlString.length == 0) {
        bottomLabel.text = @"暂无套餐描述";
    }

    if (_menu.menu_menu.count > 0) {
        bottomLabel.frame = CGRectMake(15, (94+30+ 28 * _menu.menu_menu.count) * Height_ato, screenWidth - 15, rect.size.height);

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, (94+30+ 28 * _menu.menu_menu.count) * Height_ato, screenWidth, 50)];
        [self.scroll addSubview:view];
    }
	else
	{
        bottomLabel.frame = CGRectMake(15, 94 * Height_ato, screenWidth - 15, rect.size.height);
    }

    _scroll.contentSize = CGSizeMake(screenWidth, (94+40+ 28 * _menu.menu_menu.count + rect.size.height + 80) * Height_ato);
}

- (void)loadData
{
    [GetService getMealDetailWithMealId:_meal_id Block:^(NSDictionary *dic, NSError *error){
        [self hideLoadingView];
		_menu = [WTHotelMenu modelWithDictionary:dic];
        [self initView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
