//
//  BaseViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BaseViewController.h"
#import "WTChatDetailViewController.h"
#import "MobClick.h"
#import "WTProgressHUD.h"
#import "LWAssistUtil.h"
#import "UIImage+YYAdd.h"
@interface BaseViewController () <UIActionSheetDelegate,UIAlertViewDelegate>

@end

@implementation BaseViewController
{
    UIView *protectView;
}
@synthesize data,loadingHUD;
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    self.view.backgroundColor = [UIColor whiteColor];
    //todo 此处添加初始化导航栏的代码
    
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.size =CGSizeMake(36, 100);
	if([self isKindOfClass:[WTChatDetailViewController class]])
	{
		backbutton.size = CGSizeMake(50, 50);
		[backbutton setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
		[backbutton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
	}
	else
	{
		backbutton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
		[backbutton setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
		[backbutton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, -15)];
	}

    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backbutton];
    [backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:back];

    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],NSForegroundColorAttributeName:[UIColor blackColor]}];

	_dimingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	_dimingImageView.image = [UIImage imageNamed:@"defaultDiming"];

	_blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	_blurImageView.contentMode=UIViewContentModeScaleAspectFill;
	UIImage *choosedImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
	choosedImage = choosedImage ? : [UIImage imageNamed:@"defaultBG"];
	_blurImageView.image = choosedImage;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    [self setNavWithHidden];
    [self setNavWithWhiteColor];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)setNavWithWhiteColor
{
    if (self.navigationController&&!self.navigationController.navigationBarHidden) {
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            self.navigationController.navigationBar.barTintColor=[UIColor whiteColor];
            self.navigationController.navigationBar.translucent               = NO;
        }//这种设置要加下面几行做保护，以免拖动到其他页面被设为透明后，导航栏出现黑色
        {
            protectView=[[UIView alloc]initWithFrame:CGRectMake(0, -64, screenWidth, 64)];
            protectView.backgroundColor=[UIColor whiteColor];
            [self.view insertSubview:protectView atIndex:0];
        }
    }
    else
    {
		self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

-(void)setNavWithClearColor
{
    if (self.navigationController&&!self.navigationController.navigationBarHidden) {    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.barTintColor=[UIColor clearColor];
        self.navigationController.navigationBar.translucent               = YES;
    }
}

- (void)back {
    //iOS 7
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightNavBtnEvent{
    
}

- (void)setRightBtnWithTitle:(NSString *)aTitle {
    [self setRightBtnWithTitle:aTitle andColor:[WeddingTimeAppInfoManager instance].baseColor];
}

- (void)setRightBtnWithTitle:(NSString *)aTitle andColor:(UIColor *)color; {
    UIButton * rightNavBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightNavBtn.size = CGSizeMake(80, 30);
    rightNavBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [rightNavBtn setTitle:aTitle forState:UIControlStateNormal ];
    [rightNavBtn setTitleColor:color forState:UIControlStateNormal];
    [rightNavBtn addTarget:self action:@selector(rightNavBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    rightNavBtn.titleLabel.font = DefaultFont16;
    [rightNavBtn sizeToFit];
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:rightNavBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setRightBtnWithImage:(UIImage *)aImage
{
    UIButton * rightNavBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
    rightNavBtn.size = aImage.size;
    [rightNavBtn setImage:aImage forState:UIControlStateNormal ];
    [rightNavBtn setImage:aImage forState:UIControlStateHighlighted];
    [rightNavBtn setTintColor:[UIColor clearColor]];
    [rightNavBtn addTarget:self action:@selector(rightNavBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightNavBtnItem=[[UIBarButtonItem alloc] initWithCustomView:rightNavBtn];
    self.navigationItem.rightBarButtonItem = rightNavBtnItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[SDImageCache sharedImageCache] clearMemory];
}

//需要现实毛玻璃背景的调用此方法
-(void)showBlurBackgroundView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeBlurBackgroundView:) name:PushbackgroundImageChanged object:nil];
	[self.view insertSubview:_blurImageView atIndex:0];
	[self.view insertSubview:_dimingImageView aboveSubview:_blurImageView];

	//	UIImage *blImage = [_blurImageView.image imageByBlurRadius:20 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
	//	_blurImageView.image=blImage;
}

- (void)setBlurImageViewWithImage:(UIImage *)image state:(float)state
{
    if (state < 0.169) {
        state = 0.169;
    }

    _blurImageView.image = image;
    _blurImageView.frame = CGRectMake(-151 * state, -187 * state, screenWidth + (302 * state), screenHeight + (374 * state));
}

-(void)changeBlurBackgroundView:(NSNotification*)notObj
{
//    UIImage *blImage = [back imageByBlurRadius: 40 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
    _blurImageView.image = notObj.object;
}

#pragma mark - 修改alertView,actionSheet字体颜色
- (void)willPresentAlertView:(UIAlertView *)alertView
{
	if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.3)
	{
		[[(UIAlertController *)[alertView valueForKey:@"alertController"] actions] enumerateObjectsUsingBlock:^(UIAlertAction *  obj, NSUInteger idx, BOOL *  stop) {
			[obj setValue:WeddingTimeBaseColor forKey:@"titleTextColor"];
		}];
	}
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
	if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.3)
	{
		[[(UIAlertController *)[actionSheet valueForKey:@"alertController"] actions] enumerateObjectsUsingBlock:^(UIAlertAction *  obj, NSUInteger idx, BOOL *  stop) {
			[obj setValue:WeddingTimeBaseColor forKey:@"titleTextColor"];
		}];
	}
}


- (void)showLoadingViewTitle:(NSString*)title {
    [loadingHUD hide:YES];
    loadingHUD = [WTProgressHUD showLoadingHUDWithTitle:title showInView:self.view];
}

- (void)showLoadingView {
    [loadingHUD hide:YES];
    loadingHUD = [WTProgressHUD showLoadingHUDWithTitle:nil showInView:self.view];
}

- (void)showLoadingView:(UIView *)aView {
    [loadingHUD hide:YES];
    loadingHUD = [WTProgressHUD showLoadingHUDWithTitle:nil showInView:aView];
    
}

- (void)showLoadingView:(UIView *)aView top:(CGFloat)top {
    [loadingHUD hide:YES];
    loadingHUD = [WTProgressHUD showLoadingHUDWithTitle:nil showInView:aView];
    loadingHUD.top=top;
    
}

- (void)hideLoadingView {
    [loadingHUD hide:YES];
}

- (void)hideLoadingViewAfterDelay:(CGFloat)time
{
    [loadingHUD hide:YES afterDelay:time];
}

- (void)loadData {
    
}

- (void)reloadData {
    
}

-(void)setDataTableView:(UITableView *)dataTableView
{
    _dataTableView=dataTableView;
    if ([self.dataTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.dataTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.dataTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.dataTableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (void)setDataTableViewAsDefault:(CGRect)frame {
    self.dataTableView = [[UITableView alloc] initWithFrame:frame];
    self.dataTableView.backgroundColor = [UIColor clearColor];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_dataTableView];
}

- (void)cleanData {
    if (data != nil) {
        if ([data isKindOfClass:[NSArray class]]
            || [data isKindOfClass:[NSMutableArray class]]
            || [data isKindOfClass:[NSDictionary class]]
            || [data isKindOfClass:[NSMutableDictionary class]]) {
            
            if (0 < [data count]) {
                
                if ([data isKindOfClass:[NSMutableArray class]]
                    || [data isKindOfClass:[NSMutableDictionary class]]) {
                    [data removeAllObjects];
                }
                data = [[NSMutableArray alloc] init];
            }
        }
        else {
            data = [[NSMutableArray alloc] init];
        }
    }
    else {
        data = [[NSMutableArray alloc] init];
    }
}

- (void)addTapButton
{
    UIButton *backButton = [UIButton new];
    backButton.tag = 10086;
	[backButton setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];

    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 );
        make.left.mas_equalTo(10 );
        make.size.mas_equalTo(CGSizeMake(32 , 32 ));
    }];
    UIButton *backButton_big = [[UIButton alloc] initWithFrame:CGRectMake(0, 12 * Height_ato, 80, 72 * Width_ato)];
    [self.view addSubview:backButton_big];
    [backButton_big addTarget:self action:@selector(tapButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideBackButton
{
    UIButton *button = (UIButton *)[self.view viewWithTag:10086];
    button.hidden = YES;
}

- (void)showBackButton
{
    UIButton *button = (UIButton *)[self.view viewWithTag:10086];
    button.hidden = NO;
}

- (void)tapButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PushbackgroundImageChanged object:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.navigationController.viewControllers.count>1?YES:NO;
}
@end
