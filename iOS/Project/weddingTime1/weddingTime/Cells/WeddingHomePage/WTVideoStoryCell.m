//
//  WTWebViewCell.m
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "WTVideoStoryCell.h"
#import "WTWeddingStory.h"
#import "UIImageView+SD.h"
@interface WTVideoStoryCell () <UIWebViewDelegate>
@property (nonatomic, copy) NSURL *videoURL;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@end

@implementation WTVideoStoryCell
- (void)awakeFromNib {

}
+ (WTVideoStoryCell *)webCellWithTableView:(UITableView *)tableView{
	WTVideoStoryCell * cell = (WTVideoStoryCell *)[tableView dequeueReusableCellWithIdentifier:@"WTVideoStoryCell"];
	if (nil == cell) {
		cell = (WTVideoStoryCell *)[[NSBundle mainBundle] loadNibNamed:@"WTVideoStoryCell" owner:self options:nil][0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)setStory:(WTWeddingStory *)story
{
    _story = story;
	NSString *urlString = story.media.length > 0 ? story.media : story.path ;
	self.videoURL = [NSURL URLWithString:urlString];

	[self.videoImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlString,@"?vframe/png/offset/0"]]];
}

- (IBAction)playVideo:(UIButton *)sender
{
	if([self.delegate respondsToSelector:@selector(WTVideoStoryCellDidSelected:andVideoURL:)]){
		[self.delegate WTVideoStoryCellDidSelected:self andVideoURL:self.videoURL];
	}
}

@end
