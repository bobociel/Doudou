//
//  ComboDetailTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ComboDetailTableViewCell.h"

@implementation UITableView (ComboDetailCell)

- (ComboDetailTableViewCell *)comboDetailCell
{
    static NSString *CellIdentifier = @"ComboDetailTableViewCell";
    
    ComboDetailTableViewCell * cell = (ComboDetailTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[ComboDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end
@interface ComboDetailTableViewCell ()

@property (nonatomic, strong) UILabel *behindLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation ComboDetailTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
    }
    return self;
}

- (void)initView
{
    UILabel *label = [UILabel new];
    [self.contentView addSubview:label];
    label.textAlignment = NSTextAlignmentRight;
    label.font = [WeddingTimeAppInfoManager fontWithSize:12];
    label.textColor = LightGragyColor;
    label.text = @"桌";
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25 * Height_ato);
        make.right.mas_equalTo(-13 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(14 * Width_ato, 14 * Width_ato));
    }];
    self.behindLabel = [UILabel new];
    [self.contentView addSubview:_behindLabel];
    self.behindLabel.textAlignment = NSTextAlignmentRight;
    self.behindLabel.font = [WeddingTimeAppInfoManager fontWithSize:19];
    self.behindLabel.textColor = rgba(255, 100, 153, 1);
    [self.behindLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(18 * Height_ato);
        make.right.mas_equalTo(-30 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(80 * Width_ato, 24 * Height_ato));
    }];
    
    self.nameLabel = [UILabel new];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font =[WeddingTimeAppInfoManager fontWithSize:14];
    _nameLabel.textColor = rgba(102, 102, 102, 1);
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23 * Height_ato);
        make.left.mas_equalTo(10 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(200 * Width_ato, 16 * Height_ato));
    }];
    
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(10 * Width_ato, 62 * Height_ato - 1, screenWidth - 20 * Width_ato, 1)];
    levelImage.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.1)];
    [self.contentView addSubview:levelImage];
    
}

- (void)setMenu:(WTHotelMenu *)menu
{
	_menu = menu;
	_nameLabel.text = _menu.menu_name;
	_behindLabel.text = _menu.menu_price;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
