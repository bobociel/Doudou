//
//  SendFriendRequestViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "SendFriendRequestViewController.h"
#import "PlaceholderTextView.h"
#import "BaseFunction.h"
#import "Constants.h"

@interface SendFriendRequestViewController ()<UITextViewDelegate>

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *requestCommentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentTextRemainTextView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@end

@implementation SendFriendRequestViewController

static const NSUInteger MAX_TEXT_NUM = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    _viewContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [_scrollView addSubview:_viewContainer];
    [BaseFunction setBorderWidth:0.5 color:HintTextColor view:_requestCommentTextView.superview];
    _requestCommentTextView.keyboardType = UIKeyboardTypeASCIICapable;
    _requestCommentTextView.returnKeyType = UIReturnKeyDone;
    _requestCommentTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender {
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [_requestCommentTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *content = textView.text;
    if(content.length <= 60) {
        _commentTextRemainTextView.text = [NSString stringWithFormat:@"%ld",MAX_TEXT_NUM - content.length];
        _commentTextRemainTextView.textColor = ColorWithRGB(158, 158, 158);
    } else {
        _commentTextRemainTextView.text = [NSString stringWithFormat:@"%ld",content.length - MAX_TEXT_NUM];
        _commentTextRemainTextView.textColor = [UIColor redColor];
    }
}

@end
