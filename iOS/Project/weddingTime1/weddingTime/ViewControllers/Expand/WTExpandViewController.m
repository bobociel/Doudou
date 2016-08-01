//
//  ExpandViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTExpandViewController.h"
#import "ExpandControllerCell.h"
#import "RootView.h"
#import "WTKissViewController.h"
#import "WTDrawViewController.h"
#import "UserInfoManager.h"
#import "WTHomeViewController.h"
#import "WTDemandListViewController.h"
#import "WTCreateDemandViewController.h"
#import <POP/POP.h>
@interface WTExpandViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@end

@implementation WTExpandViewController
{
    UITableView *baseTableView;
    NSArray *btnList;
    
    RootView *gradientBackView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBlurBackgroundView];
    [self initBaseTable];
    // Do any additional setup after loading the view.
}
-(void)changeBackgroundImage{
    [self showBlurBackgroundView];
    // Do any additional setup after loading the view.
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)draw
{
    MSLog();
    if([LWAssistUtil isLogin])
        [WTDrawViewController pushViewControllerWithRootViewController:self isFromJoin:NO isFromChat:NO];
}

-(void)kiss
{
    MSLog();
    if([LWAssistUtil isLogin])
        [WTKissViewController pushViewControllerWithRootViewController:self isFromJoin:NO];
}

-(void)home
{
    MSLog();
    if([LWAssistUtil isLogin]){
        [self.navigationController pushViewController:[WTHomeViewController new] animated:YES];
    }
}

-(void)createNeed
{
    MSLog();
    if([LWAssistUtil isLogin])
    {
        WTCreateDemandViewController *next=[WTCreateDemandViewController new];
        [self.navigationController pushViewController:next animated:YES];
    }
}

-(void)initBaseTable
{
    btnList=[[NSArray alloc]initWithObjects:
             @{@"image":@"icon_draw",@"title":@"一起画",@"subTitle":@"虽然要结婚了，情调依然不能少",@"action":@"draw"},
             @{@"image":@"icon_kiss",@"title":@"指纹kiss",@"subTitle":@"亲爱的你不在我身边，但是还想么么哒！",@"action":@"kiss"},
             @{@"image":@"icon_home_expand",@"title":@"婚礼请柬",@"subTitle":@"拥有独立婚礼域名，把我们婚礼邀请分享给亲朋好友",@"action":@"home"},
             @{@"image":@"icon_need",@"title":@"发起婚礼需求",@"subTitle":@"全城商家抢单｜服务更好｜价格更透明",@"action":@"createNeed"},
             nil];
    
    baseTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    baseTableView.height-=49;
    baseTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    baseTableView.delegate=self;
    baseTableView.dataSource=self;
    baseTableView.backgroundColor=[UIColor clearColor];
    gradientBackView=[RootView new];
    gradientBackView.frame=baseTableView.bounds;
    gradientBackView.needGradient=YES;
    gradientBackView.alpha=0.61;
    [self.view addSubview:gradientBackView];
    
    [self.view addSubview:baseTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)animationBegin
{
    if (baseTableView) {
        [baseTableView reloadData];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return btnList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandControllerCell *cell=[tableView ExpandControllerCell];
    if (indexPath.row>=btnList.count) {
        return nil;
    }
    [cell setInfo:btnList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>=btnList.count) {
        return;
    }
    NSDictionary *dic=btnList[indexPath.row];
    SEL target=NSSelectorFromString([LWUtil getString: dic[@"action"] andDefaultStr:@""]) ;
    if (target&&[self respondsToSelector:target]) {
        IMP imp = [self methodForSelector:target];
        void (*func)(id, SEL) = (void *)imp;
        func(self, target);
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (CellHeight/CellWidth)*tableView.width;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    cell.left=-screenWidth;
    
    NSTimeInterval time=0.3+indexPath.row*0.1;
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:time];
    cell.left=0;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
    
//    float lineSpeedDif=30;
//    POPSpringAnimation *transformBottomAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
//    transformBottomAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, cell.center.y)];
//    transformBottomAnimation.dynamicsTension        =45-indexPath.row*lineSpeedDif;
//    transformBottomAnimation.dynamicsFriction=10;
//    transformBottomAnimation.dynamicsMass=1.4;
//    
//    [cell pop_addAnimation:transformBottomAnimation forKey:@"transformBottomAnimation"];
}
@end
