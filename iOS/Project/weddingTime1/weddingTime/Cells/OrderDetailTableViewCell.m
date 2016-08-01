//
//  OrderDetailTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "OrderDetailTableViewCell.h"

@interface OrderDetailTableViewCell ()

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation UITableView (OrderDetailCell)

- (OrderDetailTableViewCell *)orderDetailCell
{
    static NSString *CellIdentifier = @"OrderDetailTableViewCell";
    
    OrderDetailTableViewCell * cell = (OrderDetailTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[OrderDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@implementation OrderDetailTableViewCell
{

}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    self.promptLabel = [UILabel new];
    self.promptLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    self.promptLabel.textColor = rgba(170, 170, 170, 1);
    [self.contentView addSubview:_promptLabel];
    
    self.valueLabel = [UILabel new];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    _valueLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.contentView addSubview:_valueLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * Height_ato);
        make.left.mas_equalTo(15 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
        make.width.mas_equalTo(85);
    }];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * Height_ato);
        make.height.mas_equalTo(16 * Width_ato);
        make.left.mas_equalTo(115 * Width_ato);
        make.right.mas_equalTo(-15 * Width_ato);
    }];
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.61 * Width_ato, 50 * Height_ato, screenWidth - 10.61 * Width_ato, 0.5 * Height_ato)];
    [LWAssistUtil imageViewSetAsLineView:levelImage color:[UIColor lightGrayColor]];
    [self.contentView addSubview:levelImage];
}

- (void)setInfo:(id)info
{
    _valueLabel.textColor = rgba(102, 102, 102, 1);
    _valueLabel.text = [LWUtil getString:info[@""] andDefaultStr:@""];
    //todo;
    _valueLabel.text = @"杭州婚礼时光";
}


- (void)setValueLabelTextColor:(UIColor *)color
{
    _valueLabel.textColor = color;
}
- (void)setPromptLabelText:(NSString *)text
{
    _promptLabel.text = text;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
