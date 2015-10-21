//
//  TranslateViewController.m
//  nihao
//
//  Created by HelloWorld on 6/12/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TranslateViewController.h"
#import "PlaceholderTextView.h"
#import "HttpManager.h"
#import "BaseFunction.h"

@interface TranslateViewController ()<UITextViewDelegate> {
    //翻译源类型
    NSString *_from;
    //翻译目标类型
    NSString *_to;
}

- (IBAction)changeTranslateLanguage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *languageFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageToLabel;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *translateTextView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)dismissKeybord:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *goTranslateButton;
- (IBAction)goTranslate:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *translateSourceView;
@property (weak, nonatomic) IBOutlet UITextView *translateSource;
- (IBAction)clearTranslateResult:(id)sender;
//翻译结果父容器
@property (weak, nonatomic) IBOutlet UIView *translateResultView;
@property (weak, nonatomic) IBOutlet UILabel *translateResult;
- (IBAction)copyTranslateResult:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *pinyinSource;
@property (weak, nonatomic) IBOutlet UILabel *pinyinResult;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateSourceTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateSourceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateResultButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateResultViewHeightConstraint;

@end

NS_ENUM(NSUInteger, BUTTON_STATE) {
    BUTTON_STATE_CLICKABLE = 0,
    BUTTON_STATE_UNCLICKABLE
};

@implementation TranslateViewController

static NSString *const EN = @"en";
static NSString *const ZH = @"zh";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Translate";
    [self dontShowBackButtonTitle];
    [self initView];
    _from = EN;
    _to = ZH;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initView {
    _translateTextView.placeholder = @"Translate here";
    _translateTextView.placeholderFont = FontNeveLightWithSize(14.0);
    _translateTextView.placeholderColor = ColorWithRGB(210, 210, 210);
    _translateTextView.delegate = self;
    _translateSource.delegate = self;
    _translateTextView.enablesReturnKeyAutomatically = YES;
    _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    _containerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    [_scrollView addSubview:_containerView];
    _goTranslateButton.userInteractionEnabled = NO;
}

#pragma mark - click events
- (IBAction)changeTranslateLanguage:(id)sender {
    if([_from isEqualToString:EN]) {
        _from = ZH;
        _to = EN;
        _languageFromLabel.text = @"Chinese";
        _languageToLabel.text = @"English";
    } else {
        _from = EN;
        _to = ZH;
        _languageFromLabel.text = @"English";
        _languageToLabel.text = @"Chinese";
    }
}

- (IBAction)dismissKeybord:(id)sender {
    [_translateTextView resignFirstResponder];
}

- (IBAction)goTranslate:(id)sender {
    NSString *content = [_translateTextView isFirstResponder] ? _translateTextView.text : _translateSource.text;
    if(IsStringEmpty(content)) {
        return;
    }
    [_translateTextView resignFirstResponder];
    [_translateSource resignFirstResponder];
    [self showHUDWithText:@"Translating..."];
    [HttpManager translateContent:content from:_from to:_to apiKey:BAIDU_TRANSLATE_APIKEY success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"errNum"] integerValue] == 0) {
            NSDictionary *result = responseObject[@"retData"];
            NSArray *transResultArray = result[@"trans_result"];
            NSDictionary *transResult = transResultArray[0];
            NSString *src = transResult[@"src"];
            NSString *dst = transResult[@"dst"];
            [self showTranslateResult:src dst:dst];
            [self hideHud];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            //如果翻译后的内容显示超过了scrollview的滚动区域，则需要将滚动区域扩大
            CGFloat maxY = CGRectGetMaxY(_translateResultView.frame);
            if(maxY > SCREEN_HEIGHT) {
                _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, maxY);
            } else {
                _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
            }
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDNetError];
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if(textView == _translateTextView) {
        NSString *content = textView.text;
        if(IsStringEmpty(content)) {
            [self setButtonState:BUTTON_STATE_UNCLICKABLE];
        } else {
            [self setButtonState:BUTTON_STATE_CLICKABLE];
        }
    } else {
        CGFloat fixedWidth = textView.frame.size.width;
        CGFloat orginHeight = textView.frame.size.height;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        _translateSourceViewHeightConstraint.constant = _translateSourceViewHeightConstraint.constant + CGRectGetHeight(newFrame) - orginHeight;
        _translateSourceTextViewHeightConstraint.constant = CGRectGetHeight(newFrame);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self goTranslate:nil];
        return YES;
    }
    return YES;
}

#pragma mark - click events
- (IBAction)clearTranslateResult:(id)sender {
    [self clearTranslateResult];
}

- (IBAction)copyTranslateResult:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _translateResult.text;
    [self showHUDDoneWithText:@"Translation Copied"];
}

#pragma mark - ui交互

/**
 *  显示翻译结果
 *
 *  @param src 需要翻译的字符串
 *  @param dst 翻译结果
 */
