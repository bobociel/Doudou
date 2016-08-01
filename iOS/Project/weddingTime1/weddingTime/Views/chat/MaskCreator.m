//
//  MaskCreator.m
//  lovewith
//
//  Created by 默默 on 15/7/30.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "MaskCreator.h"
#import "UIImage+Utils.h"
@implementation MaskCreator

float heightRatios[7]={1/1,
    4.0/3.0,
    3.0/2.0,
    3.0/4.0,
    2.0/3.0,
    1136.0/640.0,
    1920.0/1080.0};

+ (MaskCreator *)instance {
    static MaskCreator *_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[MaskCreator alloc] init];
    });
    
    return _instance;
}

- (id)init{
    if (self=[super init]) {
        if (!self.maskDic) {
            self.maskDic=[[NSMutableDictionary alloc]init];
        }
        return self;
    }
    return nil;
}

-(CGSize)returnSizeWithImageSize:(CGSize)imageSize
{
    
    float height=imageSize.width;
    int sizeIndex=0;
    for (int i=0; i<sizeof(heightRatios); i++) {
        float tempHeight=imageSize.width*heightRatios[i];
        if (fabs(height-imageSize.height)>fabs(tempHeight-imageSize.height)) {
            height=tempHeight;
            sizeIndex=i;
        }
    }

    float width=(screenWidth-ChatContentLeft-1*(ChatMargin+ChatIconWH+ChatMargin));
    height=heightRatios[sizeIndex]*width;
    
    return CGSizeMake(width, height);
}

-(UIImage*)returnMaskWithImageSize:(CGSize)imageSize outOrIn:(BOOL)ifout
{
    UIEdgeInsets insets;
    
    float height=imageSize.width;
    int sizeIndex=0;
    for (int i=0; i<sizeof(heightRatios); i++) {
        float tempHeight=imageSize.width*heightRatios[i];
        if (fabs(height-imageSize.height)>fabs(tempHeight-imageSize.height)) {
            height=tempHeight;
            sizeIndex=i;
        }
    }
    
    NSString *key=[NSString stringWithFormat:@"%d%d",ifout,sizeIndex];
    
    int beishu=KEY_WINDOW.screen.scale;
    float width=(screenWidth-ChatContentLeft-1*(ChatMargin+ChatIconWH+ChatMargin))*beishu;
    height=heightRatios[sizeIndex]*width;
    UIImage *maskImageDrawnToSize =self.maskDic[key];
    
    if (!maskImageDrawnToSize) {
        
        __block UIImage *originBubble=nil;
        
        if (ifout) {
            originBubble =[UIImage imageNamed :@"talk_bubble_red"];
            insets = UIEdgeInsetsMake(ChatBackImageEdgeTop,  ChatBackImageEdgeRight, ChatBackImageEdgeBottom,  ChatBackImageEdgeLeft);
        }
        else
        {
            originBubble =[UIImage imageNamed :@"talk_bubble_white"];
            insets =UIEdgeInsetsMake(ChatBackImageEdgeTop,  ChatBackImageEdgeLeft, ChatBackImageEdgeBottom,  ChatBackImageEdgeRight);
        }
        
        width=(int)width;
        height=(int)height;
        originBubble=[originBubble renderAtSize:CGSizeMake(originBubble.size.width*beishu, originBubble.size.height*beishu)];
        originBubble= [originBubble resizableImageWithCapInsets:UIEdgeInsetsMake(insets.top*beishu, insets.left*beishu, insets.bottom*beishu, insets.right*beishu)];
        
        maskImageDrawnToSize = [originBubble renderAtSize:CGSizeMake(width,height)];
        
        [self.maskDic setObject:maskImageDrawnToSize forKey:key];
    }
    
    return maskImageDrawnToSize;
}
@end
