//
//  WTContentCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/17.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTContentCell.h"
#define kMaxHeight 200
@implementation WTContentCell

- (void)awakeFromNib {
    [super awakeFromNib];

	_contentTV.delegate = self;
	_contentTV.font = DefaultFont12;
	_contentTV.scrollEnabled = NO;
	_contentTV.editable = NO;
	_contentTV.tintColor = WeddingTimeBaseColor;
	_contentTV.textColor = rgba(170, 170, 170, 1);
	_contentTV.textAlignment = NSTextAlignmentLeft;
	_contentTV.dataDetectorTypes = UIDataDetectorTypeLink;
	[_showBtn setTitle:@"展开全部" forState:UIControlStateNormal];
	[_showBtn setTitle:@"收回全部" forState:UIControlStateSelected];
}

- (void)setContent:(NSString *)content
{
	_content = content;
	_contentTV.text = content;

	CGSize descSize = [LWUtil textViewSizeWithTextView:_contentTV andWidth:(screenWidth - 20 * 2)];
	_showBtnHeight.constant = descSize.height > kMaxHeight ? 30 : 0 ;
	_contentTVHeight.constant = _showAll ? ceil(descSize.height) : kMaxHeight ;
}

+ (CGFloat)getHeightWith:(NSString *)content isShowAll:(BOOL)showAll
{
	
	return 300;
}

- (IBAction)moreAction:(UIButton *)sender
{
	if([self.delegate respondsToSelector:@selector(WTContentCell:didSelectedMore:)])
	{
		sender.selected = !sender.selected;
		[self.delegate WTContentCell:self didSelectedMore:sender];
	}
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
	NSString *openURLStr = [textView.text substringWithRange:characterRange];
	if(![openURLStr hasPrefix:@"http://"] && ![openURLStr hasPrefix:@"https://"]){
		openURLStr = [NSString stringWithFormat:@"http://%@",openURLStr];
	}

	if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:openURLStr]])
	{
		[WTProgressHUD ShowTextHUD:@"网址不可用" showInView:KEY_WINDOW afterDelay:1];
	}else
	{
		if([self.delegate respondsToSelector:@selector(WTContentCell:didSelectedLink:)])
		{
			[self.delegate WTContentCell:self didSelectedLink:[NSURL URLWithString:openURLStr]];
		}
	}
	return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView (WTContentCell)

- (WTContentCell *)WTContentCell
{
	static NSString *CellIdentifier = @"WTContentCell";
	
	WTContentCell * cell = (WTContentCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTContentCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
	}
	return cell;
}
@end
