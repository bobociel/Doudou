//
//  GuideView.h
//  nihao
//
//  Created by 刘志 on 15/8/26.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideView : UIView

- (instancetype) initWithBackgroundImageName : (NSString *) imageName;

@property (nonatomic,copy) void(^getItButtonClick)(void);

@end
