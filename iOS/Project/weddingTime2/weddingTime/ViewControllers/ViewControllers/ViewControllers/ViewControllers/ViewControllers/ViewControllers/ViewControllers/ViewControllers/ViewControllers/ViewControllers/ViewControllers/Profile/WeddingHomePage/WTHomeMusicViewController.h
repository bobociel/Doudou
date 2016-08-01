//
//  WDHomeMusicViewController.h
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"

@protocol musicHasSelectDelegate <NSObject>

- (void)selectMusicName:(NSString *)name andMusicId:(NSString *)musicId;

@end
@interface WTHomeMusicViewController :BaseViewController
@property (nonatomic, strong) NSArray *musicArray;
@property (nonatomic, copy) NSString *musicChoosedID;
@property (nonatomic, weak) id<musicHasSelectDelegate> delegate;
@end
