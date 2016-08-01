//
//  chatPointView.m
//  lovewith
//
//  Created by 默默 on 15/7/16.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "chatPointView.h"
#import "ConversationStore.h"
@implementation chatPointView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(instancetype)initWithView:(UIView*)superview center:(CGPoint)center
{
    self = [super init];
    if (self) {
        self.size=CGSizeMake(14, 14);
        self.layer.borderColor=[UIColor whiteColor].CGColor;
        self.layer.borderWidth=2;
        self.layer.cornerRadius=self.bounds.size.width/2;
        self.layer.masksToBounds=YES;
        self.backgroundColor =[UIColor redColor];
        self.text=@"";
        self.textColor=[UIColor whiteColor];
        self.textAlignment=NSTextAlignmentCenter;
        self.font=[UIFont systemFontOfSize:9];
        [superview addSubview:self];
        self.center=center;
        [self checkHaveUnread];
    }
    return self;
}

-(void)checkHaveUnread
{
    int count=[[ConversationStore sharedInstance]conversationUnreadCountAll];
    if (count>0) {
        self.hidden=NO;
        self.text=[NSString stringWithFormat:@"%d",count];
        [self sizeToFit];
        self.height=14;
        self.width+=8;
        if (self.width<self.height) {
            self.width=self.height;
        }
    }
    else
    {
        self.hidden=YES;
    }
}

-(void)dealloc
{
}


@end
