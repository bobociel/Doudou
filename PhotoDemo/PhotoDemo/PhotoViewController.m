//
//  PhotoViewController.m
//  PhotoDemo
//
//  Created by hangzhou on 15/9/24.
//  Copyright © 2015年 hangzhou. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic,retain) UICollectionView *collectionView;
@property (nonatomic,retain) NSMutableArray *assetArray;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.assetArray = [NSMutableArray array];
    [self setupView];
    
    [self.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result)
        {
           [self.assetArray addObject:result];
        }
        else
        {
            [self.collectionView reloadData];
        }
    }];
}

- (void)setupView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetArray.count;;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assetArray[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
    imageView.frame = cell.contentView.frame;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 75);
}

@end
