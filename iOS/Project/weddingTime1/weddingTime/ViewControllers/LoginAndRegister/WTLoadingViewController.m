//
//  LodingViewcontrollerViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTLoadingViewController.h"
#import "WTMainViewController.h"
#import "WTLoginViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "QHNavigationController.h"

@interface WTLoadingViewController ()<UserInfoManagerObserver>

@end

@implementation WTLoadingViewController
{
    MPMoviePlayerController *player;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UserInfoManager instance]addInfoUpdateObserver:self forName:infoUpdateObserver];
    [self initMoviePlayer];
    // Do any additional setup after loading the view from its nib.
}

-(void)userInfoUpdate
{
    if ([[UserInfoManager instance].tokenId_self isNotEmptyCtg]) {
        [self hide];
    }
}

-(void)dealloc
{
    [[UserInfoManager instance]removeInfoUpdateObserver: self forName:infoUpdateObserver];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoviePlayer
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    player = [[MPMoviePlayerController alloc] initWithContentURL:URL];
    player.movieSourceType=MPMovieSourceTypeFile;
    player.controlStyle=MPMovieControlStyleNone;
    player.repeatMode=MPMovieRepeatModeOne;
    [self.view insertSubview:player.view atIndex:0];
    self.view.clipsToBounds=YES;
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.valueOffset([NSValue valueWithCGSize:CGSizeMake(414, 736)]);
    }];
    [player play];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)Browse:(id)sender {
    [self hide];
}

-(void)hide
{
    if (self.navigationController) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


//- (IBAction)Login:(id)sender {
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3f;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    transition.type = kCATransitionMoveIn;
//    transition.subtype = kCATransitionFromTop;
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//
//    [self.navigationController pushViewController:[LoginViewController new] animated:NO];
//    //[self.navigationController pushViewController:[MainViewController new] animated:YES];
//}

- (IBAction)Login:(id)sender {
    [LoginManager pushToLoginViewControllerWithAnimation:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

@end
