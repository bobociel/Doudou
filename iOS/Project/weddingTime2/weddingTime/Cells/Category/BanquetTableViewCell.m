//
//  BanquetTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "BanquetTableViewCell.h"
#import "BanquetCollectionViewCell.h"
#import "WTBanquetViewController.h"
@implementation UITableView (BanquetListCell)

- (BanquetTableViewCell *)banquetCell
{
    static NSString *CellIdentifier = @"BanquetTableViewCell";
    
    BanquetTableViewCell * cell = (BanquetTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[BanquetTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@interface BanquetTableViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *banquetCollect;
@property (nonatomic, strong) UILabel *titileLabel;
@property (nonatomic, strong) UIView *shadowView;
@end
@implementation BanquetTableViewCell
{
    NSArray *array;
}
NSString * const CellIdentifier = @"BanquetCollectionViewCell";
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.banquetCollect.frame = CGRectMake(0, 58 * Height_ato, screenWidth, self.size.height - 58 * Height_ato);
}

- (void)initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29* Height_ato, screenWidth, 18 * Height_ato)];
    self.titileLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titileLabel];
    _titileLabel.font = [UIFont systemFontOfSize:17];
    _titileLabel.text = @"宴会厅";
    _titileLabel.textColor = rgba(70, 70, 70, 1);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((screenWidth - 30) / 2, (screenWidth - 30) / 2);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10);

    self.banquetCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 58 * Height_ato, screenWidth, self.size.height - 58 * Height_ato) collectionViewLayout:flowLayout];
    _banquetCollect.backgroundColor = WHITE;
    [_banquetCollect registerClass:[BanquetCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    _banquetCollect.delegate = self;
    _banquetCollect.dataSource = self;
    _banquetCollect.pagingEnabled = NO;
    _banquetCollect.scrollEnabled=NO;
    _banquetCollect.scrollsToTop=NO;
    [self.contentView addSubview:_banquetCollect];
    
    self.shadowView = [UIView new];
    _shadowView.backgroundColor = rgba(230, 230, 230, 1);
    [self addSubview:_shadowView];
    [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5 * screenHeight / 736.0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(5 * screenHeight / 736.0);
    }];
}

- (void)setInfo:(id)info
{
    array = [NSArray arrayWithArray:info];
    [_banquetCollect reloadData];
}

- (CGFloat)getHeightWithInfo:(id)info
{
    return 192 * Width_ato;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WTHotelBallRoom *ballRoom = array[indexPath.item];
    BanquetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.ballRoom = ballRoom;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WTHotelBallRoom *ballRoom = array[indexPath.row];
    WTBanquetViewController *ban = [[WTBanquetViewController alloc] init];
    ban.ballroom_id = ballRoom.ballroom_id;
    [self.delegate banquetCollectHasSelectedWithBan_id:ballRoom.ballroom_id];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
