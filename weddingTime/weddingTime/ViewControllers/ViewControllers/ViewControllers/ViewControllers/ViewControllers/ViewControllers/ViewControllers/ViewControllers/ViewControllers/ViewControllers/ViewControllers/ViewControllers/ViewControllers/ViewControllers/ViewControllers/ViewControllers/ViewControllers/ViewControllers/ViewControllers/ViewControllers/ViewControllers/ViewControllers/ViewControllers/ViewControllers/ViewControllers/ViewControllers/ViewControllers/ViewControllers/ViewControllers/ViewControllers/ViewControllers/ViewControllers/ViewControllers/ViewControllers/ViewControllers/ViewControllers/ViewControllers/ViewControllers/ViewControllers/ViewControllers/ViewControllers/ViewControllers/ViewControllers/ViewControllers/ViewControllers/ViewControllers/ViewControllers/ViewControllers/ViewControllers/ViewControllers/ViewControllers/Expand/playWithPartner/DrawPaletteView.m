//
//  Palette.m
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "DrawPaletteView.h"
#import "WTProgressHUD.h"
#import "ChatMessageManager.h"
@implementation DrawPaletteView {
    BOOL isWaitingForHashInfo;
    int sendHash;
}

@synthesize x;
@synthesize y;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
	
}

- (void)awakeFromNib {

    myallline=[[NSMutableArray alloc] initWithCapacity:10];
    myallColor=[[NSMutableArray alloc] initWithCapacity:10];
    myallwidth=[[NSMutableArray alloc] initWithCapacity:10];

    partnerAallline=[[NSMutableArray alloc] init] ;
    partnerAallColor =[[NSMutableArray alloc] init] ;
    partnerAallwidth =[[NSMutableArray alloc] init] ;

    
    partnerHashDrawQuen = [[NSMutableDictionary alloc] init];
    
    sendHash=0;
}

- (void)drawRect:(CGRect)rect  {
	//获取上下文
	CGContextRef context=UIGraphicsGetCurrentContext();
	//设置笔冒
	CGContextSetLineCap(context, kCGLineCapRound);
	//设置画线的连接处　拐点圆滑
	CGContextSetLineJoin(context, kCGLineJoinRound);
	//画之前线

    
    //画自己的
	if (myallline.count>0) {
		for (int i=0; i<[myallline count]; i++) {
			NSArray* tempArray=[NSArray arrayWithArray:[myallline objectAtIndex:i]];

			if ([myallColor count]>0) {
                segmentColor= [LWUtil colorWithHexString:myallColor[i]].CGColor;
                Intsegmentwidth=[[myallwidth objectAtIndex:i]floatValue]+1;
			}
			if ([tempArray count]>1) {
				CGContextBeginPath(context);
				CGPoint myStartPoint=[[tempArray objectAtIndex:0] CGPointValue];
				CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
				
				for (int j=0; j<[tempArray count]-1; j++) {
					CGPoint myEndPoint=[[tempArray objectAtIndex:j+1] CGPointValue];
					CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);	
				}
				CGContextSetStrokeColorWithColor(context, segmentColor);
				CGContextSetLineWidth(context, Intsegmentwidth);
				CGContextStrokePath(context);
			}
		}
	}
    
    //画对方的
    if (partnerAallline.count>0) {
        for (int i=0; i<[partnerAallline count]; i++) {
            NSArray* tempArray=[NSArray arrayWithArray:[partnerAallline objectAtIndex:i]];
            
            if ([partnerAallColor count]>0) {
                paternerSegmentColor= [LWUtil colorWithHexString:partnerAallColor[i]].CGColor;
                paternerIntsegmentwidth=[[partnerAallwidth objectAtIndex:i]floatValue]+1;
            }
            if ([tempArray count]>1) {
                CGContextBeginPath(context);
                CGPoint myStartPoint=[[tempArray objectAtIndex:0] CGPointValue];
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                
                for (int j=0; j<[tempArray count]-1; j++) {
                    CGPoint myEndPoint=[[tempArray objectAtIndex:j+1] CGPointValue];
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
                CGContextSetStrokeColorWithColor(context, paternerSegmentColor);
                CGContextSetLineWidth(context, paternerIntsegmentwidth);
                CGContextStrokePath(context);
            }
        }
    }
    
	//画当前的线
	if ([myallpoint count]>1) {
		CGContextBeginPath(context);
		//起点
		CGPoint myStartPoint=[[myallpoint objectAtIndex:0]   CGPointValue];
		CGContextMoveToPoint(context,    myStartPoint.x, myStartPoint.y);
		//把move的点全部加入　数组
		for (int i=0; i<[myallpoint count]-1; i++) {
			CGPoint myEndPoint=  [[myallpoint objectAtIndex:i+1] CGPointValue];
			CGContextAddLineToPoint(context, myEndPoint.x,   myEndPoint.y);
		}
		//在颜色和画笔大小数组里面取不相应的值
		segmentColor= [LWUtil colorWithHexString:[myallColor lastObject]].CGColor;
		Intsegmentwidth=[[myallwidth lastObject]floatValue]+1;
		//绘制画笔颜色
		CGContextSetStrokeColorWithColor(context, segmentColor);
		CGContextSetFillColorWithColor (context,  segmentColor);
		//绘制画笔宽度
		CGContextSetLineWidth(context, Intsegmentwidth);
		//把数组里面的点全部画出来
		CGContextStrokePath(context);
	}
}

