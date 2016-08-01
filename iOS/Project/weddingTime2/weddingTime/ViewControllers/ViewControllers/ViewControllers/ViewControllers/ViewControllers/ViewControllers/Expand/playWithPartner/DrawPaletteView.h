//
//  Palette.h
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWUtil.h"
#import "ChatConversationManager.h"


@interface DrawPaletteView : UIView
{
	float x;
	float y;
	float           Intsegmentwidth;
	CGColorRef      segmentColor;
    
    float           paternerIntsegmentwidth;
    CGColorRef      paternerSegmentColor;
    

	NSMutableArray* myallpoint;
	NSMutableArray* myallline;
	NSMutableArray* myallColor;
	NSMutableArray* myallwidth;
    
    NSMutableArray* partnerAallline;
    NSMutableArray* partnerAallColor;
    NSMutableArray* partnerAallwidth;
    
    //哈希表暂存 在收到的哈希总数和实际收到的笔画数一致时表示 当前笔画存满 则将收到的所有同伴的笔画显示到画画上
    NSMutableDictionary *partnerHashDrawQuen;

    
	
}

@property float x;
@property float y;

- (void)IntroductionpointInitPoint;
- (void)IntroductionpointSavePoint;
- (void)IntroductionpointAddPoint:(CGPoint)sender;
- (void)IntroductionpointHexColor:(NSString *)hexcolor;
- (void)IntroductionpointWidth:(int)sender;
- (void)didReceiveDrawInfo:(NSNotification *)aNotify;

- (void)myalllineclear;
- (void)myLineFinallyRemove;
- (void)sendMyDraw;
- (BOOL)sendImage;

@end
