//
//  SecondViewController.m
//  TestNotification
//
//  Created by wangxiaobo on 16/1/11.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "SecondViewController.h"
#import "ViewController.h"

@implementation SecondViewController
- (IBAction)runNot:(UIBarButtonItem *)sender
{
	NSLog(@"noti start:%@",[NSDate date]);
	for(int i=0; i < 10000000; i++){
		[[NSNotificationCenter defaultCenter] postNotificationName:BBUserInfoUpdateNotification object:nil];
	}

	NSLog(@"delegate start:%@",[NSDate date]);
	for (int i=0; i < 10000000; i++) {
		if([self.delegate respondsToSelector:@selector(secondViewControllerGetInfo:)])
		{
			[self.delegate secondViewControllerGetInfo:@""];
		}
	}

	NSLog(@"block start:%@",[NSDate date]);
	for (int i=0; i < 10000000; i++) {
		if(_block) { self.block(); }
	}
}

@end
