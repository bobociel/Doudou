//
//  NewsCell.h
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class News;

@interface NewsCell : UITableViewCell

- (void)configureCellWithInfo:(News *)news forRowAtIndexPath:(NSIndexPath *)indexPath;

//图片点击
@property (nonatomic, copy) void(^showBigPhoto)(void);

@end
