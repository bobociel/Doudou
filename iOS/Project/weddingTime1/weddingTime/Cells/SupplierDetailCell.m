//
//  SupplierDetailCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "SupplierDetailCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
@implementation UITableView (SupplerDetail)

- (SupplierDetailCell *)supplerDetailCell
{
    static NSString *CellIdentifier = @"CommonTableViewCell";
    
    SupplierDetailCell * cell = (SupplierDetailCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[SupplierDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;

}

@end

@interface SupplierDetailCell ()

@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UILabel *titilLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@end
@implementation SupplierDetailCell
{
    UIView *shadowView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}


- (void)initView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.topImage = [UIImageView new];
    [self addSubview:_topImage];

    self.titilLabel = [UILabel new];
    
    _titilLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    _titilLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titilLabel];
    _titilLabel.numberOfLines = 0;
    
    self.priceLabel = [UILabel new];
    _priceLabel.font = [UIFont systemFontOfSize:14];
    _priceLabel.textColor = [UIColor colorWithRed:178 / 255.0 green:178 / 255.0 blue:178 / 255.0 alpha:1];
    [self addSubview:_priceLabel];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    
    shadowView = [UIView new];
    shadowView.backgroundColor = rgba(230, 230, 230, 1);
    [self.contentView addSubview:shadowView];
    
}

- (void)setInfo:(id)info
{
    NSString *tempStr = info[@"post_pic"];
    NSArray *tempArray = [tempStr componentsSeparatedByString:@"?imageView2/"];
    NSString *urlStr = tempArray[0];

    __weak UIImageView *top = _topImage;
    _topImage.contentMode = UIViewContentModeCenter;

	_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
    [_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:urlStr]
								   placeholderImage:nil
											options:SDWebImageRetryFailed
										   progress:nil
										  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
											  if (image != nil) {
												  top.contentMode =  UIViewContentModeScaleToFill;
											  }
										  }
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];

    _topImage.clipsToBounds = YES;

    NSNumber *width = info[@"width"];
    NSNumber *height = info[@"heigth"];

    _topImage.frame = CGRectMake(0, 0, screenWidth, screenWidth / width.floatValue * height.floatValue);

//    _topImage.contentMode =  UIViewContentModeScaleAspectFill;
//    _topImage.contentMode = UIViewContentModeScaleToFill;

//    [_topImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(screenWidth / width.floatValue * height.floatValue);
//    }];
    
//    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo((screenWidth / width.floatValue * height.floatValue )+ 100*Height_ato);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(5 * Height_ato);
//    }];
    
    _titilLabel.text = [LWUtil getString:info[@"post_name"] andDefaultStr:@""];
    
    NSString *nameStr = [LWUtil getString:info[@"post_name"] andDefaultStr:@""];;
    NSDictionary *dic = @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18]};
    CGRect rect = [nameStr boundingRectWithSize:CGSizeMake(screenWidth - 50, 10000)
										options:NSStringDrawingUsesLineFragmentOrigin
									 attributes:dic
										context:nil];
    _titilLabel.frame = CGRectMake(25, (screenWidth / width.floatValue * height.floatValue)+25*Height_ato, screenWidth - 50, rect.size.height);
    _priceLabel.frame = CGRectMake(0, (screenWidth / width.floatValue * height.floatValue)+37*Height_ato + rect.size.height, screenWidth, 28);

    
    shadowView.frame = CGRectMake(0, (screenWidth / width.floatValue * height.floatValue)+37*Height_ato + rect.size.height + 45, screenWidth, 5);
    NSString *str = [LWUtil getString:info[@"post_price"] andDefaultStr:@""];
    if (str.length > 0) {
        _priceLabel.text = [NSString stringWithFormat:@"￥%@",str];
    } else {
        _priceLabel.text = @"报价详询商家";
    }
}

- (CGFloat)getHeightWithInfo:(id)info
{
    return 465 * Height_ato;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end


