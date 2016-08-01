//
//  QHNavigationController.M
//  QHNavigationController
//
//
//  Created by momo on 15/6/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "QHNavigationController.h"
@implementation QHNavigationController

@synthesize currentShowVC;
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)vc
                    animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.enabled = YES;
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = nil;
    else
        self.currentShowVC = vc;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        return NO;
    }
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        
        if (!self.currentShowVC) {
            return NO;
        }
        return (self.currentShowVC == self.topViewController);
    }
    return YES;
}

- (void)viewDidLoad {
    __weak QHNavigationController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate
{
	if([self.topViewController isKindOfClass:[MPMoviePlayerViewController class]])
	{
		return YES;
	}
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if([self.topViewController isKindOfClass:[MPMoviePlayerViewController class]])
	{
		return UIInterfaceOrientationMaskAll;
	}
	return UIInterfaceOrientationMaskPortrait;
}
@end
