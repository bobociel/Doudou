//
//  MaskCreator.h
//  lovewith
//
//  Created by 默默 on 15/7/30.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 自设定
 */
#define ChatMargin        10 //间隔
#define ChatIconWH        44 //头像宽高height,width

#define ChatTimeMarginW   15 //时间文本与边框间隔宽度方向
#define ChatTimeMarginH   10 //时间文本与边框间隔高度方向

#define ChatBackImageEdgeTop    20 //图片的顶部开始拉伸的像素距离，同时也是计算最低高度的依据
#define ChatBackImageEdgeLeft   28 //图片的左边开始拉伸的像素距离
#define ChatBackImageEdgeBottom 20 //图片的底部开始拉伸的像素距离，同时也是计算最低高度的依据
#define ChatBackImageEdgeRight  20 //图片的右边开始拉伸的像素距离

#define ChatContentFontSize 14//字体大小

#define ChatContentLeft   24 //文本内容与按钮左边缘间隔，也是计算最小宽度的依据
#define ChatContentRight  16 //文本内容与按钮右边缘间隔，也是计算最小宽度的依据

#define ChatContentTop    ChatBackImageEdgeTop-ChatContentFontSize/2 //文本内容与按钮上边缘间隔
#define ChatContentBottom ChatBackImageEdgeBottom-ChatContentFontSize/2 //文本内容与按钮下边缘间隔

#define ChatTimeFont  [WeddingTimeAppInfoManager fontWithSize:11] //时间字体
#define ChatContentFont [UIFont fontWithName:@"STHeitiSC-Light" size:ChatContentFontSize] //内容字体
#define ChatContentW screenWidth-ChatContentLeft*2-ChatContentRight-1*(ChatMargin+ChatIconWH+ChatMargin)//内容宽度
#define ChatPicWH   screenWidth-ChatContentLeft-1*(ChatMargin+ChatIconWH+ChatMargin)//图片宽高

@interface MaskCreator : NSObject
@property (nonatomic,strong) NSMutableDictionary *maskDic;
+ (MaskCreator *)instance;
-(CGSize)returnSizeWithImageSize:(CGSize)imageSize;
-(UIImage*)returnMaskWithImageSize:(CGSize)imageSize outOrIn:(BOOL)ifout;
@end
