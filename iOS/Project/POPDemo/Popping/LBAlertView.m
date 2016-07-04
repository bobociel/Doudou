//
//  LBAlertView.m
//  Popping
//
//  Created by wangxiaobo on 16/6/8.
//  Copyright © 2016年 André Schneider. All rights reserved.
//

#import "LBAlertView.h"

@interface LBAlertView()
@property (nonatomic,copy)   NSString *title;
@property (nonatomic,copy)   NSString *cancelButtonTitle;
@property (nonatomic,strong) UIImage  *centerImage;
@property (nonatomic,strong) NSArray  *buttonTitles;

@property (nonatomic,strong) UIView  *contentView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *centerImageView;
@end

@implementation LBAlertView

+ (instancetype)viewWithTitle:(NSString *)title centerImage:(UIImage *)image cancelButton:(NSString *)cancle otherButtons:(NSArray *)buttons
{
	LBAlertView *view = [[LBAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	view.title = title;
	view.centerImage = image;
	view.buttonTitles = buttons;
	[view setupView];
	return view;
}

- (void)setupView
{
	_contentView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/4.0 / 2,
															([UIScreen mainScreen].bounds.size.height - 50) / 2.0,
															[UIScreen mainScreen].bounds.size.width / 4.0 * 3 - 50,
															50)];
	_contentView.backgroundColor = [UIColor whiteColor];
	_contentView.layer.cornerRadius = 10.0;
	_contentView.layer.shadowColor = [UIColor redColor].CGColor;
	_contentView.layer.shadowOffset = CGSizeMake(5, 5);
	_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.frame cornerRadius:_contentView.layer.cornerRadius].CGPath;
	[self addSubview:_contentView];

	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	[_contentView addSubview:_titleLabel];

	_centerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_contentView addSubview:_centerImageView];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
	[_contentView addSubview:lineView];

	for (NSInteger i=0; i < _buttonTitles.count; i++) {
		UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
		actionButton.frame = CGRectMake(0, 30, _contentView.frame.size.width/_buttonTitles.count, 20);
		actionButton.tag = i;
		[actionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		[actionButton setTitle:_buttonTitles[i] forState:UIControlStateNormal];
		[_contentView addSubview:actionButton];
		[actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)action:(UIButton *)sender
{
	[self hide];
	if(_onButtonTouchUpInside){
		self.onButtonTouchUpInside(self,sender.tag);
	}
}

- (void)show
{
	[[UIApplication sharedApplication].keyWindow addSubview:self];

	_contentView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1);
	_contentView.alpha = 0.5;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
		_contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
		_contentView.alpha = 1.0;
	} completion:^(BOOL finished) {

	}];
}

- (void)hide
{
	CATransform3D transform = _contentView.layer.transform;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		_contentView.layer.transform = CATransform3DScale(transform, 0.6, 0.6, 1);
		_contentView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
