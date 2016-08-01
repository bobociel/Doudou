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
    [self initMoviePlayer];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)initMoviePlayer
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    player = [[MPMoviePlayerController alloc] initWithContentURL:URL];
    player.movieSourceType = MPMovieSourceTypeFile;
    player.controlStyle = MPMovieControlStyleNone;
    player.repeatMode = MPMovieRepeatModeOne;
    [self.view insertSubview:player.view atIndex:0];
    self.view.clipsToBounds=YES;
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.valueOffset([NSValue valueWithCGSize:CGSizeMake(414, 736)]);
    }];
    [player play];
}

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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

@end
