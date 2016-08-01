//
//  WeddingHomePageStoryCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingHomePageStoryCell.h"
#import "UIImageView+WebCache.h"
@implementation UITableView(WeddingHomePageStoryCell)

- (WeddingHomePageStoryCell *)WeddingHomePageStoryCell{
    
    static NSString *CellIdentifier = @"WeddingHomePageStoryCell";
    
    WeddingHomePageStoryCell * cell = (WeddingHomePageStoryCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (WeddingHomePageStoryCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@implementation WeddingHomePageStoryCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textView.delegate = self;
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:rgba(221, 221, 221, 1)];
	self.textView.textColor = subTitleLableColor;
}

- (void)setStroy:(WTWeddingStory *)stroy
{
	_stroy = stroy;
	self.textView.text = [LWUtil getString:stroy.content andDefaultStr:@"我们的故事"];

	NSString *urlString = stroy.media.length > 0 ? stroy.media: stroy.path;
    [self.headImage mp_setImageWithURL:urlString placeholderImage:[LWUtil imageWithColor:[UIColor lightGrayColor]]];
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

@end
