//
//  WTAlertView+hack.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTAlertView+hack.h"

@implementation WTAlertView (hack)

static char theName;




- (NSString *)myName
{
    return objc_getAssociatedObject(self, &theName);
}

- (void)setMyName:(NSString *)name
{
    objc_setAssociatedObject(self, &theName, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && self.myName.length < 3) {
    } else {
        [self close];
    }
}


@end
