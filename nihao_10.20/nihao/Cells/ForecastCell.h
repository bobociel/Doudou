//
//  ForecastCell.h
//  nihao
//
//  Created by HelloWorld on 7/29/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastCell : UICollectionViewCell

- (void)configureCellWithForecastInfo:(NSDictionary *)forecastInfo forRowAtIndexPath:(NSIndexPath *)indexPath weatherPhenomenonDictionary:(NSDictionary *)weatherPhenomenon;

- (void)showCellSubViews:(BOOL)show;

@end
