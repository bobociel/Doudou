//
//  NetWorkingFailDoErr.h
//  weddingTime
//
//  Created by 默默 on 15/9/24.
//  Copyright (c) 2015年 默默. All rights reserved.
//


typedef void (^NetWorkingFailDoErrTouchBlock)();
@interface NetWorkingFailDoErr : UIView
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (copy, nonatomic) NetWorkingFailDoErrTouchBlock touchBlock;
+(void)errWithView:(UIView*)view content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block;

+(void)errWithView:(UIView*)view frame:(CGRect)frame backColor:(UIColor*)backColor font:(UIFont*)textFont textColor:(UIColor*)textColor content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block;

+(void)removeAllErrorViewAtView:(UIView*)view;
@end
