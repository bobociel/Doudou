//
//  WTDeskCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/24.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingBless.h"
#define kCellHeight 185
@class WTDeskCell;
@protocol WTDeskCellDelegate <NSObject>
- (void)WTDeskCellDidBeignEdit:(WTDeskCell *)cell;
- (void)WTDeskCell:(WTDeskCell *)cell didSelectedDelete:(UIControl *)sender;
@end
@interface WTDeskCell : UITableViewCell <UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIControl *deleteControl;
@property (nonatomic,assign) id <WTDeskCellDelegate> delegate;
@property (nonatomic,assign) BOOL canDelete;
@property (nonatomic,strong) WTWeddingDesk *descInfo;
@end

@interface UITableView (WTDeskCell)
- (WTDeskCell *)WTDeskCell;
@end