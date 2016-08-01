//
//  DWFlowLayout.m
//  CardSlide
//
//  Created by DavidWang on 15/11/25.
//  Copyright © 2015年 DavidWang. All rights reserved.
//

#import "DWFlowLayout.h"

@interface DWFlowLayout ()
{
    CGFloat preOffset;
    CGFloat difference;
    NSIndexPath *mainIndex;
    NSIndexPath *movingIndex;
}
@end

@implementation DWFlowLayout

-(id)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = - 20 * ([UIScreen mainScreen].scale);
        self.sectionInset = UIEdgeInsetsMake(0,40, 0,40);
    }
    return self;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{

    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);//collectionView落在屏幕中点的x坐标
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }

    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

static CGFloat const ActiveDistance = 320;
//static CGFloat const ScaleFactor = 0.2;

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesA = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect ;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;

	//缩放效果
//    for (UICollectionViewLayoutAttributes* attributes in attributesA) {
//
//        CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
//        CGFloat normalizedDistance = distance / ActiveDistance;
//        CGFloat zoom = 1 + ScaleFactor*(1 - ABS(normalizedDistance));
//        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
//        attributes.zIndex = 1.0;
//    }

	//3D内部V形翻页
	for (UICollectionViewLayoutAttributes* attributes in attributesA) {

		CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
		CGFloat normalizedDistance = distance / ActiveDistance;
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = 1.0/-500;
		transform = CATransform3DRotate(transform, normalizedDistance *M_PI/4.0f, 0.0f, 1.0f, 0.0f);
		attributes.transform3D = CATransform3DTranslate(transform, 0.0f, 0.0f, 0.0f);
	}

	//旋转翻页
//    for (UICollectionViewLayoutAttributes *attribute in attributesA)
//    {
//        CGFloat distance = attribute.center.x - CGRectGetMidX(visibleRect);
//        CATransform3D t = CATransform3DIdentity;
//        t.m34  = 1.0/-500;
//        t = CATransform3DRotate(t,-distance/320, distance >0 ? -1 : 1, 1, 0);
//        attribute.transform3D = t;
//    }

    return attributesA;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end