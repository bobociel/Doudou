//
//  WTThemeCell.h
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingTheme.h"
@class WTThemeCell;
@protocol WTThemeCellDelegate <NSObject>
- (void)WTThemeCell:(WTThemeCell *)cell didSeledtedOpenCard:(UIControl *)sender;
@end

@interface WTThemeCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIButton *showCardButton;
@property (nonatomic,assign) id <WTThemeCellDelegate> delegate;
@property (nonatomic,strong) WTWeddingTheme *theme;
@end
