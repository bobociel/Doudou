//
//  ContactHeader.h
//  nihoo
//
//  Created by 刘志 on 15/4/20.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactHeaderDelegate <NSObject>

- (void) didSelectHeaderItem : (NSInteger) index;

@end

@interface ContactHeader : UIView

@property (nonatomic, weak) id<ContactHeaderDelegate> delegate;

@end
