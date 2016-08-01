//
//  CommentDetailTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "CommentDetailTableViewCell.h"
#import <UIImageView+WebCache.h>
@implementation UITableView (CommentDetailCell)

- (CommentDetailTableViewCell *)commentDetailCell
{
    static NSString *CellIdentifier = @"CommentDetailTableViewCell";
    
    CommentDetailTableViewCell * cell = (CommentDetailTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[CommentDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}


@end

@interface CommentDetailTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end
@implementation CommentDetailTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _avatarImage.contentMode = UIViewContentModeScaleToFill;
}



- (void)initView
{
    self.avatarImage = [UIImageView new];
    self.avatarImage.layer.cornerRadius = 24 *Width_ato;
    self.avatarImage.layer.masksToBounds = YES;
    [self.contentView addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(21 * Height_ato);
        make.left.mas_equalTo(10 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(48 * Width_ato, 48 * Width_ato));
    }];
    
    self.titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * Height_ato);
        make.left.mas_equalTo(72 * Width_ato);
        make.right.mas_equalTo(-10 * Width_ato);
        make.height.mas_equalTo(16 * Height_ato);
    }];
    
    self.detailLabel = [UILabel new];
    [self.contentView addSubview:_detailLabel];
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    _detailLabel.textColor = rgba(119, 119, 119, 1);
    _detailLabel.numberOfLines = 0;
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(52 * Height_ato);
        make.left.mas_equalTo(72 * Width_ato);
        make.right.mas_equalTo(-10 * Width_ato);
        make.bottom.mas_equalTo(-10 * Width_ato);
    }];
    
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(10 * Width_ato, 102 * Height_ato - 1, screenWidth - 20 * Width_ato, 1)];
    levelImage.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.1)];
    [self.contentView addSubview:levelImage];
}

- (void)setInfo:(id)info
{
    [_avatarImage sd_setImageWithURL:[NSURL URLWithString:[LWUtil getString:info[@"comment_author_avatar"] andDefaultStr:@""]] placeholderImage:[UIImage imageNamed:@"defaultPic"]];
    _titleLabel.text = [LWUtil getString:info[@"comment_author_name"] andDefaultStr:@""];
    _detailLabel.text = [LWUtil getString:info[@"comment_content"] andDefaultStr:@""];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
