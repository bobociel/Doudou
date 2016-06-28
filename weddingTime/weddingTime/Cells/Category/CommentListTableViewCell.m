//
//  CommentListTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "CommentListTableViewCell.h"
#import "CommentDetailTableViewCell.h"

@implementation UITableView (commentListCell)

- (CommentListTableViewCell *)commentListCell
{
    static NSString *CellIdentifier = @"CommentListTableViewCell";
    
    CommentListTableViewCell * cell = (CommentListTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[CommentListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@interface CommentListTableViewCell ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@end
@implementation CommentListTableViewCell
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
    _tableView.frame = CGRectMake(0, 80 * Height_ato, screenWidth, self.size.height - 80 * Height_ato);
}

- (void)initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30* Height_ato, screenWidth, 18 * Height_ato)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.text = @"点评";
    _titleLabel.textColor = rgba(70, 70, 70, 70);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80 * Height_ato, screenWidth, self.size.height - 80 * Height_ato) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pagingEnabled = NO;
    _tableView.scrollEnabled=NO;
    _tableView.scrollsToTop=NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTHotelComment *comment = array[indexPath.item];
    CommentDetailTableViewCell *cell = [tableView commentDetailCell];
	cell.hotelComment = comment;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106 * Height_ato;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
