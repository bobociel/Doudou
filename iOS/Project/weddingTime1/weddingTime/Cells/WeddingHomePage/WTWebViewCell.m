//
//  WTWebViewCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTWebViewCell.h"
#import "WTWeddingStory.h"
#import "UIImageView+SD.h"
#define kFromString @"http://7xk6d2.media1.z0.glb.clouddn.com/"
#define kToString		 @"http://video.lovewith.me/"
@interface WTWebViewCell ()
@property (nonatomic, copy) NSURL *videoURL;
@end

@implementation WTWebViewCell
+ (WTWebViewCell *)webCellWithTableView:(UITableView *)tableView{
	WTWebViewCell * cell = (WTWebViewCell *)[tableView dequeueReusableCellWithIdentifier:@"WTWebViewCell"];
	if (nil == cell) {
		cell = (WTWebViewCell *)[[NSBundle mainBundle] loadNibNamed:@"WTWebViewCell" owner:self options:nil][0];
	}
	return cell;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setStory:(WTWeddingStory *)story
{
    _story = story;
	NSString *urlString = story.media.length > 0 ? story.media : story.path ;
	urlString = [[urlString stringByReplacingOccurrencesOfString:kFromString withString:kToString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	self.videoURL = [NSURL URLWithString:urlString];

	[self.videoImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlString,@"?vframe/png/offset/0"]]];
}

- (IBAction)playVideo:(UIButton *)sender
{
	if([self.delegate respondsToSelector:@selector(WTWebCellDidSelected:andVideoURL:)]){
		[self.delegate WTWebCellDidSelected:self andVideoURL:self.videoURL];
	}
}


@end
