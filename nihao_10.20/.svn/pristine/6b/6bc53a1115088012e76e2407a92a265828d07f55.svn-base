//
//  ListingLoadingStatusView.m
//  nihao
//
//  Created by 刘志 on 15/6/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ListingLoadingStatusView.h"
#import <UIKit/UIKit.h>

@interface ListingLoadingStatusView() {
    CGFloat _emptyImageWidth;
    CGFloat _emptyImageHeight;
}

@property (nonatomic,strong) UIControl *error;
@property (nonatomic,strong) UIView *empty;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) UIImageView *emptyImage;
@property (nonatomic,strong) UILabel *emptyContent;

@end

@implementation ListingLoadingStatusView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.frame = frame;
        
        //加载中控件
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.frame = CGRectMake((CGRectGetWidth(self.frame) - 50) / 2 , (CGRectGetHeight(self.frame) - 50) / 2 - 20, 50, 50);
        [_indicatorView startAnimating];
        
        //网络异常控件
        UILabel *errLabel = [[UILabel alloc] init];
        errLabel.text = @"Can't establish connection, please try again later";
        errLabel.textColor = ColorWithRGB(216, 216, 216);
        errLabel.font = FontNeveLightWithSize(14.0);
        [errLabel sizeToFit];
        
        _error = [[UIControl alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - CGRectGetWidth(errLabel.frame) ) / 2 , (CGRectGetHeight(self.frame) - CGRectGetHeight(errLabel.frame) - 91 - 15) / 2, CGRectGetWidth(errLabel.frame), CGRectGetHeight(errLabel.frame) + 77 + 15)];
        [_error addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *errImage = [[UIImageView alloc] initWithImage:ImageNamed(@"icon_no_internet")];
        errImage.frame = CGRectMake((CGRectGetWidth(_error.frame) - 77) / 2, 0, 77, 91);
        [_error addSubview:errImage];
        errLabel.frame = CGRectMake(0, CGRectGetMaxY(errImage.frame) + 15, CGRectGetWidth(errLabel.frame), CGRectGetHeight(errLabel.frame));
        [_error addSubview:errLabel];
        
        //内容为空
        _emptyContent = [[UILabel alloc] init];
        _emptyContent.text = @"No results found";
        _emptyContent.textColor = ColorWithRGB(216, 216, 216);
        _emptyContent.font = FontNeveLightWithSize(14.0);
        [_emptyContent sizeToFit];
        
        //默认图片的尺寸
        _emptyImageWidth = NO_SEARCH_CONTENT.width;
        _emptyImageHeight = NO_SEARCH_CONTENT.height;
        _empty = [[UIView alloc] init];
        _empty.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - CGRectGetHeight(_emptyContent.frame) - 15 - _emptyImageHeight) / 2 - 20, CGRectGetWidth(self.frame), CGRectGetHeight(_emptyContent.frame) + 15 + _emptyImageHeight);
        
        _emptyImage = [[UIImageView alloc] initWithImage:ImageNamed(@"icon_no_search_result")];
        _emptyImage.frame = CGRectMake((CGRectGetWidth(_empty.frame) - _emptyImageWidth) / 2, 0, _emptyImageWidth, _emptyImageHeight);
        _emptyImage.contentMode = UIViewContentModeScaleAspectFit;
        _emptyContent.frame = CGRectMake((CGRectGetWidth(_empty.frame) - CGRectGetWidth(_emptyContent.frame)) / 2 + 15, CGRectGetMaxY(_emptyImage.frame) + 15, _emptyImageWidth, CGRectGetHeight(_emptyContent.frame));
        [_empty addSubview:_emptyImage];
        [_empty addSubview:_emptyContent];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    _empty.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - CGRectGetHeight(_emptyContent.frame) - 15 - _emptyImageHeight) / 2 - 20, CGRectGetWidth(self.frame), CGRectGetHeight(_emptyContent.frame) + 15 + _emptyImageHeight);
    _emptyImage.frame = CGRectMake((CGRectGetWidth(_empty.frame) - _emptyImageWidth) / 2, 0, _emptyImageWidth, _emptyImageHeight);
    _emptyContent.frame = CGRectMake((CGRectGetWidth(_empty.frame) - CGRectGetWidth(_emptyContent.frame)) / 2, CGRectGetMaxY(_emptyImage.frame) + 15, CGRectGetWidth(_emptyContent.frame), CGRectGetHeight(_emptyContent.frame));
}

- (void) showWithStatus:(LoadingStatus)status {
    [self removeSubviews];
    switch (status) {
        case Empty:
            [self addSubview:_empty];
            break;
        case Loading:
            [self addSubview:_indicatorView];
            break;
        case NetErr:
            [self addSubview:_error];
            break;
        case Done:
            [self removeFromSuperview];
            break;
        default:
            break;
    }
	
	[self.superview bringSubviewToFront:self];
}

- (void) removeSubviews {
    for(UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.hidden || ![self pointInside:point withEvent:event] || [self isEmptyStatus] || [self isLoadingStatus]) {
        return nil;
    }
    return _error;
}

- (BOOL)isEmptyStatus {
	NSArray *subviews = [self subviews];
	if (subviews != nil && subviews.count > 0) {
        BOOL isEmptyStatus = NO;
        for(UIView *subView in subviews) {
            if(_empty == subView) {
                isEmptyStatus = YES;
            }
        }
		return isEmptyStatus;
	} else {
		return YES;
	}
}

- (BOOL) isLoadingStatus {
    NSArray *subviews = [self subviews];
    if(subviews && subviews.count > 0) {
        BOOL isEmptyStatus = NO;
        for(UIView *subView in subviews) {
            if(_indicatorView == subView) {
                isEmptyStatus = YES;
            }
        }
        return isEmptyStatus;
    }
    return NO;
}

- (void) refreshList {
    self.refresh();
}

- (void) setEmptyImage:(NSString *)imageName emptyContent:(NSString *)emptyContent imageSize:(CGSize)imageSize{
    //内容为空页面
    _emptyImageWidth = imageSize.width;
    _emptyImageHeight = imageSize.height;
    _emptyContent.text = emptyContent;
    _emptyImage.image = ImageNamed(imageName);
    [_emptyContent sizeToFit];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
