//
//  WorksDetailCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WorksDetailCell.h"
#import <UIImageView+WebCache.h>
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#define youku @"http://player.youku.com/embed/"

@implementation UITableView (SupplerDetail)

- (WorksDetailCell *)WorksDetailCell
{
    static NSString *CellIdentifier = @"WorksDetailCell";
    
    WorksDetailCell * cell = (WorksDetailCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        cell = [[WorksDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
    
}
@end

@interface WorksDetailCell ()<UIWebViewDelegate>

@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIWebView *webVideo;
@end
@implementation WorksDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
        make.bottom.mas_equalTo(-7);
    }];
}

- (void)setInfo:(id)info
{
    NSString *urlStr;
        if (_type == 1) {
            urlStr = info[@"src"];
        } else {
			urlStr = info[@"pic"];
			_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
            [_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:info[@"pic"]]
											 andPlaceholder:nil];
        }
    __weak UIImageView *top = _topImage;
    _topImage.contentMode = UIViewContentModeCenter;
	_topImage.backgroundColor = [LWUtil colorWithHexString:@"ecedf0"];
    [_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:urlStr]
								   placeholderImage:nil
											options:SDWebImageRetryFailed progress:nil
										  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
											  if (image != nil) {
												  top.contentMode =  UIViewContentModeScaleToFill;
											  }
										  }
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];
    
    _topImage.clipsToBounds = YES;

}
- (void)initWebViewWithInfo:(NSString *)info
{
    if (self.webVideo) {
        return;
    }
    self.webVideo = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-10)];
    self.webVideo.delegate = self;
    NSString *url;
    if ([info isNotEmptyCtg]) {
        url = [NSString stringWithFormat:@"%@%@",youku, info];
    } else {
        //url = @"http://player.youku.com/embed/XOTM5OTcxNTgw";
    }
    if (info) {
        [self.webVideo loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    
    _webVideo.scalesPageToFit = NO;
    _webVideo.scrollView.pagingEnabled = NO;
    _webVideo.scrollView.backgroundColor = [UIColor colorWithRed:230 green:230 blue:230 alpha:0.8];
    _webVideo.scrollView.scrollEnabled=NO;
    _webVideo.scrollView.scrollsToTop=NO;
    [self.contentView addSubview:_webVideo];
}
- (CGFloat)getHeightWithInfo:(id)info
{
    NSString *height = info[@"height"];
    NSString *width = info[@"width"];
    return screenWidth / width.intValue * height.intValue;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