- (void)IntroductionpointInitPoint {
	myallpoint=[[NSMutableArray alloc] initWithCapacity:10];
}

//把画过的当前线放入　存放线的数组
-(void)IntroductionpointSavePoint {
	[myallline addObject:myallpoint];
}
-(void)IntroductionpointAddPoint:(CGPoint)sender {
	NSValue* pointvalue=[NSValue valueWithCGPoint:sender];
	[myallpoint addObject:pointvalue ];
}

- (void)IntroductionpointHexColor:(NSString *)color {
	[myallColor addObject:color];
}

- (void)IntroductionpointWidth:(int)sender {
	[myallwidth addObject:@(sender)];
}

- (void)myalllineclear {
	if ([myallline count]>0)  {
		[myallline removeAllObjects];
		[myallColor removeAllObjects];
		[myallwidth removeAllObjects];
		[myallpoint removeAllObjects];
		myallline=[[NSMutableArray alloc] initWithCapacity:10];
		myallColor=[[NSMutableArray alloc] initWithCapacity:10];
		myallwidth=[[NSMutableArray alloc] initWithCapacity:10];
		[self setNeedsDisplay];
        [self sendCleanMyDraw];
	}
}

- (void)myLineFinallyRemove {
	if ([myallline count]>0) {
		[myallline  removeLastObject];
		[myallColor removeLastObject];
		[myallwidth removeLastObject];
		[myallpoint removeAllObjects];
    }
	[self setNeedsDisplay];
    if ([myallline count]<=0) {
    [self sendCleanMyDraw];
    }
}


- (void)startSendWithLineArr:(NSArray *)lines andIndex:(int)index andHash:(int)hash andTotalCount:(int)totalCount{
    
    NSMutableArray *sendLine = [[NSMutableArray alloc] init];
    
    for(int i=0;i<lines.count;i++) {
        CGPoint point = [lines[i] CGPointValue];
        NSDictionary *dic =@{@"x":@(point.x/self.width),@"y":@(point.y/self.height)};
        [sendLine addObject:dic];
    }

    AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:nil attributes:@{ConversationTypeKey:ConversationTypeDraw,ConversationIsForGameKey:@(YES),@"data":@{@"isClean":@(NO),@"line":[sendLine copy],@"color":myallColor[index],@"width":myallwidth[index],@"hash":@(hash),@"total":@(totalCount),@"index":@(index)}}];
    
    [[ChatMessageManager instance].conversationOur sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
        if (error) {
            MSLog(@"发送画画信息失败");
        } else {
            
        }
    }];
}

- (void)sendCleanMyDraw {
    
    AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:nil attributes:@{ConversationTypeKey:ConversationTypeDraw,@"data":@{@"isClean":@(YES)}}];
    
    [[ChatMessageManager instance].conversationOur sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
        if (error) {
            MSLog(@"发送画画信息失败");
        } else {
            
        }
    }];

}

- (void)sendMyDraw {
    if ([ChatMessageManager instance].conversationOur) {
        
        int totalSendCount = 0;
        int maxSendCount=40;
        sendHash++;
        for(NSArray *arr in myallline) {
            totalSendCount+=(arr.count/maxSendCount);
            if (arr.count%maxSendCount!=0) {
                totalSendCount+=1;
            }
        }
        
        for(int i=0 ;i<myallline.count;i++) {
            NSArray *curArr = myallline[i];
            int sendCount  = (int)curArr.count/maxSendCount;
            for(int j=0;j<sendCount;j++) {
                NSMutableArray *curMuArr = [[NSMutableArray alloc] init];
                int indexHead = j*maxSendCount;
                for (int k=0; k<maxSendCount; k++) {
                    [curMuArr addObject:curArr[k+indexHead]];
                }
                
                [self startSendWithLineArr:[curMuArr copy] andIndex:i andHash:sendHash andTotalCount:totalSendCount];
            }
            
            if (curArr.count%maxSendCount!=0) {
                NSMutableArray *curMuArr = [[NSMutableArray alloc] init];
                int indexHead = sendCount*maxSendCount;
                for (int k=0; k<curArr.count%maxSendCount; k++) {
                    [curMuArr addObject:curArr[k+indexHead]];
                }
                [self startSendWithLineArr:[curMuArr copy] andIndex:i andHash:sendHash andTotalCount:totalSendCount];

            }
            
        }


    }

}

