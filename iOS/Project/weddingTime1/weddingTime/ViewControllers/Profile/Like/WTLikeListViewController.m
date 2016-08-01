//
//  LikeListViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTLikeListViewController.h"
#import "WTLikeChildViewController.h"
#import "WTInspiretionListViewController.h"
#import "LWUtil.h"
#import "WTSearchViewController.h"
@interface WTLikeListViewController ()
{
    UISegmentedControl *likeSegmentedControl;
    LikeType type;
    WTLikeChildViewController *HotelCommListViewController;
    WTLikeChildViewController *SupplierCommListViewController;
    WTInspiretionListViewController *weddingInspiretionSearchListViewController;
}
@end

@implementation WTLikeListViewController





- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationStyle];
    [self setSegMentedControl];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setNavigationStyle
{
    self.title = @"喜欢";
    [self setRightBtnWithImage:[UIImage imageNamed:@"search"]];
}

- (void)rightNavBtnEvent
{
    WTSearchViewController *search = [[WTSearchViewController alloc] init];
    if (likeSegmentedControl.selectedSegmentIndex == 0) {
        
        search.curSearchType = SearchTypeSupplier;
    } else if(likeSegmentedControl.selectedSegmentIndex == 1) {
        search.curSearchType = SearchTypeHotel;
    } else if(likeSegmentedControl.selectedSegmentIndex == 2) {
        search.curSearchType = SearchTypeInspiretion;
    }
    [self.navigationController pushViewController:search animated:YES];
}

- (void)setSegMentedControl
{
    self.view.backgroundColor = WHITE;
    likeSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"婚礼服务商",@"婚宴酒店",@"婚礼灵感"]];
    likeSegmentedControl.frame = CGRectMake(0, 0, 0, 30);
    likeSegmentedControl.top=75-64;
    likeSegmentedControl.left  = 10.f;
    likeSegmentedControl.width = screenWidth-2*likeSegmentedControl.left;
    likeSegmentedControl.selectedSegmentIndex = 0;
    likeSegmentedControl.tintColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [likeSegmentedControl addTarget:self action:@selector(likeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:likeSegmentedControl];
    type = [self getTypeWithIndex:0];
    [self loadData];
}

- (LikeType)getTypeWithIndex:(int)index {
    if (index==0) {
        return LikeTypeSupplier;
    }else if (index==1) {
        return LikeTypeHotel ;
    }else {
        return LikeTypeInspiretion;
    }
}

- (void)likeSegmentedControlValueChanged:(UISegmentedControl *)segment
{
    type=[self getTypeWithIndex:(int)segment.selectedSegmentIndex];
    [self loadData];
}

- (void)loadData
{
    if (type==LikeTypeHotel) {
        if (!HotelCommListViewController) {
            HotelCommListViewController = [[WTLikeChildViewController alloc] init];
            HotelCommListViewController.type = LikeTypeHotel;
            [self addChildViewController:HotelCommListViewController];
            HotelCommListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
        }
        [self.view insertSubview:HotelCommListViewController.view belowSubview:likeSegmentedControl];
    }else if(type==SearchTypeSupplier){
        if (!SupplierCommListViewController) {
            SupplierCommListViewController = [[WTLikeChildViewController alloc] init];
            SupplierCommListViewController.type = LikeTypeSupplier;
            [self addChildViewController:SupplierCommListViewController];
            SupplierCommListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
            
        }
        [self.view insertSubview:SupplierCommListViewController.view belowSubview:likeSegmentedControl];
    }else if (type==SearchTypeInspiretion) {
        if (!weddingInspiretionSearchListViewController) {
            weddingInspiretionSearchListViewController = [[WTInspiretionListViewController alloc] initWithNibName:@"WTInspiretionListViewController" bundle:nil];
            [self addChildViewController:weddingInspiretionSearchListViewController];
            weddingInspiretionSearchListViewController.showWithLike=YES;
            weddingInspiretionSearchListViewController.view.frame=CGRectMake(0, 115-64, screenWidth, screenHeight-110);
        }
        [self.view insertSubview:weddingInspiretionSearchListViewController.view belowSubview:likeSegmentedControl];
    }
}


- (void)searchAction
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
