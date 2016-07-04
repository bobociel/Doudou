//
//  YHYunHuoViewDetailController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSegmentedControl;

typedef NS_ENUM(NSInteger, YHYunHuoPageType)
{
	YHYunHuoPageTypeRiCheng	= 0,
	YHYunHuoPageTypeActivity,
	YHYunHuoPageTypeYunPan,
	YHYunHuoPageTypeTask,
	YHYunHuoPageTypeGPSTrajectory,
	YHYunHuoPageTypeApproval,
	YHYunHuoPageTypeCheckInOut,
	YHYunHuoPageTypeCount,
};

@interface YHYunHuoViewDetailController : UIViewController
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic,weak) IBOutlet HYSegmentedControl	*pageSegmentControl;
@property (nonatomic,weak) IBOutlet UIView				*pageContainer;

- (IBAction) reorderViewOut:(id)sender;
- (IBAction)nextPage:(id)sender;
- (IBAction)prePage:(id)sender;
@end