- (void) showTranslateResult : (NSString *) src dst : (NSString *) dst {
    _goTranslateButton.hidden = YES;
    _translateTextView.hidden = YES;
    _translateSourceView.hidden = NO;
    _translateResultView.hidden = NO;
    [self clearSourcePinyin];
    [self clearResultPinyin];
    _translateSource.text = src;
    CGSize maxSize = CGSizeMake(CGRectGetWidth(_translateResult.frame), 9999);
    if([_from isEqualToString:ZH]) {
        [self setSourcePinyin:src];
    } else {
        [self setResultPinyin:dst];
    }
    [self textViewDidChange:_translateSource];
    CGSize dstSize = [BaseFunction labelSizeWithText:dst font:FontNeveLightWithSize(14.0) constrainedToSize:maxSize];
    CGRect dstFrame = _translateResult.frame;
    _translateResult.frame = CGRectMake(CGRectGetMinX(dstFrame), CGRectGetMinY(dstFrame), CGRectGetWidth(dstFrame), dstSize.height);
    _translateResult.text = dst;
    //更新翻译结果view的高度
    _translateResultViewHeightConstraint.constant = _translateResultViewHeightConstraint.constant + (dstSize.height - CGRectGetHeight(dstFrame));
}

/**
 *  清除翻译结果
 */
- (void) clearTranslateResult {
    _goTranslateButton.hidden = NO;
    _translateTextView.hidden = NO;
    _translateSourceView.hidden = YES;
    _translateResultView.hidden = YES;
    _translateTextView.text = @"";
    if([_translateSource isFirstResponder]) {
        [_translateSource resignFirstResponder];
    }
    [self setButtonState:BUTTON_STATE_UNCLICKABLE];
    [self clearResultPinyin];
    [self clearSourcePinyin];
}

- (void) setSourcePinyin : (NSString *) src{
    CGSize maxSize = CGSizeMake(CGRectGetWidth(_translateResult.frame), 9999);
    NSString * pinyin = [BaseFunction chineseToPinyin:src];
    CGSize pinyinLabelSize = [BaseFunction labelSizeWithText:pinyin font:FontNeveLightWithSize(14.0) constrainedToSize:maxSize];
    _translateSourceViewHeightConstraint.constant = _translateSourceViewHeightConstraint.constant + pinyinLabelSize.height;
    _pinyinSource.frame = CGRectMake(CGRectGetMinX(_pinyinSource.frame), CGRectGetMinY(_pinyinSource.frame), CGRectGetWidth(_pinyinSource.frame), pinyinLabelSize.height);
    _pinyinSource.text = pinyin;
}

- (void) clearSourcePinyin {
    _translateSourceViewHeightConstraint.constant = _translateSourceViewHeightConstraint.constant - CGRectGetHeight(_pinyinSource.frame);
    _pinyinSource.frame = CGRectMake(CGRectGetMinX(_pinyinSource.frame), CGRectGetMinY(_pinyinSource.frame), CGRectGetWidth(_pinyinSource.frame), 0);
    _pinyinSource.text = @"";
    [self textViewDidChange:_translateSource];
}

- (void) setResultPinyin : (NSString *) dst {
    NSString *pinyin = [BaseFunction chineseToPinyin:dst];
    CGSize maxSize = CGSizeMake(CGRectGetWidth(_translateResult.frame), 9999);
    CGSize pinyinLabelSize = [BaseFunction labelSizeWithText:pinyin font:FontNeveLightWithSize(14.0) constrainedToSize:maxSize];
    _pinyinResult.frame = CGRectMake(CGRectGetMinX(_pinyinResult.frame), CGRectGetMinY(_pinyinResult.frame), CGRectGetWidth(_pinyinResult.frame), pinyinLabelSize.height);
    _pinyinResult.text = pinyin;
    _translateResultViewHeightConstraint.constant = _translateResultViewHeightConstraint.constant + pinyinLabelSize.height;
    _translateResultButtonConstraint.constant = pinyinLabelSize.height;
}

- (void) clearResultPinyin {
    _translateResultButtonConstraint.constant = _translateResultButtonConstraint.constant - CGRectGetHeight(_pinyinResult.frame);
    _translateResultViewHeightConstraint.constant = _translateResultViewHeightConstraint.constant - CGRectGetHeight(_pinyinResult.frame);
    _pinyinResult.frame = CGRectMake(CGRectGetMinX(_pinyinResult.frame), CGRectGetMinY(_pinyinResult.frame), CGRectGetWidth(_pinyinResult.frame), 0);
    _pinyinResult.text = @"";
}

/**
 *  设置按钮的状态
 *
 *  @param state 可点击BUTTON_STATE_CLICKABLE or 不可点击BUTTON_STATE_UNCLICKABLE
 */
- (void) setButtonState : (int) state {
    if(state == BUTTON_STATE_CLICKABLE) {
        [_goTranslateButton setBackgroundColor:BUTTON_ENABLED_COLOR];
        _goTranslateButton.userInteractionEnabled = YES;
    } else {
        [_goTranslateButton setBackgroundColor:BUTTON_DISABLED_COLOR];
        _goTranslateButton.userInteractionEnabled = NO;
    }
}

/**
 *  将中文转拼音
 *
 *  @param str 中文
 *
 *  @return 中文拼音
 */
- (NSString *) chineseToPinyin : (NSString *) str {
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (__bridge CFStringRef)str);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    return [NSString stringWithFormat:@"%@",string];
}

@end
