//
//  ReportViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/13.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ReportViewController.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "PlaceholderTextView.h"

@interface ReportViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate> {
    NSArray *_titleArray;
    NSInteger _selectedIndex;
    UIButton *_submitButton;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *commentReason;
- (IBAction)hideKeyboard:(id)sender;

@end

@implementation ReportViewController

static NSString *CELL_IDENTIFIER = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Report";
    [self dontShowBackButtonTitle];
    [self addSubmitButton];
    
    _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_contentView.frame));
    _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    [_scrollView addSubview:_contentView];
    _selectedIndex = -1;
    _titleArray = @[@"Waste marketing",@"Pornographic",@"Sensitive information",@"Harass me",@"False information",@"Other reason"];
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    _table.scrollEnabled = NO;
    _commentReason.placeholder = @"Please fill in, to ensure that the report can be accepted(optional)";
    _commentReason.font = FontNeveLightWithSize(14.0);
    _commentReason.returnKeyType = UIReturnKeyDone;
    _commentReason.delegate = self;
    _commentReason.placeholderFont = FontNeveLightWithSize(14.0);
    [BaseFunction setCornerRadius:3.0 view:_commentReason];
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:_commentReason];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addSubmitButton {
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [_submitButton setTitleColor:ColorWithRGB(171, 222, 255) forState:UIControlStateNormal];
    _submitButton.titleLabel.font = FontNeveLightWithSize(16.0);
    [_submitButton addTarget:self action:@selector(requestReport) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton sizeToFit];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:_submitButton];
    self.navigationItem.rightBarButtonItem = barButton;
}

#pragma mark - net work
- (void) requestReport {
    if(_selectedIndex == -1) {
        return;
    }
    
    [self showHUDWithText:@"Reporting..."];
    NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSString *cd_id = @"";
    if(_postId != 0) {
        cd_id = [NSString stringWithFormat:@"%ld",_postId];
    }
    
    NSUInteger reportType = _selectedIndex;
    
    NSString *cmd_id = @"";
    if(_commentId != 0) {
        cmd_id = [NSString stringWithFormat:@"%ld",_commentId];
    }
    
    NSString *reportComment = _commentReason.text;
    
    NSString *r_ci_id = @"";
    if(_userId != 0) {
        r_ci_id = [NSString stringWithFormat:@"%ld",_userId];
    }
    
    [HttpManager requestReport:uid cd_id:cd_id reportType:[NSString stringWithFormat:@"%ld",reportType] reportComment:reportComment aki_id:@"" cmd_id:cmd_id  r_ci_id:r_ci_id success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [self showHUDDoneWithText:@"Report Success"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHUDNetError];
    }];
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [tableView reloadData];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - uitableview datasource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.font = FontNeveLightWithSize(16.0);
    if(_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - uitextview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [_commentReason resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)hideKeyboard:(id)sender {
    [_commentReason resignFirstResponder];
}

@end
