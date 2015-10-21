//
//  MImagesViewController.m
//  nihao
//
//  Created by HelloWorld on 8/24/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MImagesViewController.h"
#import "PicCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Picture.h"
#import "MWPhotoBrowser.h"

#define CellSpacing 15

@interface MImagesViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString *CellIdentifier = @"picCollectionCellIdentifier";

@implementation MImagesViewController {
	NSInteger cellSize;
	MWPhotoBrowser *photoBrowser;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Images";
	
	cellSize = (SCREEN_WIDTH - 15 * 3) / 2;
	
	UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
	layout.minimumLineSpacing = CellSpacing;
	layout.minimumInteritemSpacing = CellSpacing;
	layout.scrollDirection = UICollectionViewScrollDirectionVertical;
	layout.itemSize = CGSizeMake(cellSize, cellSize);
	
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.collectionView.alwaysBounceVertical = YES;
	self.collectionView.alwaysBounceHorizontal = NO;
	self.collectionView.showsVerticalScrollIndicator = NO;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.contentInset = UIEdgeInsetsMake(CellSpacing, CellSpacing, CellSpacing, CellSpacing);
	[self.collectionView registerNib:[UINib nibWithNibName:@"PicCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellIdentifier];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.collectionView];
	
//	self.collectionView = [UICollectionView alloc];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.collectionView.frame = self.view.bounds;
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.collectionView.delegate = nil;
	self.collectionView.dataSource = nil;
	self.collectionView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	PicCell *cell = (PicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	Picture *picture = self.pictures[indexPath.row];
	[cell.image sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture.picture_big_network_url]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if (error) {
			cell.image.image = [UIImage imageNamed:@"img_is_load_failed"];
		}
	}];
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	[self showPhotoBrowerAtIndex:indexPath.row];
}

#pragma mark - 浏览图片gallery

- (void)showPhotoBrowerAtIndex:(NSInteger)index {
	photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	//设置浏览图片的navigationbar为蓝色
	photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
	[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
	photoBrowser.displayActionButton = NO;
	photoBrowser.enableGrid = NO;
	[photoBrowser setCurrentPhotoIndex:index];
	[photoBrowser setCurrentPhotoIndex:index];
	// Manipulate
	[photoBrowser showNextPhotoAnimated:YES];
	[photoBrowser showPreviousPhotoAnimated:YES];
	[self.navigationController pushViewController:photoBrowser animated:YES];
}

#pragma mark - mwphotobrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return self.pictures.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index < self.pictures.count) {
		Picture *picture = self.pictures[index];
		NSString *photoUrl = picture. picture_original_network_url;
		MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:photoUrl]]];
		return photo;
	}
	
	return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
