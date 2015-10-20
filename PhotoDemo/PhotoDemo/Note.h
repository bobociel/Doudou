//
//  Note.h
//  PhotoDemo
//
//  Created by hangzhou on 15/9/29.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Attachment.h"
@interface Note : JSONModel
@property (nonatomic, copy) NSString    *noteid;
@property (nonatomic, retain) User      *createUser;
@property (nonatomic, copy) NSString    *createTime;
@property (nonatomic, copy) NSString    *updateTime;
@property (nonatomic, copy) NSString    *contents;
@property (nonatomic, retain) NSMutableArray<Attachment,Optional>   *picture;
@property (nonatomic, retain) Attachment<Optional>                  *voice;
@end
