//
//  YHYunHuoViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSegmentedControl;

typedef NS_ENUM(NSInteger, YHYunHuoPageType)
{
	YHYunHuoPageTypeNotif	= 0,
	YHYunHuoPageTypeTask,
	YHYunHuoPageTypeYunPan,
	YHYunHuoPageTypeCheckInOut,
	YHYunHuoPageTypeGPSTrajectory,
	YHYunHuoPageTypeApproval,
	YHYunHuoPageTypeCount,
};

@interface YHYunHuoViewController : UIViewController
@property (nonatomic,weak) IBOutlet HYSegmentedControl	*pageSegmentControl;
@property (nonatomic,weak) IBOutlet UIView				*pageContainer;
@property (nonatomic) NSMutableArray					*projects;

- (IBAction)nextPage:(id)sender;
- (IBAction)prePage:(id)sender;

@end
