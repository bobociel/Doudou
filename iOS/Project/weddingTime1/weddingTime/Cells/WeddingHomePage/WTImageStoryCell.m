//
//  WeddingHomePageStoryCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTImageStoryCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"

@implementation UITableView(WeddingHomePageStoryCell)

- (WTImageStoryCell *)WeddingHomePageStoryCell{
    
    static NSString *CellIdentifier = @"WTImageStoryCell";
    
    WTImageStoryCell * cell = (WTImageStoryCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {

        [self registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = (WTImageStoryCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@implementation WTImageStoryCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textView.delegate = self;
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:rgba(221, 221, 221, 1)];
	self.textView.textColor = subTitleLableColor;
}

- (void)setStroy:(WTWeddingStory *)stroy
{
	_stroy = stroy;
	self.textView.text = [LWUtil getString:stroy.content andDefaultStr:@""];

	NSString *urlString = stroy.media.length > 0 ? stroy.media: stroy.path;
	urlString = [urlString stringByAppendingString:@"?imageView2/1/w/600/h/600"];
	[self.headImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:urlString]
								  placeholderImage:nil
										   options:SDWebImageRetryFailed
										  progress:nil
										 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
											 self.headImage.contentMode = UIViewContentModeScaleAspectFill;
										 }
						  ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										  Diameter:40];
}

- (void)setIsEdit:(BOOL)isEdit
{
	_isEdit = isEdit;
	_deleteControl.hidden = isEdit;
	[UIView animateWithDuration:0.2 animations:^{
		_textViewRight.constant = isEdit ?  8 : 40 ;
		[self.contentView layoutIfNeeded];
	}completion:^(BOOL finished) {

	}];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if([self.delegate respondsToSelector:@selector(WeddingHomePageStringDidBeignEdit:)]){
		[self.delegate WeddingHomePageStringDidBeignEdit:self];
	}
}

- (void)textViewDidChange:(UITextView *)textView
{
	self.stroy.content = textView.text;
	//时时保存
	[PostDataService postWeddingHomeModifyStoryWithStory:self.stroy withBlock:^(NSDictionary *result, NSError *error) {

	}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if([text isEqualToString:@"\n"] )
	{
		[textView resignFirstResponder];
	}
	return YES;
}

- (IBAction)deleteAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(WTImageStoryCell:didSelectedDelete:)]){
		[self.delegate WTImageStoryCell:self didSelectedDelete:sender];
	}
}

@end
