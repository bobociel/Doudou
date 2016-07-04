//
//  WTDetailCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTImageDetailCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
@implementation WTImageDetailCell

- (void)awakeFromNib {
	self.contentView.backgroundColor = rgba(247, 247, 247, 1);
	_detailImageView.contentMode = UIViewContentModeScaleAspectFill;
	_videoImageView.hidden = YES;
	_videoBG.hidden = YES;
	_webView.hidden = YES;
	_webView.delegate = self;
	_webView.scalesPageToFit = NO;
	_webView.scrollView.pagingEnabled = NO;
	_webView.scrollView.backgroundColor = rgba(230, 230, 230, 0.8);
	_webView.scrollView.scrollEnabled = NO;
	_webView.scrollView.scrollsToTop = NO;
	_contentLabel.numberOfLines = 0;
	_contentLabel.font = DefaultFont14;
	_contentLabel.textColor = rgba(153, 153, 153, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCellWithPostImage:(WTPostImage *)postImage andVideoPath:(NSString *)path
{
	_postImage = postImage;
	BOOL isYKVideo = [[LWUtil getString:path andDefaultStr:@""] hasPrefix:youku];
	_webView.hidden = !(_postImage.is_video && isYKVideo);
	_videoBG.hidden = (!_postImage.is_video || isYKVideo);
	_videoImageView.hidden = (!_postImage.is_video || isYKVideo);
	_detailImageView.hidden = (_postImage.is_video && isYKVideo);

	_topViewHeight.constant = _postImage.height / _postImage.width * screenWidth;
	_bottomViewHeight.constant = [WTImageDetailCell sizeWithContent:_postImage.desc];
	_contentLabel.text = [LWUtil getString:_postImage.desc andDefaultStr:@""];
	NSString *URLStr = [NSString stringWithFormat:@"%@%@",_postImage.pic, _postImage.is_video ? @"" :kSmall600];
	[self setDetailImageViewWithURLStr:[URLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	if( postImage.is_video && isYKVideo){
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
	}
}

- (void)setCardImage:(WTWeddingCardImage *)cardImage
{
	_cardImage = cardImage;
	_webView.hidden = YES;
	_videoImageView.hidden = YES;
	_detailImageView.hidden = NO;
	_topViewHeight.constant = _cardImage.h / _cardImage.w * screenWidth;
	_bottomViewHeight.constant = 0;
	NSString *URLStr = [NSString stringWithFormat:@"%@%@",_cardImage.path,kSmall600];
	[self setDetailImageViewWithURLStr:URLStr];
}

- (void)setHotelInfo:(NSDictionary *)hotelInfo
{
	_hotelInfo = hotelInfo;
	self.bottomViewHeight.constant = 0;
	self.topViewHeight.constant = 350 * Height_ato;
	NSString *URLStr = [NSString stringWithFormat:@"%@%@",hotelInfo[@"src"],kSmall600];
	[self setDetailImageViewWithURLStr:URLStr];
}

- (void)setDetailImageViewWithURLStr:(NSString *)urlStr
{
	[_detailImageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:urlStr]
										  placeholderImage:nil
												   options:SDWebImageRetryFailed
												  progress:nil
												 completed:nil
									  ProgressPrimaryColor:WeddingTimeBaseColor
									ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
												  Diameter:50];
}

+ (CGFloat)cellHeight:(NSObject *)object
{
	CGFloat cellHeight = 350 * Height_ato;
	if([object isKindOfClass:[WTPostImage class]]){
		WTPostImage *post = (WTPostImage *)object;
		cellHeight = post.height / post.width * screenWidth + [self sizeWithContent:post.desc];
	}else if([object isKindOfClass:[WTWeddingCardImage class]]){
		WTWeddingCardImage *post = (WTWeddingCardImage *)object;
		cellHeight = post.h / post.w * screenWidth;
	}
	return cellHeight + 6.0 + 0.5;
}

+ (CGFloat)sizeWithContent:(NSString *)content
{
	CGSize size = CGSizeMake(0, 0);
	if([content isNotEmptyCtg]){
		size = [content sizeForFont:DefaultFont14 size:CGSizeMake(screenWidth-40, MAXFLOAT) mode:NSLineBreakByWordWrapping];
	}
	return size.height == 0 ? 0 : (ceil(size.height) + 40);
}

#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

@end

@implementation UITableView (WTImageDetailCell)

- (WTImageDetailCell *)WTImageDetailCell
{
	static NSString *CellIdentifier = @"WTImageDetailCell";

	WTImageDetailCell *cell = (WTImageDetailCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTImageDetailCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = rgba(247, 247, 247, 1);
	}
	return cell;
}

@end
