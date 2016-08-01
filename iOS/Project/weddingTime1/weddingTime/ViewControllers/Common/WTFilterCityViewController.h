//
//  FilterCityViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol FilterSelectDelegate <NSObject>

- (void)filterHasSelectWithInfo:(id)info index:(NSIndexPath *)index;

@end

@protocol SynFilterSelectDelegate <NSObject>

- (void)synFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index;

@end
@interface WTFilterCityViewController : BaseViewController    

@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSIndexPath *index;
@property (nonatomic, assign) id<FilterSelectDelegate> delegate;
@property (nonatomic, assign) id<SynFilterSelectDelegate> synDelegate;
@end
