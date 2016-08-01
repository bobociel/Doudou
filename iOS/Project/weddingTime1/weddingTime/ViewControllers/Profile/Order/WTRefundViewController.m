//
//  RefundViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTRefundViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#define kButtonHeight 44.0
@interface WTRefundViewController ()<UITextViewDelegate>

@end

@implementation WTRefundViewController
{
    UITextView *filed;
    UIButton *payButton;
    UILabel *placeLabel;
    TPKeyboardAvoidingScrollView *scrollView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.clipsToBounds=NO;
    self.view.backgroundColor      = [UIColor whiteColor];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    [self initView];
}

- (void)initView
{
    
    
    self.title = @"申请退款";
    filed = [[UITextView alloc] initWithFrame:CGRectMake(10 * Width_ato, 0 * Height_ato, screenWidth - 20 * Width_ato, 100)];
    filed.font = [WeddingTimeAppInfoManager fontWithSize:16];
    filed.textColor = rgba(102, 102, 102, 1);
    
    filed.delegate = self;
    
    
//    filed.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    filed.placeholder = @"输入退款理由";
    [scrollView addSubview:filed];
    
    
    placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 * Width_ato, 10 * Height_ato, screenWidth - 15, 20)];
    placeLabel.enabled = NO;
    placeLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    placeLabel.textColor = rgba(151, 151, 151, 1);
    placeLabel.text = @"请输入退款理由...";
    [scrollView addSubview:placeLabel];
    
//    filed.delegate =self;
//    filed.adjustsFontSizeToFitWidth = NO;//设置为YES时文本会自动缩小以适应文本窗口大小。默认是保持原来大小，而让长文本滚动
//    filed.clearButtonMode = UITextFieldViewModeAlways;
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
//    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
//    tapGestureRecognizer.cancelsTouchesInView = NO;
//    //将触摸事件添加到当前view
//    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self addPayButton];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        placeLabel.text = @"请输入退款理由...";
        [payButton setBackgroundColor:rgba(210, 210, 210, 1)];
    }else{
        placeLabel.text = @"";
        [payButton setBackgroundColor:WeddingTimeBaseColor];
    }
    
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (textField.text.length > 0) {
//        [payButton setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
//    }
//    return YES;
//}

- (void)addPayButton
{
    payButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    payButton.frame = CGRectMake(0, screenHeight - 50 * Height_ato - 64, screenWidth, 50 * Height_ato);
    [self.view addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(kButtonHeight);
    }];
    [payButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [payButton setTitleColor:WHITE forState:UIControlStateNormal];
    [payButton setTitle:@"提交" forState:UIControlStateNormal];
    payButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    [payButton setBackgroundColor:rgba(210, 210, 210, 1)];
}

- (void)buttonAction
{
    [self.delegate refundWithStr:filed.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [filed resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
