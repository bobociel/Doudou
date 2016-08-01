//
//  FilterCityTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "FilterCityTableViewCell.h"

@interface FilterCityTableViewCell ()

@property (nonatomic, strong) UILabel *cityName;
@end
@implementation UITableView (filterCityCell)

- (FilterCityTableViewCell *)filterCityCell
{
    static NSString *CellIdentifier = @"FilterCityTableViewCell";
    
    FilterCityTableViewCell * cell = (FilterCityTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[FilterCityTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;

}

@end
@implementation FilterCityTableViewCell
{
    UIImageView *imageView;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    
}

- (void)initView
{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cityName = [UILabel new];
    [self.contentView addSubview:_cityName];
    self.cityName.textColor = rgba(102, 102, 102, 1);
    self.cityName.textAlignment = NSTextAlignmentCenter;
    self.cityName.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.cityName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 53 * Height_ato - 1, screenWidth - 20, 1)];
    levelImage.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.1)];
    
//    imageView = [[UIImageView alloc] init];
//    [LWAssistUtil imageViewSetAsLineView:imageView color:[UIColor lightGrayColor]];
//    imageView.frame = CGRectMake(20, self.size.height - 0.3, screenWidth - 15, 0.3);
    [self.contentView addSubview:levelImage];
}

- (void)setInfo:(id)info
{
    [self restoreTitleColor];
    self.cityName.text = [LWUtil getString:info[@"name"] andDefaultStr:@""];
}
- (void)restoreTitleColor
{
    self.cityName.textColor = rgba(102, 102, 102, 1);
}

- (void)setSelectedColor
{
    self.cityName.textColor = [WeddingTimeAppInfoManager instance].baseColor;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
