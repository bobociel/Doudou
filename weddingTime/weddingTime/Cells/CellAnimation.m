//
//  CellAnimation.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/2.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "CellAnimation.h"
#import "CommAnimationForControl.h"



@implementation UITableViewCell (TableCellAnimation)

- (void)addOpacityAnitionFrom:(float)start to:(float)end
{
    [self.layer pop_addAnimation:[CommAnimationOpacity OpacityFromOpacity:start toOpacity:end] forKey:@"layerOpacityAnimationUnDefault"];
}
- (void)addScaleAnimationFrom:(float)start to:(float)end
{
    [self.layer pop_addAnimation:[CommAnimationScale LayerScaleToScaleWithFromeScale:start andToScale:end ] forKey:@"layerScaleAnimationUnDefault"];
}
@end


@implementation UICollectionViewCell (CollectionCellAnimation)

- (void)addOpacityAnitionFrom:(float)start to:(float)end
{
    [self.layer pop_addAnimation:[CommAnimationOpacity OpacityFromOpacity:start toOpacity:end] forKey:@"layerOpacityAnimationUnDefault"];
}
- (void)addScaleAnimationFrom:(float)start to:(float)end
{
    [self.layer pop_addAnimation:[CommAnimationScale LayerScaleToScaleWithFromeScale:start andToScale:end ] forKey:@"layerScaleAnimationUnDefault"];
}
@end

@implementation CellAnimation


@end
