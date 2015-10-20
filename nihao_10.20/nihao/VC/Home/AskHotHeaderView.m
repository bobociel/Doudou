//
//  AskHotHeaderView.m
//  nihao
//
//  Created by HelloWorld on 7/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskHotHeaderView.h"
#import "AskContent.h"
#import "Constants.h"

@interface AskHotHeaderView ()

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;

@end

@implementation AskHotHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = (AskHotHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"AskHotHeaderView" owner:self options:nil][0];
		self.frame = frame;
		
		// 修改 Search 按钮样式
		self.searchBtn.layer.masksToBounds = YES;
		self.searchBtn.layer.borderWidth = 0.5;
		self.searchBtn.layer.borderColor = SeparatorColor.CGColor;
	}
	
	return self;
}

// 根据热门问题的数量来绘制视图
- (void)configureViewWithHotQuestions:(NSArray *)questions {
	NSInteger y = 80;
	NSInteger tag = 0;
	
	for (AskContent *question in questions) {
		UIButton *hotBtn = [self getNewHotButtonWithQuestion:question frame:CGRectMake(0, y, SCREEN_WIDTH, 40)];
		hotBtn.backgroundColor = [UIColor whiteColor];
		hotBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		hotBtn.tag = tag;
		[hotBtn addTarget:self action:@selector(hotQuestionSelected:) forControlEvents:UIControlEventTouchUpInside];
		tag++;
		[self addSubview:hotBtn];
		y += 40;
	}
	
	for (int i = 0; i < questions.count; i++) {
		if (i != questions.count - 1) {
			UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0.5)];
			line.backgroundColor = SeparatorColor;
			[self addSubview:line];
		}
	}
	
	if (questions.count > 0) {
		UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 0.5)];
		line0.backgroundColor = SeparatorColor;
		[self addSubview:line0];
	}
}

- (UIButton *)getNewHotButtonWithQuestion:(AskContent *)question frame:(CGRect)frame {
	UIButton *hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	hotBtn.frame = frame;
	[hotBtn setImage:[UIImage imageNamed:@"icon_hot_question"] forState:UIControlStateNormal];
	[hotBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
	[hotBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	hotBtn.titleLabel.font = FontNeveLightWithSize(16.0);
	[hotBtn setTitleColor:TextColor575757 forState:UIControlStateNormal];
	[hotBtn setTitle:question.aki_title forState:UIControlStateNormal];
	
	return hotBtn;
}

- (void)setSelectedCityName:(NSString *)cityName {
	self.cityNameLabel.text = cityName;
}

#pragma mark - click events

- (IBAction)selectCity:(id)sender {
	if ([self.delegate respondsToSelector:@selector(selectCityClicked)]) {
		[self.delegate selectCityClicked];
	}
}

- (IBAction)search:(id)sender {
	if ([self.delegate respondsToSelector:@selector(searchButtonClicked)]) {
		[self.delegate searchButtonClicked];
	}
}

- (IBAction)moreHotQuestions:(id)sender {
	if ([self.delegate respondsToSelector:@selector(moreHotQuestionsClicked)]) {
		[self.delegate moreHotQuestionsClicked];
	}
}

- (void)hotQuestionSelected:(UIButton *)sender {
	if ([self.delegate respondsToSelector:@selector(hotQuestionSelectedAtIndex:)]) {
		[self.delegate hotQuestionSelectedAtIndex:sender.tag];
	}
}

@end
