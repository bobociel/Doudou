//
//  UserGuideViewController.m
//  nihao
//
//  Created by HelloWorld on 7/6/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "UserGuideViewController.h"

@interface UserGuideViewController () <UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIPageControl *_page;
    UIButton *_closeButton;
    NSMutableArray *_guideImageViews;
    NSMutableArray *_guideImages;
    UIButton *_skipButton;
    BOOL _pageControlUsed;
}

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self dontShowBackButtonTitle];
	self.title = @"User Guide";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor clearColor];
    //初始化每个页面的View对象
    NSArray *imageArray = @[@"icon_guide_post.jpg",@"icon_guide_ask.jpg",@"icon_guide_translate.jpg",@"icon_guide_message.jpg",@"icon_guide_contact.jpg",@"icon_guide_recharge.jpg",@"icon_guide_exchange.jpg"];
    _guideImages = [NSMutableArray array];
    [_guideImages addObjectsFromArray:imageArray];
    _guideImageViews = [NSMutableArray arrayWithCapacity:imageArray.count];
    for(NSUInteger i = 0; i < _guideImages.count;i++) {
        [_guideImageViews addObject:[NSNull null]];
    }
    
    CGRect frame = self.view.frame;
    
    //设置滚动条的属性
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setFrame:frame];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * _guideImages.count + 10, SCREEN_HEIGHT - 20);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    //初始化页码
    _page = [[UIPageControl alloc] init];
    [_page setFrame:CGRectMake(140, SCREEN_HEIGHT - 50, 38, 36)];
    _page.numberOfPages = _guideImages.count;
    _page.currentPage = 0;
    [_page addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_page];
    
    _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_skipButton setImage:ImageNamed(@"icon_close_guide") forState:UIControlStateNormal];
    [_skipButton setImage:ImageNamed(@"icon_close_guide") forState:UIControlStateSelected];
    [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _skipButton.titleLabel.font = FontNeveLightWithSize(16.0);
    _skipButton.frame = CGRectMake(15, 15, 30, 30);
    [_skipButton addTarget:self action:@selector(closeWelcomeView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_skipButton];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    //[_page setHidden:YES];
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0){
        return;
    }
    
    CGRect frame = self.view.frame;
    float w = frame.size.width, h = frame.size.height;
    
    if(page >= _guideImages.count) {
        return;
    }
    
    UIImageView *controller = [_guideImageViews objectAtIndex:page];
    if((NSNull *)controller == [NSNull null]) {
        controller = [[UIImageView alloc] initWithFrame:CGRectMake(w * page, 0, w, h)];
        UIImage *image = [UIImage imageNamed:_guideImages[page]];
        controller.image = image;
        [_guideImageViews replaceObjectAtIndex:page withObject:controller];
        [_scrollView addSubview:controller];
    }
}



- (void) changePage:(id)sender {
    int page = (int)_page.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
    
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}


- (void) closeThisView:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void) closeWelcomeView {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIScrollView Delegate

//----------------------
//  实现滚动条的委托方法
//----------------------


-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    // Switch the indicator when more than 50% of the previous/next page is visible
    float offsetx = scrollView.contentOffset.x;
    if(((_guideImages.count -1) * pageWidth) < offsetx) {
        [self closeThisView:nil];
        return;
    }
    
    int page = floor((offsetx - pageWidth / 2) / pageWidth) + 1;
    _page.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}


@end
