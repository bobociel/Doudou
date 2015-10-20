//
//  Attachment.h
//  PhotoDemo
//
//  Created by hangzhou on 15/9/29.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Attachment @end

@interface Attachment : JSONModel
@property (nonatomic, copy) NSString *bucket;
@property (nonatomic, copy) NSString *key;
@end
