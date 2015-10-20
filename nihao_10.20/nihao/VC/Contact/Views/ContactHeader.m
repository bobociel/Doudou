//
//  ContactHeader.m
//  nihoo
//
//  Created by 刘志 on 15/4/20.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "ContactHeader.h"

@interface ContactHeader()

@property (weak, nonatomic) IBOutlet UIView *addFriendView;

@end

@implementation ContactHeader

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"ContactHeader" owner:self options:nil];
        for(NSObject *obj in objs) {
            if([obj isKindOfClass:[ContactHeader class]]) {
                self = (ContactHeader *) obj;
                break;
            }
        }
        [self addLinesBetweenViews];
        [self initViews];
    }
    return self;
}

/**
 *  在header item view之间添加高度为0.5的分割线
 */
- (void) addLinesBetweenViews {
    UIView *seperator1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_addFriendView.frame) - 0.5, SCREEN_WIDTH, 0.5)];
    seperator1.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [_addFriendView addSubview:seperator1];
}

- (void) initViews {
    NSArray *views = @[_addFriendView];
    NSInteger tag = 0;
    for(UIView *view in views) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeaderItem:)];
        recognizer.numberOfTapsRequired = 1;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:recognizer];
        view.tag = tag++;
    }
}

- (void) didSelectHeaderItem : (UITapGestureRecognizer *) recognizer {
    if(_delegate) {
        [_delegate didSelectHeaderItem:recognizer.view.tag];
    }
}

@end
