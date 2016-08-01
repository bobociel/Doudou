//
//  PaperButton.m
//  lovewith
//
//  Created by imqiuhang on 15/4/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "PaperButton.h"
#import "UUAVAudioPlayer.h"
#import <POP/POP.h>

@interface PaperButton()
@property(nonatomic) CALayer *topLayer;
@property(nonatomic) CALayer *bottomLayer;
@property(nonatomic) BOOL showMenu;

@end

@implementation PaperButton

+ (instancetype)button {
    return [self buttonWithOrigin:CGPointZero];
}

+ (instancetype)buttonWithOrigin:(CGPoint)origin {
    return [[self alloc] initWithFrame:CGRectMake(origin.x,origin.y,24,17)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


#pragma mark - Instance methods

- (void)tintColorDidChange {
    CGColorRef color = self.tintColor.CGColor;
    self.topLayer.backgroundColor = color;
    self.bottomLayer.backgroundColor = color;
}

- (void)animateToMenu {
    [self removeAllAnimations];

    CGPoint center                               = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    POPBasicAnimation *fadeAnimation             = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeAnimation.toValue                        = @0;
    fadeAnimation.duration                       = 0.3;
    
    POPBasicAnimation *positionTopAnimation      = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionTopAnimation.toValue                 = [NSValue valueWithCGPoint:center];
    positionTopAnimation.duration                = 0.3;
    
    POPBasicAnimation *positionBottomAnimation   = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionBottomAnimation.toValue              = [NSValue valueWithCGPoint:center];
    positionTopAnimation.duration                = 0.3;
    
    POPSpringAnimation *transformTopAnimation    = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformTopAnimation.toValue                = @(0);
    transformTopAnimation.springBounciness       = 10.f;
    transformTopAnimation.springSpeed            = 20;
    transformTopAnimation.dynamicsTension        = 250;
    
    POPSpringAnimation *transformBottomAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformBottomAnimation.toValue             = @(0);
    transformBottomAnimation.springBounciness    = 10.0f;
    transformBottomAnimation.springSpeed         = 20;
    transformBottomAnimation.dynamicsTension     = 250;
    
    [self.topLayer pop_addAnimation:positionTopAnimation forKey:@"positionTopAnimation"];
    [self.topLayer pop_addAnimation:transformTopAnimation forKey:@"rotateTopAnimation"];
    [self.bottomLayer pop_addAnimation:positionBottomAnimation forKey:@"positionBottomAnimation"];
    [self.bottomLayer pop_addAnimation:transformBottomAnimation forKey:@"rotateBottomAnimation"];
    self.showMenu = NO;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(toMenuAction)]) {
         [self.delegate toMenuAction];
    }
}

- (void)animateToClose {
    [self removeAllAnimations];
    CGPoint center                               = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    POPBasicAnimation *fadeAnimation             = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeAnimation.toValue                        = @0;
    fadeAnimation.duration                       = 0.3;

    POPBasicAnimation *positionTopAnimation      = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionTopAnimation.toValue                 = [NSValue valueWithCGPoint:center];
    positionTopAnimation.duration                = 0.3;

    POPBasicAnimation *positionBottomAnimation   = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionBottomAnimation.toValue              = [NSValue valueWithCGPoint:center];
    positionTopAnimation.duration                = 0.3;

    POPSpringAnimation *transformTopAnimation    = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformTopAnimation.toValue                = @(-3*M_PI_4);
    transformTopAnimation.springBounciness       = 10.f;
    transformTopAnimation.springSpeed            = 20;
    transformTopAnimation.dynamicsTension        = 250;

    POPSpringAnimation *transformBottomAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformBottomAnimation.toValue             = @(-3*M_PI_4);
    transformBottomAnimation.springBounciness    = 10.0f;
    transformBottomAnimation.springSpeed         = 20;
    transformBottomAnimation.dynamicsTension     = 250;

    [self.topLayer pop_addAnimation:positionTopAnimation forKey:@"positionTopAnimation"];
    [self.topLayer pop_addAnimation:transformTopAnimation forKey:@"rotateTopAnimation"];
    [self.bottomLayer pop_addAnimation:positionBottomAnimation forKey:@"positionBottomAnimation"];
    [self.bottomLayer pop_addAnimation:transformBottomAnimation forKey:@"rotateBottomAnimation"];
    
    self.showMenu = YES;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(toCloseAction)]) {
        [self.delegate toCloseAction];
    }
}

- (void)touchUpInsideHandler:(PaperButton *)sender {
    if (self.showMenu) {
		[[UUAVAudioPlayer sharedInstance] playSongWithData:[UUAVAudioPlayer localAudioDataWithFileName:@"closeButton.wav"] andType:AVFileTypeWAVE];
        [self animateToMenu];
    } else {
		[[UUAVAudioPlayer sharedInstance] playSongWithData:[UUAVAudioPlayer localAudioDataWithFileName:@"openButton.wav"] andType:AVFileTypeWAVE];
        [self animateToClose];
    }
}

- (void)setup {
    CGFloat height                   = 2.f;
    CGFloat width                    = 20;
    CGFloat cornerRadius             = 1.f;
    CGColorRef color                 = [self.tintColor CGColor];

    self.topLayer                    = [CALayer layer];
    self.topLayer.frame              = CGRectMake((self.width-width)/2, (self.height-height)/2, width, height);
    self.topLayer.cornerRadius       = cornerRadius;
    self.topLayer.backgroundColor    = color;

    self.bottomLayer                 = [CALayer layer];
    self.bottomLayer.frame           = CGRectMake((self.width-height)/2, (self.height-width)/2, height, width);
    self.bottomLayer.cornerRadius    = cornerRadius;
    self.bottomLayer.backgroundColor = color;

    [self.layer addSublayer:self.topLayer];
    [self.layer addSublayer:self.bottomLayer];

    [self addTarget:self action:@selector(touchUpInsideHandler:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeAllAnimations {
    [self.topLayer pop_removeAllAnimations];
    [self.bottomLayer pop_removeAllAnimations];
}

@end
