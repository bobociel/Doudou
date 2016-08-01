//
//  ComboListTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ComboListTableViewCell.h"
#import "ComboDetailTableViewCell.h"
@implementation UITableView (ComboListCell)

- (ComboListTableViewCell *)comboCell
{
    static NSString *CellIdentifier = @"ComboListTableViewCell";
    
    ComboListTableViewCell * cell = (ComboListTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[ComboListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@interface ComboListTableViewCell ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *shadowView;
@end
@implementation ComboListTableViewCell
{
    NSArray *array;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}


- (void)setInfo:(id)info
{
    array = info;
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _tableView.frame = CGRectMake(0, 70 * Height_ato, screenWidth, self.size.height - 70 * Height_ato);
    _shadowView.frame = CGRectMake(0, self.size.height - 5 * Height_ato, screenWidth, 5 * Height_ato);
}
- (void)initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30* Height_ato, screenWidth, 18 * Height_ato)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.text = @"套餐价格";
    _titleLabel.textColor = rgba(70, 70, 70, 1);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70 * Height_ato, screenWidth, self.size.height - 70 * Height_ato) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _tableView.pagingEnabled = NO;
    _tableView.scrollEnabled=NO;
    _tableView.scrollsToTop=NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];
    
    self.shadowView = [UIView new];
    _shadowView.backgroundColor = rgba(241, 242, 244, 1);
    [self addSubview:_shadowView];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = array[indexPath.row];
    ComboDetailTableViewCell *cell = [tableView comboDetailCell];
    [cell setInfo:info];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = array[indexPath.row];
    NSNumber *menu_id = info[@"menu_id"];
    [self.delegate comboCellHasSelectedWithMenu_id:menu_id];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62 * Height_ato;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
