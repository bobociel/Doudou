//
//  CenterTableView.h
//  nihao
//
//  Created by HelloWorld on 7/20/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CenterTableViewDelegate;

@interface CenterTableView : UIView

/**
 *  视图最大的宽度，默认200
 */
@property (nonatomic, assign) NSInteger maxWidth;

/**
 *  视图最大的高度，默认500
 */
@property (nonatomic, assign) NSInteger maxHeight;

/**
 *  根据传入的数组初始化视图
 *
 *  @param data 要显示的数组
 */
- (void)configureViewWithDatas:(NSArray *)data;


/**
 *  显示视图的方法
 *
 *  @param superView 要显示在那个 View 中，一般传入 VC 的 self.view
 */
- (void)showInView:(UIView *)superView;

@property (nonatomic, assign) id<CenterTableViewDelegate> delegate;

@end

@protocol CenterTableViewDelegate <NSObject>

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath withRowText:(NSString *)text;

@end
