//
//  ChargeSuccessViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ChargeSuccessViewController.h"

@interface ChargeSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *amountAndPhoneLabel;
@end

@implementation ChargeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mobile Recharge";
    [self addCompleteButton];
    _amountAndPhoneLabel.text = [NSString stringWithFormat:@"%@,Recharge amount %@ yuan",_phoneNum,_money];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addCompleteButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FontNeveLightWithSize(16.0);
    [button sizeToFit];
    [button addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chargeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = chargeButtonItem;
}

- (void) complete {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
