//
//  HYSegmentedControl.m
//  CustomSegControlView
//
//  Created by sxzw on 14-6-12.
//  Copyright (c) 2014年 sxzw. All rights reserved.
//

#import "HYSegmentedControl.h"

#define HYSegmentedControl_Height 44.0
#define HYSegmentedControl_Width ([UIScreen mainScreen].bounds.size.width)
#define Min_Width_4_Button 60.0

#define Define_Tag_add 1000

#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RED_LINE_COLOR	([UIColor redColor])

@interface HYSegmentedControl()

@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *array4Btn;
@property (strong, nonatomic)UIView *bottomLineView;
@property (nonatomic) int selectedIndex;

@end

@implementation HYSegmentedControl

- (void) awakeFromNib
{
	[self doInit];
}

//- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate
//{
//    CGRect rect4View = CGRectMake(.0f, y, HYSegmentedControl_Width, HYSegmentedControl_Height);
//    if (self = [super initWithFrame:rect4View]) {
//        
//        self.backgroundColor = UIColorFromRGBValue(0xf3f3f3);
//        [self setUserInteractionEnabled:YES];
//        
//        self.delegate = delegate;
//        
//        //
//        //  array4btn
//        //
//        _array4Btn = [[NSMutableArray alloc] initWithCapacity:titles.count];
//        
//        //
//        //  set button
//        //
//        CGFloat width4btn = rect4View.size.width/titles.count;
//        if (width4btn < Min_Width_4_Button) {
//            width4btn = Min_Width_4_Button;
//        }
//        
//        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        _scrollView.backgroundColor = self.backgroundColor;
//        _scrollView.userInteractionEnabled = YES;
//        _scrollView.contentSize = CGSizeMake(titles.count*width4btn, HYSegmentedControl_Height);
//        _scrollView.showsHorizontalScrollIndicator = NO;
//        
//        for (int i = 0; i<titles.count; i++) {
//            
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(i*width4btn, .0f, width4btn, HYSegmentedControl_Height);
//            [btn setTitleColor:RED_LINE_COLOR forState:UIControlStateNormal];
//            btn.titleLabel.font = [UIFont systemFontOfSize:16];
//            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
//            [btn addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventTouchUpInside];
//            btn.tag = Define_Tag_add+i;
//            [_scrollView addSubview:btn];
//            [_array4Btn addObject:btn];
//            
//            if (i == 0) {
//                btn.selected = YES;
//            }
//        }
//        
//        //
//        //  lineView
//        //
////        CGFloat height4Line = HYSegmentedControl_Height/3.0f;
////        CGFloat originY = (HYSegmentedControl_Height - height4Line)/2;
////        for (int i = 1; i<titles.count; i++) {
////            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i*width4btn-1.0f, originY, 1.0f, height4Line)];
////            lineView.backgroundColor = UIColorFromRGBValue(0xcccccc);
////            [_scrollView addSubview:lineView];
////        }
//		
//        //
//        //  bottom lineView
//        //
//        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, HYSegmentedControl_Height-1, width4btn-10.0f, 1.0f)];
//		_bottomLineView.backgroundColor = RED_LINE_COLOR;//UIColorFromRGBValue(0x454545);
//        [_scrollView addSubview:_bottomLineView];
//        
//        [self addSubview:_scrollView];
//    }
//    return self;
//}

