//
//  SettingViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//


typedef NS_ENUM(NSInteger,WTSetType){
	WTSetTypeProfile = 0,
	WTSetTypeSetBG,
	WTSetTypeSetPSW,
	WTSetTypeClearMemory,

	WTSetTypeAboutAs,
	WTSetTypeSuggest,
	WTSetTypeComment,
	WTSetTypeProtocol,
	WTSetTypePolicy,
	WTSetTypeExit
};
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface WTSettingViewController : BaseViewController

@end
