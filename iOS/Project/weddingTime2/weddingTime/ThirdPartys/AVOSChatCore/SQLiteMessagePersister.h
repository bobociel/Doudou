//
//  SQLiteMessagePersister.h
//  FreeChat
//
//  Created by Feng Junwen on 3/4/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePersister.h"


@interface SQLiteMessagePersister : NSObject <MessagePersister>

+(instancetype)sharedInstance;
-(void)openSql:(NSString*)userId;
-(void)close;

@end
