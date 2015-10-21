//
//  SelectCityHeaderView.m
//  nihao
//
//  Created by HelloWorld on 7/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "SelectCityHeaderView.h"
#import "Constants.h"
#import "HotCityCell.h"
#import "City.h"

@interface SelectCityHeaderView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *currentCityNameBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *allCitiesView;

@end

static NSString *CellReuseIdentifier = @"HotCityCell";

@implementation SelectCityHeaderView {
	CGFloat itemWidth;
	NSArray *hotCities;
}

#pragma mark - view life cycle

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = (SelectCityHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"SelectCityHeaderView" owner:self options:nil][0];
		self.frame = frame;
		
		itemWidth = 0.0;
		
		// 修改 Search 按钮样式
		self.searchBtn.layer.masksToBounds = YES;
		self.searchBtn.layer.borderWidth = 0.5;
		self.searchBtn.layer.borderColor = SeparatorColor.CGColor;
	}
	
	return self;
}

- (void)configureViewWithHotCities:(NSArray *)cities {
	hotCities = cities;
	itemWidth = (SCREEN_WIDTH - 30 - 15 * 2) / 3.0;
	
	// draw lines
	UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 0.5)];
	line0.backgroundColor = SeparatorColor;
	[self addSubview:line0];
	UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
	line1.backgroundColor = SeparatorColor;
	[self.allCitiesView addSubview:line1];
	
	NSInteger lineNumber = 0;
	if (hotCities.count % 3 == 0) {
		lineNumber = hotCities.count / 3;
	} else {
		lineNumber = hotCities.count / 3 + 1;
	}
	
	if (lineNumber > 0) {
		NSInteger updateHeight = CGRectGetHeight(self.frame) + (lineNumber * 30 + (lineNumber - 1) * 15);
		self.frame = CGRectMake(0, 0, SCREEN_WIDTH, updateHeight);
		
		UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
		layout.minimumLineSpacing = 15;
		layout.minimumInteritemSpacing = 15;
		layout.scrollDirection = UICollectionViewScrollDirectionVertical;
		layout.itemSize = CGSizeMake(itemWidth, 30);
		
		self.collectionView.collectionViewLayout = layout;
		self.collectionView.delegate = self;
		self.collectionView.dataSource = self;
		self.collectionView.bounces = NO;
		[self.collectionView registerNib:[UINib nibWithNibName:@"HotCityCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellReuseIdentifier];
		self.collectionView.backgroundColor = [UIColor whiteColor];
		
		[self.collectionView reloadData];
	}
}

- (void)setCurrentCityName:(NSString *)cityName {
	[self.currentCityNameBtn setTitle:cityName forState:UIControlStateNormal];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return hotCities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	HotCityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
	City *city = hotCities[indexPath.row];
	cell.cityNameLabel.text = city.city_name_en;
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	if ([self.delegate respondsToSelector:@selector(hotCitySelectedAtIndex:)]) {
		[self.delegate hotCitySelectedAtIndex:indexPath.row];
	}
}

#pragma mark  click events

- (IBAction)searchCity:(id)sender {
	if ([self.delegate respondsToSelector:@selector(searchButtonClicked)]) {
		[self.delegate searchButtonClicked];
	}
}

- (IBAction)selectLocateCity:(id)sender {
	if ([self.delegate respondsToSelector:@selector(selectedLocateCity)]) {
		[self.delegate selectedLocateCity];
	}
}

@end
