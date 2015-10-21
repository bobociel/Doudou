//
//  AddFriendsViewController.h
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@protocol ContactDelegate <NSObject>
- (void) didSelectItem : (NSInteger) index;
@end

@interface GroupAddFriendsViewController : BaseViewController
@property (nonatomic, weak) id<ContactDelegate> delegate;
@property (nonatomic,strong) NSString *firstUserName;
@end
