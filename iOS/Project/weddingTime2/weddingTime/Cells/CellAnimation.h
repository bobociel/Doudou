//
//  CellAnimation.h
//  weddingTime
//
//  Created by jakf_17 on 15/12/2.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellAnimation : NSObject

@end


@interface UITableViewCell (TableCellAnimation)
- (void)addOpacityAnitionFrom:(float)start to:(float)end;
- (void)addScaleAnimationFrom:(float)start to:(float)end;
@end

@interface UICollectionViewCell (CollectionCellAnimation)
- (void)addOpacityAnitionFrom:(float)start to:(float)end;
- (void)addScaleAnimationFrom:(float)start to:(float)end;
@end