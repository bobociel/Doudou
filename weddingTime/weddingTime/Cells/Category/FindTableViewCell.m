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
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *dimingView;
//@property (nonatomic, strong) CALayer *dimingLayer;
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
    self.topImage = [UIImageView new];
    [self.contentView addSubview:_topImage];
    [_topImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
    
//	_dimingLayer = [LWUtil gradientLayerWithFrame:CGRectMake(0, kCellHeight - 65, screenWidth, 60)];
//    [self.contentView.layer addSublayer:_dimingLayer];

    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = WHITE;
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [self.contentView addSubview:_titleLabel];
    
    self.detailLabel = [UILabel new];
    self.detailLabel.textColor = WHITE;
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:20];
	_detailLabel.numberOfLines = 0;
    [self.contentView addSubview:_detailLabel];
	[_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(10.0);
		make.bottom.equalTo(self.mas_bottom).offset(-15.0);
		make.width.mas_equalTo(340 * Width_ato);
	}];
}

- (void)setUIWithInfo:(FindItemModel *)info
{
    NSString *imageUrl = info.content.path;

    _topImage.contentMode = UIViewContentModeCenter;
	_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	[self setUpImageView:_topImage withImageURL:[imageUrl stringByAppendingString:kSmall600]];
    _topImage.clipsToBounds = YES;
	_topImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
   [_topImage setContentScaleFactor:[[UIScreen mainScreen] scale]];

	_detailLabel.text = [LWUtil getString:info.content.content andDefaultStr:@""];

	CGSize detailLabelSize = [_detailLabel.text sizeForFont:DefaultFont20 size:CGSizeMake(300 * Width_ato, MAXFLOAT) mode:NSLineBreakByWordWrapping];
	_detailLabel.height = ceil(detailLabelSize.height);

	NSString *content = info.discover_type == FindItemTypeInspiretion ? info.content.counts : info.content.title;
    _titleLabel.attributedText = [LWUtil attributeStringWithType:info.discover_type andContent:content];

	[_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(10.0);
		make.width.mas_equalTo(250 * Width_ato);
		make.bottom.equalTo(_detailLabel.mas_top).offset(-10.0);
		make.height.mas_equalTo(20.0);
	}];
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
        }
		else if (imageURL){
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
