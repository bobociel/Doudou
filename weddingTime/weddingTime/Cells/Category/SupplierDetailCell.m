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
        cell = [[SupplierDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
@end

@interface SupplierDetailCell ()
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UILabel *titilLabel;
@property (nonatomic, strong) UIView *shadowView;
@end
@implementation SupplierDetailCell
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
	_titilLabel.numberOfLines = 0;
    _titilLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titilLabel];
    
    self.shadowView = [UIView new];
    _shadowView.backgroundColor = rgba(247, 247, 247, 1);
    [self.contentView addSubview:_shadowView];
}

- (void)setPost:(WTSupplierPost *)post
{
	_post = post;
	_topImage.frame = CGRectMake(0, 0, screenWidth, screenWidth / post.width * post.heigth);
	_topImage.clipsToBounds = YES;
	_topImage.contentMode = UIViewContentModeScaleToFill;
	_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];

	NSString *urlStr = [NSString stringWithFormat:@"%@%@",post.post_pic,kSmall600];
	[_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:urlStr]
								   placeholderImage:nil
											options:SDWebImageRetryFailed
										   progress:nil
										  completed:nil
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];

	_titilLabel.text = post.post_name;

	CGRect rect = [post.post_name boundingRectWithSize:CGSizeMake(screenWidth - 50, 10000)
										options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
									 attributes:@{NSFontAttributeName:DefaultFont18}
										context:nil];
	_titilLabel.frame = CGRectMake(25, (screenWidth / post.width * post.heigth) + 15 , screenWidth - 50, ceil(rect.size.height) );
	_shadowView.frame = CGRectMake(0, (screenWidth / post.width * post.heigth) + ceil(rect.size.height) + 30, screenWidth, 5);
}

- (CGFloat)getHeightWithInfo:(id)info
{
    return 450 * Height_ato;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


