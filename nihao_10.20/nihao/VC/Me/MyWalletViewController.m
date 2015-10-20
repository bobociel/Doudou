//
//  MyWalletViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "MyWalletViewController.h"

@interface MyWalletViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userWalletLabel;
- (IBAction)recharge:(id)sender;
//金额导出
- (IBAction)withDraw:(id)sender;
- (IBAction)viewBankCard:(id)sender;
- (IBAction)setPaymentPassword:(id)sender;
//银行卡数量
@property (weak, nonatomic) IBOutlet UILabel *bankNumLabel;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Wallet";
    [self dontShowBackButtonTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click events
- (IBAction)recharge:(id)sender {
}

- (IBAction)withDraw:(id)sender {
}

- (IBAction)viewBankCard:(id)sender {
}

- (IBAction)setPaymentPassword:(id)sender {
}
@end
