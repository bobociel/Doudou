//
//  AppDelegate.m
//  Popping
//
//  Created by André Schneider on 06.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ViewController *animationsListViewController = [ViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:animationsListViewController];

    [self.window setRootViewController:navigationController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[UINavigationBar appearance] setTitleTextAttributes
	 :@{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:20],
		NSForegroundColorAttributeName: [UIColor blueColor]}];



    return YES;
}

@end
