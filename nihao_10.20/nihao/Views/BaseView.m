//
//  BaseView.m
//  nihao
//
//  Created by HelloWorld on 7/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseView.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#define HUD_DELAY 1.5

@implementation BaseView {
	MBProgressHUD *HUD;
}

#pragma mark - HUD
- (void)showHUDWithText:(NSString *)text delay:(NSTimeInterval)delay {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = text;
	HUD.margin = 10.f;
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:delay];
}

- (void)showHUDDone {
	[self showHUDDoneWithText:@"Completed"];
}

- (void)showHUDDoneWithText:(NSString *)text {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [[MBProgressHUD alloc] initWithView:self];
	[self addSubview:HUD];
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_right"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = text;
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDErrorWithText : (NSString *)text {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [[MBProgressHUD alloc] initWithView:self];
	[self addSubview:HUD];
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = text;
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDNetError {
    [self showHUDErrorWithText:BAD_NETWORK];
}

- (void)showHUDServerError {
	[self showHUDErrorWithText:@"Server Error"];
}

- (void)showWithLabelText:(NSString *)showText executing:(SEL)method {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [[MBProgressHUD alloc] initWithView:self];
	[self addSubview:HUD];
	HUD.labelText = showText;
	[HUD showWhileExecuting:method onTarget:self withObject:nil animated:YES];
}

- (void)showHUDWithText:(NSString *)text {
	if (!HUD.isHidden) {
		[HUD hide:NO];
	}
	HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = text;
	HUD.margin = 10.f;
	HUD.removeFromSuperViewOnHide = YES;
}

- (void)processServerErrorWithCode:(NSInteger)code andErrorMsg:(NSString *)msg {
	if (code == 500) {
		[self showHUDServerError];
	} else {
		[self showHUDErrorWithText:msg];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
