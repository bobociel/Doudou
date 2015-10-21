//
//  SelectCityHeaderView.h
//  nihao
//
//  Created by HelloWorld on 7/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectCityHeaderViewDelegate <NSObject>

- (void)searchButtonClicked;
- (void)selectedLocateCity;
- (void)hotCitySelectedAtIndex:(NSInteger)index;

@end

@interface SelectCityHeaderView : UIView

- (void)configureViewWithHotCities:(NSArray *)cities;
- (void)setCurrentCityName:(NSString *)cityName;

@property (nonatomic, assign) id<SelectCityHeaderViewDelegate> delegate;

@end
