//
//  EmptyListView.m
//  nihao
//
//  Created by HelloWorld on 8/24/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "EmptyListView.h"
#import "Constants.h"

#define ImageViewWidth 109
#define ImageViewHeight 75
#define ImageViewLabelSpace 20

@interface EmptyListView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation EmptyListView

#pragma mark - Lifecycle

- (void)dealloc {
	
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
//		NSInteger viewX = (SCREEN_WIDTH - EmptyListViewWidth) / 2;
//		CGRect viewFrame = CGRectMake(viewX, 100, EmptyListViewWidth, EmptyListViewHeight);
//		self.frame = viewFrame;
		
		[self setUpViews];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGFloat labelWidth = CGRectGetWidth(self.hintLabel.frame);
	CGFloat viewWidth = MIN(MAX(labelWidth, ImageViewWidth), SCREEN_WIDTH);
	CGFloat labelHeight = CGRectGetHeight(self.hintLabel.frame);
	CGFloat viewHeight = ImageViewHeight + (labelHeight ? (labelHeight + ImageViewLabelSpace) : 0);
	NSInteger viewX = (SCREEN_WIDTH - viewWidth) / 2;
	self.imageView.center = CGPointMake(viewWidth / 2, ImageViewHeight / 2);
	self.hintLabel.frame = CGRectMake(0, ImageViewHeight + ImageViewLabelSpace, viewWidth, labelHeight);
	self.frame = CGRectMake(viewX, 100, viewWidth, viewHeight);
}

#pragma mark - Private

- (void)setUpViews {
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ImageViewWidth, ImageViewHeight)];
	self.imageView.image = [UIImage imageNamed:@"img_empty_list"];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
	
	self.hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.hintLabel.font = FontNeveLightWithSize(18);
	self.hintLabel.textColor = HintTextColor;
	self.hintLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:self.hintLabel];
}

#pragma mark - Setter

- (void)setHintText:(NSString *)hintText {
	self.hintLabel.text = hintText;
	[self.hintLabel sizeToFit];
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

//- (void)setEmptyListViewType:(EmptyListViewType)emptyListViewType hintText:(NSString *)hintText {
//	
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
