//
//  CommIntroView.m
//  weddingTime
//
//  Created by wangxiaobo on 16/1/28.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "CommIntroView.h"
#define kStoryListViewController @"WTStoryListViewController"

#define kButtonHeight 40.0
#define kButtonWidth  40.0
#define kButtonX      20.0
#define kButtonY      20.0

#define kImageViewX 60.0
#define kImageViewWith  (screenWidth - kImageViewX * 2)
#define kImageViewHeigt kImageViewWith * 1.715
#define kImageViewY ((screenHeight - kImageViewHeigt) / 2)

#define kPageControlWidth 100.0
#define kPageControlHeight 25.0
#define kPageControlX	((screenWidth - kPageControlWidth) / 2.0)
#define kPageControlY 	(screenHeight - (kImageViewY + kPageControlHeight) / 2.0 )
@interface CommIntroView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *dimingView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, copy) NSString *currentVCName;
@end

@implementation CommIntroView
+ (instancetype)view
{
	static CommIntroView *introView;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		introView = [[self alloc] init];
	});
	return introView;
}

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
		self.dimingView = [[UIView alloc] initWithFrame:self.bounds];
		self.dimingView.backgroundColor = rgba(0, 0, 0, 0.85);
		[self addSubview:_dimingView];

		self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_closeButton.frame = CGRectMake(kButtonX, kButtonY, kButtonWidth, kButtonHeight);
		_closeButton.contentMode = UIViewContentModeCenter;
		[self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
		[self.closeButton setImage:[UIImage imageNamed:@"close_select"] forState:UIControlStateHighlighted];
		[self addSubview:_closeButton];
		[self.closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (void)setUpIntroViewWithClass:(Class)className
{
	self.currentVCName = NSStringFromClass(className);
	if(![UserInfoManager instance].introVCInfo[_currentVCName])
	{
		[self show];
		if([_currentVCName isEqualToString:kStoryListViewController])
		{
			[_scrollView removeFromSuperview];
			[_pageController removeFromSuperview];
			_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
			_scrollView.contentSize = CGSizeMake(screenWidth * 2, screenHeight);
			_scrollView.showsHorizontalScrollIndicator = NO;
			_scrollView.showsVerticalScrollIndicator = NO;
			_scrollView.pagingEnabled = YES;
			_scrollView.delegate = self;
			[self insertSubview:_scrollView belowSubview:_closeButton];

			_pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(kPageControlX, kPageControlY, kPageControlWidth, kPageControlHeight)];
			_pageController.pageIndicatorTintColor = [UIColor whiteColor];
			_pageController.currentPageIndicatorTintColor = WeddingTimeBaseColor;
			_pageController.numberOfPages = 2;
			_pageController.enabled = NO;
			[self addSubview:_pageController];

			for (NSUInteger i=0; i < 2; i++) {
				UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX + screenWidth * i, kImageViewY, kImageViewWith, kImageViewHeigt)];
				imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"intro_story%lu",(long)(i+1)]];
				[_scrollView addSubview:imageView];
			}
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSInteger index = scrollView.contentOffset.x / screenWidth;
	_pageController.currentPage = index;
}

- (void)show
{
	[KEY_WINDOW addSubview:self];
	self.alpha = 0;
	[UIView animateWithDuration:0.25 animations:^{
		self.alpha = 1.0;
	}completion:^(BOOL finished) {

	}];
}

- (void)hide
{
	[KEY_WINDOW addSubview:self];
	[UIView animateWithDuration:0.25 animations:^{
		self.alpha = 0;
	}completion:^(BOOL finished) {
		[self removeFromSuperview];
		if(![UserInfoManager instance].introVCInfo || ![[UserInfoManager instance].introVCInfo isKindOfClass:[NSMutableDictionary class]])
		{
			[UserInfoManager instance].introVCInfo = [NSMutableDictionary dictionary];
		}
		[[UserInfoManager instance].introVCInfo setObject:@"1" forKey:_currentVCName];
		[[UserInfoManager instance] saveOtherToUserDefaults];
	}];
}

@end
