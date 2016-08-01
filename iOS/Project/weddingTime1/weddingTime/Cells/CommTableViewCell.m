//
//  CommTableViewCell.m
//  lovewith
//
//  Created by imqiuhang on 15/4/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommTableViewCell.h"

@implementation CommTableViewCell

- (void)setInfo:(id)info {
     MSLog(@"子类%@未实现该方法!!",NSStringFromClass([self class]));
}
- (CGFloat)getHeightWithInfo:(id)info {
    MSLog(@"子类%@未实现该方法!!",NSStringFromClass([self class]));
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self ];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

@end
