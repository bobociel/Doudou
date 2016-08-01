//
//  OrderListTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "OrderListTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "WTLocalDataManager.h"
@interface OrderListTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation UITableView (OrderListCell)

- (OrderListTableViewCell *)orderListCell
{
    static NSString *CellIdentifier = @"OrderListTableViewCell";
    
    OrderListTableViewCell * cell = (OrderListTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[OrderListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@implementation OrderListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.avatarImage = [UIImageView new];
    [self.contentView addSubview:_avatarImage];
    _avatarImage.layer.cornerRadius = 24 ;
    _avatarImage.layer.masksToBounds = YES;
    
    
    self.nameLabel = [UILabel new];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [WeddingTimeAppInfoManager fontWithSize:17];
    _nameLabel.textColor = rgba(51, 51, 51, 1);
    self.orderStateLabel = [UILabel new];
    [self.contentView addSubview:_orderStateLabel];
    _orderStateLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    
    _avatarImage.image = [UIImage imageNamed:@"male_default"];
    
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23 );
        make.left.mas_equalTo(12.25 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(48 , 48 ));
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(26 );
        make.left.mas_equalTo(72 );
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [_orderStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(55 );
        make.left.mas_equalTo(72 );
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(14 );
    }];

    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.61, 94 -0.5, screenWidth - 10.61, 0.5)];
    levelImage.image = [LWUtil imageWithColor:rgba(221, 221, 221, 1) frame:CGRectMake(0, 0, screenWidth, 0.5)];
    [self.contentView addSubview:levelImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _avatarImage.contentMode = UIViewContentModeScaleToFill;
}
- (void)setInfo:(OrderList *)info
{
    NSString *child_orders = info.child_orders;
    NSData *data = [child_orders dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [LWUtil toArrayOrNSDictionary:data];
    [_avatarImage sd_setImageWithURL:[NSURL URLWithString:info.logo]
					placeholderImage:[UIImage imageNamed:@"male_default"]];//todo;
    
    NSDictionary *dic = array[0];
    _nameLabel.text = [LWUtil getString:info.company andDefaultStr:@""];
    NSString *pay_status = [LWUtil getString:dic[@"pay_status_name"] andDefaultStr:@""];
    NSString *trans_status = [LWUtil getString:info.trans_status_name andDefaultStr:@""];
    if (pay_status.length == 0) {
        _orderStateLabel.text = trans_status;
    } else {
        _orderStateLabel.text = pay_status;
    }
    [self setImageWithStr:info.logo];
    if (info.trans_status.intValue == 1 || info.trans_status.intValue == -1|| info.trans_status.intValue == -2) {
        _orderStateLabel.textColor = rgba(170, 170, 170, 1);
    } else {
        _orderStateLabel.textColor = [WeddingTimeAppInfoManager instance].baseColor;
    }
}

- (void)setImageWithStr:(NSString *)url
{
    [_avatarImage sd_setImageWithURL:[NSURL URLWithString:url]
					placeholderImage:[UIImage imageNamed:@"male_default"]];
}
- (void)setStateLabelPink
{
    _orderStateLabel.textColor = [WeddingTimeAppInfoManager instance].baseColor;
}

- (void)setStateLabelGray
{
    _orderStateLabel.textColor = rgba(170, 170, 170, 1);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
