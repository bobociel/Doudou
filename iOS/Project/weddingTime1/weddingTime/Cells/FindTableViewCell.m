//
//  FindTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/22.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "FindTableViewCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import <Masonry.h>

@implementation UITableView(CommWeddingListCell)

- (FindTableViewCell *)findCell{
    
    static NSString *CellIdentifier = @"FindTableViewCell";
    
    FindTableViewCell * cell = (FindTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[FindTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}
@end


@interface FindTableViewCell ()

@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UILabel *numLebl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation FindTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = WHITE;
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
//    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
//    self.selectedBackgroundView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
    self.topImage = [UIImageView new];
    [self.contentView addSubview:_topImage];
    [_topImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
    
    self.numLebl = [UILabel new];
    _numLebl.textColor = WHITE;
    _numLebl.font = [UIFont boldSystemFontOfSize:19];
//    _numLebl.font = [WeddingTimeAppInfoManager fontWithSize:19];
    [self.contentView addSubview:_numLebl];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = WHITE;
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [self.contentView addSubview:_titleLabel];
    
    self.detailLabel = [UILabel new];
    self.detailLabel.textColor = WHITE;
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:20];
//    _detailLabel.font = [UIFont boldSystemFontOfSize:22];
    _detailLabel.numberOfLines = 0;
    [self.contentView addSubview:_detailLabel];
    
}

- (void)setUIWithInfo:(FindItemModel *)info
{
    NSString *imageUrl = info.path;
    NSString *titleText;
    NSString *detailText = info.content;
   

    _topImage.contentMode = UIViewContentModeCenter;
	_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
    [self setUpImageView:_topImage withImageURL:imageUrl];

    _topImage.clipsToBounds = YES;
	_topImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
   [_topImage setContentScaleFactor:[[UIScreen mainScreen] scale]];


    CGRect rect = [detailText boundingRectWithSize:CGSizeMake(300 * Width_ato, 10000)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:20]}
                                                                      context:nil];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 * Width_ato);
        make.bottom.mas_equalTo(-17 * Height_ato);
        make.width.mas_equalTo(300 * Width_ato);
    }];
    _detailLabel.height = rect.size.height;
    
    
    if (info.type == FindItemTypeSupplier || info.type == FindItemTypePost) {
        titleText = [NSString stringWithFormat:@"%@", info.title];
        _numLebl.frame = CGRectMake(15 * Width_ato, (325 - 27  - 22) * Height_ato- rect.size.height, 26 * Width_ato, 21 * Height_ato);
        _numLebl.text = @"by";
        _numLebl.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.frame = CGRectMake(41* Width_ato, (325 - 27  - 22) * Height_ato- rect.size.height, 250 * Width_ato, 21 * Height_ato);
    } else if (info.type == FindItemTypeInspiretion){
        titleText = @"个婚礼灵感";
        _numLebl.font = [UIFont boldSystemFontOfSize:19];

        NSDictionary *dic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:19]};
        CGRect rect1 = [info.counts boundingRectWithSize:CGSizeMake(10000, 25)
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:dic
													 context:nil];
        self.numLebl.frame = CGRectMake(15 * Width_ato, (325 - 27  - 24) * Height_ato- rect.size.height, rect1.size.width , 25 * Height_ato);
        _numLebl.text = [NSString stringWithFormat:@"%@", info.counts];
        self.titleLabel.frame = CGRectMake(rect1.size.width + 22 * Width_ato, (325 - 27  - 22) * Height_ato- rect.size.height, 250 * Width_ato, 22 * Height_ato);
        
	}

    _titleLabel.text = titleText;
    _detailLabel.numberOfLines = 0;
	_detailLabel.text = detailText;

}


- (void)setUpImageView:(UIImageView *)imageView withImageURL:(NSString *)imageURL
{
    __weak UIImageView *aImageView = imageView;
    [aImageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
                                   placeholderImage:nil
                                            options:SDWebImageRetryFailed
                                           progress:nil
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (image != nil) {
            aImageView.contentMode =  UIViewContentModeScaleAspectFill;
        }else{
            [self setUpImageView:aImageView withImageURL:imageURL.absoluteString];
        }
    }
                               ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
                             ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]										   Diameter:50];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
