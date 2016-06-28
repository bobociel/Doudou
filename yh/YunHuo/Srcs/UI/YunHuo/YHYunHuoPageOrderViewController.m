//
//  YHYunHuoPageOrderViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15-1-12.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunHuoPageOrderViewController.h"
#import "YHYunHuoPageInfo.h"
#import "TouchView.h"
#import "Header.h"
#import "YHConfig.h"

@implementation YHYunHuoPageOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_pagesArr = [NSArray arrayWithArray:[YHConfig instance].yunhuoPages];
	
    _viewArr1 = [[NSMutableArray alloc] init];
    _viewArr2 = [[NSMutableArray alloc] init];
	
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, 100, 40)];
    _titleLabel.text = @"我的云活";
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:[UIColor colorWithRed:187/255.0 green:1/255.0 blue:1/255.0 alpha:1.0]];
    [self.view addSubview:_titleLabel];
	
    _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(110, KTableStartPointY + KButtonHeight * ([self array2StartY] - 1) + 22, 100, 20)];
    _titleLabel2.text = @"其他云活";
    [_titleLabel2 setFont:[UIFont systemFontOfSize:10]];
    [_titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel2 setTextColor:[UIColor grayColor]];
    [self.view addSubview:_titleLabel2];
	
	TouchView* (^create)(YHYunHuoPageInfo *pageInfo,float x,float y) = ^(YHYunHuoPageInfo *pageInfo,float x,float y){
		TouchView * touchView = [[TouchView alloc] initWithFrame:CGRectMake(x, y, KButtonWidth, KButtonHeight)];
		[touchView setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
		[touchView.label setTextColor:[UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]];
		touchView.label.text = pageInfo.name;
		[touchView.label setTextAlignment:NSTextAlignmentCenter];
		[touchView setMoreChannelsLabel:_titleLabel2];
		touchView->_viewArr11 = _viewArr1;
		touchView->_viewArr22 = _viewArr2;
		touchView.pageInfo = pageInfo;
		
		if ( pageInfo.enabled )
		{
			touchView->_array = _viewArr1;
			[_viewArr1 addObject:touchView];
		}
		else
		{
			touchView->_array = _viewArr2;
			[_viewArr2 addObject:touchView];
		}
		
		[self.view addSubview:touchView];
		return touchView;
	};
	
	int index = 0;
    for (int i = 0; i < _pagesArr.count; i++)
	{
		YHYunHuoPageInfo *pageInfo = _pagesArr[i];
		if ( pageInfo.enabled )
		{
			create(pageInfo,KTableStartPointX + KButtonWidth * (index%5), KTableStartPointY + KButtonHeight * (index/5));
			++index;
		}
    }
	
	index = 0;
	for (int i = 0; i < _pagesArr.count; i++)
	{
		YHYunHuoPageInfo *pageInfo = _pagesArr[i];
		if ( !pageInfo.enabled )
		{
			create(pageInfo,KTableStartPointX + KButtonWidth * (index%5), KTableStartPointY + [self array2StartY] * KButtonHeight + KButtonHeight * (index/5));
			++index;
		}
	}
}

- (unsigned long) array2StartY
{
    unsigned long y = 0;

    y = _pagesArr.count/5 + 2;
    if (_pagesArr.count%5 == 0)
	{
        y -= 1;
    }
    return y;
}

- (IBAction) finishOrder
{
	NSMutableArray *arr = [NSMutableArray array];
	for ( TouchView *tv in _viewArr1 )
	{
		tv.pageInfo.enabled = YES;
		[arr addObject:tv.pageInfo];
	}
	for ( TouchView *tv in _viewArr2 )
	{
		tv.pageInfo.enabled = NO;
		[arr addObject:tv.pageInfo];
	}
	[YHConfig instance].yunhuoPages = arr;
	[[YHConfig instance] save];
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