- (void) doInit
{
	self.backgroundColor = [UIColor clearColor];
	[self setUserInteractionEnabled:YES];
	
	if ( self.dataSource == nil )
	{
		return;
	}
	
	for ( UIButton *btn in _array4Btn )
	{
		[btn removeFromSuperview];
	}
	[_array4Btn removeAllObjects];
		
	//
	//  array4btn
	//
	NSArray *titles = [self.dataSource titlesForSegmentControl:self];
	
	if ( titles.count == 0 )
	{
		return;
	}
	_array4Btn = [[NSMutableArray alloc] initWithCapacity:titles.count];
	
	//
	//  set button
	//
	CGFloat width4btn = self.bounds.size.width/titles.count;
	if (width4btn < Min_Width_4_Button)
	{
		width4btn = Min_Width_4_Button;
	}
	
	if ( _scrollView == nil )
	{
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_scrollView.backgroundColor = self.backgroundColor;
		_scrollView.userInteractionEnabled = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		[self addSubview:_scrollView];
	}
	_scrollView.contentSize = CGSizeMake(titles.count*width4btn, HYSegmentedControl_Height);
	
	for (int i = 0; i<titles.count; i++)
	{
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i*width4btn, .0f, width4btn, HYSegmentedControl_Height);
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		btn.titleLabel.font = [UIFont systemFontOfSize:16];
		[btn setTitleColor:RED_LINE_COLOR forState:UIControlStateSelected];
		[btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventTouchUpInside];
		btn.tag = Define_Tag_add+i;
		[_scrollView addSubview:btn];
		[_array4Btn addObject:btn];
		
		if (i == 0) {
			btn.selected = YES;
		}
	}
	
	//
	//  lineView
	//
//	CGFloat height4Line = HYSegmentedControl_Height/3.0f;
//	CGFloat originY = (HYSegmentedControl_Height - height4Line)/2;
//	for (int i = 1; i<titles.count; i++) {
//		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i*width4btn-1.0f, originY, 1.0f, height4Line)];
//		lineView.backgroundColor = UIColorFromRGBValue(0xcccccc);
//		[_scrollView addSubview:lineView];
//	}
	
	//
	//  bottom lineView
	//
	if ( _bottomLineView == nil )
	{
		_bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, HYSegmentedControl_Height-1, width4btn-10.0f, 1.0f)];
		_bottomLineView.backgroundColor = RED_LINE_COLOR;
		[_scrollView addSubview:_bottomLineView];
	}
	[_scrollView bringSubviewToFront:_bottomLineView];
	
	self.selectedIndex = 0;
	_scrollView.contentOffset = CGPointZero;
}

//
//  btn clicked
//
- (void)segmentedControlChange:(UIButton *)btn
{
    btn.selected = YES;
    for (UIButton *subBtn in self.array4Btn) {
        if (subBtn != btn) {
            subBtn.selected = NO;
        }
    }
	
    CGRect rect4boottomLine = self.bottomLineView.frame;
    rect4boottomLine.origin.x = btn.frame.origin.x +5;
	  
    CGPoint pt = CGPointZero;
    BOOL canScrolle = NO;
    if ((btn.tag - Define_Tag_add) >= 2 && [_array4Btn count] > 4 && [_array4Btn count] > (btn.tag - Define_Tag_add + 2)) {
        pt.x = btn.frame.origin.x - Min_Width_4_Button*1.5f;
        canScrolle = YES;
    }else if ([_array4Btn count] > 4 && (btn.tag - Define_Tag_add + 2) >= [_array4Btn count]){
//        pt.x = (_array4Btn.count - 4) * Min_Width_4_Button;
		pt.x = _scrollView.contentSize.width - _scrollView.bounds.size.width;
        canScrolle = YES;
    }else if (_array4Btn.count > 4 && (btn.tag - Define_Tag_add) < 2){
        pt.x = 0;
        canScrolle = YES;
    }
	
	pt.x = MAX(0,MIN(pt.x,_scrollView.contentSize.width - _scrollView.bounds.size.width));
    
    if (canScrolle) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = pt;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.bottomLineView.frame = rect4boottomLine;
            }];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomLineView.frame = rect4boottomLine;
        }];
    }
    
	self.selectedIndex = btn.tag - 1000;
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(hySegmentedControlSelectAtIndex:)]) {

        [self.delegate hySegmentedControlSelectAtIndex:btn.tag - 1000];
    }
}


// delegete method
- (void)changeSegmentedControlWithIndex:(NSInteger)index
{
    if (index > [_array4Btn count]-1) {
        NSLog(@"index 超出范围");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"index 超出范围" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alertView show];
        return;
    }
    
    UIButton *btn = [_array4Btn objectAtIndex:index];
    [self segmentedControlChange:btn];
}

- (int) curIndex
{
	return self.selectedIndex;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
