//
//  CommentList.h
//  nihao
//
//  Created by HelloWorld on 6/24/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface CommentList : NSObject

// total：评论数量
//@property (nonatomic, assign) NSInteger total;
// rows：评论列表
@property (nonatomic, strong) NSMutableArray *rows;

@end
