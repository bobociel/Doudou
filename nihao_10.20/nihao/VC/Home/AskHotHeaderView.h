//
//  AskHotHeaderView.h
//  nihao
//
//  Created by HelloWorld on 7/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AskHotHeaderViewDelegate <NSObject>

- (void)selectCityClicked;
- (void)searchButtonClicked;
- (void)moreHotQuestionsClicked;
- (void)hotQuestionSelectedAtIndex:(NSInteger)index;

@end

@interface AskHotHeaderView : UIView

- (void)configureViewWithHotQuestions:(NSArray *)questions;

- (void)setSelectedCityName:(NSString *)cityName;

@property (nonatomic, assign) id<AskHotHeaderViewDelegate> delegate;

@end