- (void)didReceiveDrawInfo:(NSNotification *)aNotify {
    
    if (aNotify.object) {
        
        NSDictionary *drawData =aNotify.object;
        
        if ([drawData[@"isClean"]boolValue]==YES) {
            partnerAallline=[[NSMutableArray alloc] init] ;
            partnerAallColor =[[NSMutableArray alloc] init] ;
            partnerAallwidth =[[NSMutableArray alloc] init] ;
            [self setNeedsDisplay];
            return;
        }
        
        if(!partnerHashDrawQuen[drawData[@"hash"]]) {
            NSDictionary *hashDrawQuenDic = @{@"hash":drawData[@"hash"],@"total":drawData[@"total"],@"savecount":@(0),@"data":[[NSMutableDictionary alloc] init]};
            [partnerHashDrawQuen setObject:[hashDrawQuenDic mutableCopy] forKey:drawData[@"hash"]];
        }
        
        if (!partnerHashDrawQuen[drawData[@"hash"]][@"data"][drawData[@"index"]]) {
            [ partnerHashDrawQuen[drawData[@"hash"]][@"data"] setObject:[@{@"line":[[NSMutableArray alloc] init]} mutableCopy]forKey:drawData[@"index"]];
        }
        
        [partnerHashDrawQuen[drawData[@"hash"]] setObject:@([partnerHashDrawQuen[drawData[@"hash"]][@"savecount"] intValue]+1) forKey:@"savecount"];
        
        [partnerHashDrawQuen[drawData[@"hash"]][@"data"][drawData[@"index"]][@"line"] addObjectsFromArray:drawData[@"line"]];
        
        [partnerHashDrawQuen[drawData[@"hash"]][@"data"][drawData[@"index"]] setObject:drawData[@"color"] forKey:@"color"];
        
        [partnerHashDrawQuen[drawData[@"hash"]][@"data"][drawData[@"index"]] setObject:drawData[@"width"] forKey:@"width"];
    
        
        
        int hashFull=-1;
        
        for (id key in partnerHashDrawQuen.allKeys) {
            if ([partnerHashDrawQuen[key][@"total"]intValue ]<=[partnerHashDrawQuen[key][@"savecount"]intValue]) {
                if ([partnerHashDrawQuen[key][@"hash"]intValue ]>hashFull) {
                    hashFull=[partnerHashDrawQuen[key][@"hash"]intValue ];
                }
            }
        }
        
        if (hashFull>=0) {
            partnerAallline=[[NSMutableArray alloc] init] ;
            partnerAallColor =[[NSMutableArray alloc] init] ;
            partnerAallwidth =[[NSMutableArray alloc] init] ;
            
            
            NSMutableArray *sendLine = [[NSMutableArray alloc] init];
            
            for (id key in [partnerHashDrawQuen[@(hashFull)][@"data"] allKeys]) {
                [sendLine addObject:partnerHashDrawQuen[@(hashFull)][@"data"][key][@"line"]];
                [partnerAallColor addObject:partnerHashDrawQuen[@(hashFull)][@"data"][key][@"color"]];
                 [partnerAallwidth addObject:partnerHashDrawQuen[@(hashFull)][@"data"][key][@"width"]];
            }
   
            
            NSMutableArray *patenerSendLines = [[NSMutableArray alloc] initWithCapacity:100];
            for (NSArray *arr in sendLine) {
                NSMutableArray *curArr = [[NSMutableArray alloc] initWithCapacity:100];
                for(int i=0;i<arr.count;i++) {
                    CGPoint point = CGPointMake([arr[i][@"x"] floatValue]*self.width,[arr[i][@"y"] floatValue]*self.height);
                    [curArr addObject:[NSValue valueWithCGPoint:point]];
                }
                [patenerSendLines addObject:curArr];
            }

            partnerAallline = [patenerSendLines mutableCopy];
            
            for(id key in partnerHashDrawQuen.allKeys) {
                if ([key intValue]<=hashFull) {
                    [partnerHashDrawQuen removeObjectForKey:key];
                }
            }
            
            
            [self setNeedsDisplay];
        }
        


    }
    

}

- (BOOL)sendImage {
    
    if (myallline.count<=0&&partnerAallline.count<=0) {
        [WTProgressHUD ShowTextHUD:@"画板上没有任何画哦" showInView:self.superview];
        return NO;
    }
    
   UIImage *image =  [self  screenshotWithQuality:1.f];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"drawImage.jpg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    [UIImageJPEGRepresentation(image, 1.f) writeToFile:filePath atomically:YES];
    if (filePath) {
        [ChatConversationManager sendImage:filePath text:nil attributes:nil conversation:[ChatMessageManager instance].conversationOur push:YES success:^{
            
        } failure:^(NSError *error) {
            
        }];
        return YES;
    }
    return NO;
}
@end
