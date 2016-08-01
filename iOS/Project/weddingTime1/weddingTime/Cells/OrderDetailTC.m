//
//  OrderDetailTC.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/10.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "OrderDetailTC.h"
#import "WTLocalDataManager.h"
@implementation UITableView (OrderDetailTC)

- (OrderDetailTC *)orderDetailTC
{
    static NSString *CellIdentifier = @"OrderDetailTC";
    
    OrderDetailTC * cell = (OrderDetailTC *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[OrderDetailTC alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@interface OrderDetailTC ()

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@end
@implementation OrderDetailTC

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
    self.promptLabel = [UILabel new];
    self.promptLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    self.promptLabel.textColor = rgba(170, 170, 170, 1);
    [self.contentView addSubview:_promptLabel];
    
    self.valueLabel = [UILabel new];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    _valueLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [self.contentView addSubview:_valueLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23 * Height_ato > 17 ? 23 * Height_ato : 17);
        make.left.mas_equalTo(15 * Width_ato);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(85);
    }];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23 * Height_ato > 17 ? 23 * Height_ato : 17);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(115 * Width_ato);
        make.right.mas_equalTo(-15 * Width_ato);
    }];
//    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(20 * Width_ato, 49.5 * Height_ato, screenWidth - 20 * Width_ato, 0.1 * Height_ato)];
//    [LWAssistUtil imageViewSetAsLineView:levelImage color:[UIColor lightGrayColor]];
    
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(15 * Width_ato, 50 * Height_ato > 38 ? 50 * Height_ato:38 - 0.5, screenWidth - 15 * Width_ato, 0.5)];
    lineView.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.5)];
    [self.contentView addSubview:lineView];
}

- (void)setInfo:(OrderDetail *)info index:(NSIndexPath *)index
{
    if (index.row == 0) {
        _valueLabel.text = [LWUtil getString:info.creater_username andDefaultStr:@""];
    }
    if (index.row == 1) {
        _valueLabel.text = [LWUtil getString:info.supplier_company andDefaultStr:@""];
    }
    if (index.row == 2) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:info.wedding_timestamp.integerValue];
        NSString *dateStr = [LWUtil convertNSDateToNSString:date];
        _valueLabel.text = [LWUtil getString:dateStr andDefaultStr:@""];
    }
    if (index.row == 3) {
        _valueLabel.text = [LWUtil getString:info.wedding_city andDefaultStr:@""];
    }
    NSString *child_orders = info.child_orders;
    NSData *data = [child_orders dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [LWUtil toArrayOrNSDictionary:data];
    if (array.count == 0) {
        if (index.row == 4) {
            _valueLabel.text = [NSString stringWithFormat:@"%@%@", @"￥", @""];
        }
        
    } else {
    NSDictionary *dic = array[0];
        if (index.row==4) {
            NSString *total_fee = [LWUtil getString:dic[@"total_fee"] andDefaultStr:@""];
            _valueLabel.text = [NSString stringWithFormat:@"%@%@", @"￥", total_fee];
        }
    
    }
    //todo;
    
}

- (void)setvaluelabeltext:(NSString *)text
{
    _valueLabel.text = text;
}
- (void)setValueLabelTextColor:(UIColor *)color
{
    _valueLabel.textColor = color;
}
- (void)setPromptLabelText:(NSString *)text
{
    _promptLabel.text = text;
}

@end
