//
//  WTDeskCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/24.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDeskCell.h"
#define kMaxTitle   30
#define kMaxContent 200
@implementation WTDeskCell

- (void)awakeFromNib {
	[super awakeFromNib];
	_descLabel.font = DefaultFont20;
	_descLabel.adjustsFontSizeToFitWidth = YES;

	_titleTextField.font = DefaultFont18;
	_titleTextField.delegate = self;
	_titleTextField.adjustsFontSizeToFitWidth = YES;
	_titleTextField.returnKeyType = UIReturnKeyDone;
	[_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

	_contentTextView.delegate = self;
	_contentTextView.returnKeyType = UIReturnKeyDone;
	self.deleteControl.hidden = YES;
}

- (void)setDescInfo:(WTWeddingDesk *)descInfo
{
	_descInfo = descInfo;
	_descLabel.text = [LWUtil getString:_descInfo.sort andDefaultStr:@""];
	_titleTextField.text = [LWUtil getString:_descInfo.name andDefaultStr:@""];
	_contentTextView.text = [LWUtil getString:_descInfo.member andDefaultStr:@""];
	_noteLabel.hidden = [LWUtil getString:_descInfo.member andDefaultStr:@""].length > 0;
}

- (void)setCanDelete:(BOOL)canDelete
{
	_canDelete = canDelete;
	_deleteControl.hidden = !canDelete;
}

#pragma mark - Delegate
- (IBAction)deleteAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(WTDeskCell:didSelectedDelete:)]){
		[self.delegate WTDeskCell:self didSelectedDelete:sender];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	_noteLabel.hidden = YES;
	if([self.delegate respondsToSelector:@selector(WTDeskCellDidBeignEdit:)]){
		[self.delegate WTDeskCellDidBeignEdit:self];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if([self.delegate respondsToSelector:@selector(WTDeskCellDidBeignEdit:)]){
		[self.delegate WTDeskCellDidBeignEdit:self];
	}
}

- (void)textFieldDidChange:(UITextField *)textField
{
	if(textField.markedTextRange == nil){
		_descInfo.name = [textField.text substringToIndex:MIN(textField.text.length, kMaxTitle)];
		textField.text = _descInfo.name;
	}
}

- (void)textViewDidChange:(UITextView *)textView
{
	_noteLabel.hidden = textView.text.length != 0;
	if(textView.markedTextRange == nil){
		_descInfo.member = [textView.text substringToIndex:MIN(textView.text.length, kMaxContent)];
		textView.text = _descInfo.member;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if([text isEqualToString:@"\n"]){
		[textView resignFirstResponder];
	}
	return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView (WTDeskCell)

- (WTDeskCell *)WTDeskCell
{
	static NSString *CellIdentifier = @"WTDeskCell";

	WTDeskCell * cell = (WTDeskCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTDeskCell *) [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = rgba(247, 247, 247, 1);
	}
	return cell;
}
@end