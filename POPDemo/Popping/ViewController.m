//
//  ViewController.m
//  Popping
//
//  Created by wangxiaobo on 15/12/3.
//  Copyright © 2015年 André Schneider. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Utils.h"
#import "LBAlertView.h"
#import <AFNetworking/AFNetworking.h>
@interface ViewController ()
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, assign) BOOL rotate;
@property (nonatomic, strong) CALayer *topLayer;
@property (nonatomic, strong) CALayer *bottomLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// Animation
	/*
	UIButton *centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	centerButton.backgroundColor = [UIColor yellowColor];
	centerButton.frame = CGRectMake(100, 100, 100, 30);
	[self.view addSubview:centerButton];
	[centerButton addTarget:self action:@selector(animationAction:) forControlEvents:UIControlEventTouchUpInside];

	_topLayer = [CALayer new];
	_topLayer.frame = CGRectMake((100 - 2)/2, 0, 2, 30);
	_topLayer.backgroundColor = [UIColor blackColor].CGColor;
	[centerButton.layer addSublayer:_topLayer];

	_bottomLayer = [CALayer new];
	_bottomLayer.frame = CGRectMake((100-32)/2, (30-2)/2, 30, 2);
	_bottomLayer.backgroundColor = [UIColor blackColor].CGColor;
	[centerButton.layer addSublayer:_bottomLayer];
	 */

	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://dev.lovewith.me/app/v010/u/send_confirm_key/"]];
	request.HTTPMethod = @"POST";
	//	[request setValue:@"method" forHTTPHeaderField:@"POST"];

	NSMutableData *bodyData = [NSMutableData data];
	[bodyData appendData:[@"phone=15093674674" dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:bodyData];


	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse *response, NSError *error) {

		id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
		NSLog(@"%@",result);
		
	}];

	[dataTask resume];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}



#pragma mark - Animation
- (void)animationAction:(UIButton *)sender
{
	sender.selected = !sender.selected;
	CGFloat radius = sender.selected ? -3*M_PI_4 : M_PI_2;
	[self addSpringAnimationToLayer:_topLayer toValue:radius];
	[self addSpringAnimationToLayer:_bottomLayer toValue:radius];
}

- (void)addSpringAnimationToLayer:(CALayer *)layer toValue:(CGFloat)toValue
{
	POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
	animation.springBounciness = 10;
	animation.springSpeed = 20;
	animation.dynamicsTension = 250;
	animation.toValue = @(toValue);
	animation.name = @"rotationToState";
	[layer pop_addAnimation:animation forKey:@"springRotation"];
}

- (void)redViewChangeStyle
{
    POPBasicAnimation *blue = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    blue.toValue = [UIColor blueColor];
    blue.duration = 3;
    [self.redView.layer pop_addAnimation:blue forKey:@"blue"];
   
    POPBasicAnimation *corner = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    corner.toValue = @20.0;
    corner.duration = 4;
    [self.redView.layer pop_addAnimation:corner forKey:@"corner"];
    
    POPBasicAnimation *border = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBorderWidth];
    border.toValue = @3;
    border.duration = 5;
    [self.redView.layer pop_addAnimation:border forKey:@"border"];
    
    POPBasicAnimation *borderColor = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBorderColor];
    borderColor.toValue = [UIColor yellowColor];
    borderColor.duration = 4;
    [self.redView.layer pop_addAnimation:borderColor forKey:@"borderColor"];
    
    POPBasicAnimation *opacity = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacity.toValue = @0.5;
    opacity.duration = 3;
    [self.redView.layer pop_addAnimation:opacity forKey:@"opacity"];

}

- (void)changePosition
{
    POPBasicAnimation *positionXAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    positionXAnimation.toValue = @200;
    [self.redView.layer pop_addAnimation:positionXAnimation forKey:@"positionAnimation"];
    
    POPBasicAnimation *centerAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    [self.redView.layer pop_addAnimation:centerAnimation forKey:@"centerAniamtion"];
}

- (void)scale
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(2.0f, 2.0f)];
    [self.redView pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}


@end
