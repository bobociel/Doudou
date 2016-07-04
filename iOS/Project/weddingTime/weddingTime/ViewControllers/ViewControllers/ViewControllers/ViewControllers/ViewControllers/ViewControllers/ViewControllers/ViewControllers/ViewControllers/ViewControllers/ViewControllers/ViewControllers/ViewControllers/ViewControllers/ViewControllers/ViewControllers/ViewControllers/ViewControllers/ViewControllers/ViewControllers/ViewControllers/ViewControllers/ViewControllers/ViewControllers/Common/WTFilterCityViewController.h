//
//  FilterCityViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,WTFliterType) {
	WTFliterTypeCity,
	WTFliterTypeSupplier,
	WTFliterTypePost
};
@protocol FilterSelectDelegate <NSObject>
@optional
- (void)cityFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index;
- (void)synFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index;
@end

@interface WTFilterCityViewController : BaseViewController
@property (nonatomic, assign) WTFliterType type;
@property (nonatomic, copy) NSString *synOrCityID;
@property (nonatomic, assign) id<FilterSelectDelegate> delegate;
@end
