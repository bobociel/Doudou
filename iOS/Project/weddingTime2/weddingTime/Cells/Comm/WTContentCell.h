//
//  WTContentCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/17.
//  Copyright © 2016年 默默. All rights reserved.
//

@class WTContentCell;
@protocol WTContentCellDelegate <NSObject>
- (void)WTContentCell:(WTContentCell *)cell didSelectedMore:(UIButton *)sender;
- (void)WTContentCell:(WTContentCell *)cell didSelectedLink:(NSURL *)url;
@end

@interface WTContentCell : UITableViewCell <UITextViewDelegate>
@property (nonatomic,assign) BOOL showAll;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet UIButton *showBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTVHeight;

@property (nonatomic,assign) id <WTContentCellDelegate> delegate;
@property (nonatomic,copy) NSString *content;
+ (CGFloat)getHeightWith:(NSString *)content isShowAll:(BOOL)showAll;
@end

@interface UITableView (WTContentCell)
- (WTContentCell *)WTContentCell;
@end