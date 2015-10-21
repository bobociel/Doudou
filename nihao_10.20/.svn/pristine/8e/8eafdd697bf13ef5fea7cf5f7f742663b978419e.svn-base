//
//  PlaceholderTextView.m
//  SaleHelper
//
//  Created by gitBurning on 14/12/8.
//  Copyright (c) 2014年 Burning_git. All rights reserved.
//

#import "PlaceholderTextView.h"

@interface PlaceholderTextView () <UITextViewDelegate>

// 最大长度设置
@property (assign, nonatomic) NSInteger maxTextLength;

@property (copy, nonatomic) id eventBlock;
@property (copy, nonatomic) id beginBlock;
@property (copy, nonatomic) id endBlock;
@property (copy, nonatomic) id textDidChangedBlock;

@end
@implementation PlaceholderTextView
- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self awakeFromNib];
    }
	
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_placeholderTextView removeFromSuperview];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textViewTextDidChanged:)
												 name:UITextViewTextDidChangeNotification
											   object:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textViewTextBeginEditingNotification:)
												 name:UITextViewTextDidBeginEditingNotification
											   object:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textViewTextEndEditingNotification:)
												 name:UITextViewTextDidEndEditingNotification
											   object:self];
	
	self.placeholderColor = [UIColor lightGrayColor];
	_placeholderTextView = [[UITextView alloc] initWithFrame:self.bounds];
	_placeholderTextView.editable = NO;
	_placeholderTextView.selectable = NO;
	_placeholderTextView.showsVerticalScrollIndicator = NO;
	_placeholderTextView.showsHorizontalScrollIndicator = NO;
	_placeholderTextView.userInteractionEnabled = NO;
	_placeholderTextView.backgroundColor = [UIColor clearColor];
	_placeholderTextView.font = self.placeholderFont ? : self.font;
	_placeholderTextView.textColor = self.placeholderColor;
	_placeholderTextView.text = self.placeholder;
	
	[self addSubview:_placeholderTextView];
	
	self.showsVerticalScrollIndicator = NO;
	
	self.maxTextLength = 1000;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	[_placeholderTextView sizeToFit];
	_placeholderTextView.frame = self.bounds;
}

#pragma mark - Notification

- (void)textViewTextDidChanged:(NSNotification *)notification {
	if (self.placeholder.length == 0 || [self.placeholder isEqualToString:@""]) {
		_placeholderTextView.hidden = YES;
	}
	
	if (self.text.length > 0) {
		_placeholderTextView.hidden = YES;
	} else {
		_placeholderTextView.hidden = NO;
	}
	
	if (_textDidChangedBlock) {
		void(^textDidChenged)(PlaceholderTextView *textView) = _textDidChangedBlock;
		textDidChenged(self);
	}
	
	if (_eventBlock && self.text.length > self.maxTextLength) {
		void (^limint)(PlaceholderTextView *textView) =_eventBlock;
		limint(self);
	}
}

- (void)textViewTextBeginEditingNotification:(NSNotification *)notification {
	if (_beginBlock) {
		void(^begin)(PlaceholderTextView *textView) = _beginBlock;
		begin(self);
	}
}

- (void)textViewTextEndEditingNotification:(NSNotification *)notification {
	if (_endBlock) {
		void(^end)(PlaceholderTextView *textView) = _endBlock;
		end(self);
	}
}

#pragma mark - setting

- (void)setPlaceholder:(NSString *)placeholder {
	if (placeholder.length == 0 || [placeholder isEqualToString:@""]) {
		_placeholderTextView.hidden = YES;
	}else {
		_placeholderTextView.hidden = self.text.length > 0;
		_placeholderTextView.text = placeholder;
	}
	
	_placeholder = placeholder;
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor {
	_placeholderTextView.textColor = placeholderColor;
	_placeholderColor = placeholderColor;
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
	_placeholderTextView.font = placeholderFont;
	_placeholderFont = placeholderFont;
}

- (void)setText:(NSString *)text {
	if (text.length > 0) {
		_placeholderTextView.hidden = YES;
	} else {
		_placeholderTextView.hidden = NO;
	}
	
	[super setText:text];
}

#pragma mark - 使用 block 代理 delegate

- (void)addMaxTextLengthWithMaxLength:(NSInteger)maxLength andEvent:(void (^)(PlaceholderTextView *textView))limit {
	_maxTextLength=maxLength;
	
	if (limit) {
		_eventBlock=limit;
	}
}

- (void)addTextViewBeginEvent:(void (^)(PlaceholderTextView *textView))begin {
	_beginBlock = begin;
}

- (void)addTextViewEndEvent:(void (^)(PlaceholderTextView *textView))end {
	_endBlock = end;
}

- (void)addTextViewTextDidChengedEvent:(void(^)(PlaceholderTextView *textView))textDidChanged {
	_textDidChangedBlock = textDidChanged;
}

- (void)setUpdateHeight:(CGFloat)updateHeight {
	CGRect frame = self.frame;
	frame.size.height = updateHeight;
	self.frame = frame;
	_updateHeight = updateHeight;
}

@end
