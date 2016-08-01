//
//  WeddingPlanViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanContainerViewController.h"
#import "WeddingPlanListViewController.h"
#import "WeddingPlanDetailViewController.h"
#import "SetDefaultWeddingTimeViewController.h"
#define kTopViewHeight 44.0
@interface WeddingPlanContainerViewController ()

@end

@implementation WeddingPlanContainerViewController {
    WeddingPlanListViewController *weddingPlanListViewControllerFinish;
    WeddingPlanListViewController *weddingPlanListViewControllerUnFinish;
    WeddingPlanListViewController *weddingPlanListViewControllerAll;
    
    UIButton *finishBtn;
    UIButton *unFinishBtn;
    
    UISegmentedControl *inviteSegmentedControl;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
}

- (void)loadData {
    [self changeListWithStatus:WTMatterStatusAll];
}

- (void)changeListWithStatus:(int)status {
    if (status == 0) {
        if (!weddingPlanListViewControllerAll) {
            weddingPlanListViewControllerAll = [[WeddingPlanListViewController alloc] init];
            weddingPlanListViewControllerAll.status = WTMatterStatusAll;
            [self addChildViewController:weddingPlanListViewControllerAll];
            weddingPlanListViewControllerAll.view.frame = CGRectMake(0, kTopViewHeight, screenWidth, screenHeight-kTopViewHeight);
        }
        
        [self.view insertSubview:weddingPlanListViewControllerAll.view belowSubview:inviteSegmentedControl];
    } else if (status == 1) {
        if (!weddingPlanListViewControllerFinish) {
            weddingPlanListViewControllerFinish = [[WeddingPlanListViewController alloc] init];
            weddingPlanListViewControllerFinish.status = WTMatterStatusFinished;
            [self addChildViewController:weddingPlanListViewControllerFinish];
			weddingPlanListViewControllerFinish.view.frame = CGRectMake(0, kTopViewHeight, screenWidth, screenHeight-kTopViewHeight);
        }
        [self.view insertSubview:weddingPlanListViewControllerFinish.view belowSubview:inviteSegmentedControl];
    } else {
        if (!weddingPlanListViewControllerUnFinish) {
            weddingPlanListViewControllerUnFinish = [[WeddingPlanListViewController alloc] init];
            weddingPlanListViewControllerUnFinish.status = WTMatterStatusUnFinished;
            [self addChildViewController:weddingPlanListViewControllerUnFinish];
			weddingPlanListViewControllerUnFinish.view.frame = CGRectMake(0, kTopViewHeight, screenWidth, screenHeight-kTopViewHeight);
        }
        [self.view insertSubview:weddingPlanListViewControllerUnFinish.view belowSubview:inviteSegmentedControl];
    }
}

- (void)addNewPlan {
    [self.navigationController pushViewController:[WeddingPlanDetailViewController new]
                                         animated:YES];
}

- (void)chooseDate {
    SetDefaultWeddingTimeViewController *setVC = [SetDefaultWeddingTimeViewController new];
    setVC.isFromMain=NO;
    [self.navigationController pushViewController:[SetDefaultWeddingTimeViewController new] animated:YES];
}

- (void)initView {
    self.title = @"婚礼计划";
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
	
    inviteSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"全部",@"已完成",@"未完成"]];
    inviteSegmentedControl.frame = CGRectMake(0, 0, 0, 30);
    inviteSegmentedControl.top= 11.f;
    inviteSegmentedControl.left  = 10.f;
    inviteSegmentedControl.width = screenWidth-2*inviteSegmentedControl.left;
    inviteSegmentedControl.selectedSegmentIndex = 0;
    inviteSegmentedControl.tintColor = [[WeddingTimeAppInfoManager instance] baseColor];
    [inviteSegmentedControl addTarget:self action:@selector(typeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:inviteSegmentedControl];
    
    UIButton * addPlanBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    [addPlanBtn setImage:[UIImage imageNamed :@"add_nav"] forState:UIControlStateNormal ];
    addPlanBtn.adjustsImageWhenHighlighted=NO;
    [addPlanBtn addTarget:self action:@selector(addNewPlan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightAddPlanItem=[[UIBarButtonItem alloc] initWithCustomView:addPlanBtn];
    
    UIButton * dateBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    dateBtn.adjustsImageWhenHighlighted=NO;
    [dateBtn setImage:[UIImage imageNamed :@"icon_setWeddingTime_pink"] forState:UIControlStateNormal ];
    [dateBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightdateItem=[[UIBarButtonItem alloc] initWithCustomView:dateBtn];
    
    self.navigationItem.rightBarButtonItems =@[rightAddPlanItem,rightdateItem];
}

- (void)typeSegmentedControlValueChanged:(UISegmentedControl *)segment
{
    [self changeListWithStatus:(int)segment.selectedSegmentIndex];
}
@end
