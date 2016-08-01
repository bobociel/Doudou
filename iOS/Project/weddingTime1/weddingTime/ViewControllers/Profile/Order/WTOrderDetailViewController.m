//
//  OrderDetailViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTOrderDetailViewController.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "OrderDetailTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "CustomButton.h"
#import "OrderDetailTC.h"
#import "WTLocalDataManager.h"
#import "PostDataService.h"
#import "WTRefundViewController.h"
#import "AliPayManager.h"
#import "WTSupplierViewController.h"
#define kButtonHeight 44.0
@interface WTOrderDetailViewController ()<UITableViewDataSource, UITableViewDelegate, WTAlertViewDelegate, RefundDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation WTOrderDetailViewController
{
    NSArray *strArray;
    NSDictionary *_result;
    UILabel *stateLabel;
    UIButton *stateButton;
    UIButton *payButton;
    NSNumber *childNum;
    NSString *child_id;
    NSString *reason;
    NSString *telNum;
    NSDictionary *child_result;
    OrderDetail *order;
    WTAlertView *alert_payed;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];
    [WeddingTimeAppInfoManager instance].curid_order_detail = nil;
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    [WeddingTimeAppInfoManager instance].curid_order_detail = self.order_id;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self getCashOrderDetail:^{
        [self.dataTableView reloadData];
        [self hideLoadingView];
        self.dataTableView.tableHeaderView = [self getHeaderView];
    }];
    [self loadData];
    
    [self addNotify];
}

- (void)orderRefresh
{
    [alert_payed close];
    [self loadData];
}

- (void)getCashOrderDetail:(void (^)())finishBlock
{
    order = [OrderDetail getOrderDetailFromDB:self.order_id];
    self.array = [NSMutableArray array];
    if (order) {
        [_array addObject:order];
    }
    finishBlock();
}

- (void)doFinishGetOrderListResult:(NSDictionary *)result Block:(void(^)())block
{
    NSDictionary *dic = result[@"data"];
    NSArray *array = [dic objectForKey:@"child_orders"];
    NSString *jsonStr = [LWUtil toJSONString:array];
    NSMutableDictionary *nseDic;
    if (array.count > 0) {
        nseDic = [NSMutableDictionary dictionaryWithDictionary:array[0]];
    }
    child_result = [NSDictionary dictionaryWithDictionary:nseDic];
    NSMutableDictionary *dbDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dbDic setObject:jsonStr forKey:@"child_orders"];
    [OrderDetail insertOrderDetailToDB:dbDic];
    block();
}


- (void)refundWithStr:(NSString *)str
{
    reason = str;
    if (!reason) {
        reason = @"";
    }
    [PostDataService postOrderRefunChild_order_no:child_result[@"child_order_no"] reason:reason withBlock:^(NSDictionary *result, NSError *error) {
        if (error) {
            
            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil] showInView:self.view];
            return ;
        } else {
            [WTProgressHUD ShowTextHUD:@"请求发送成功" showInView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidPayed object:nil];
        }
    }];
}

- (void)initView
{
    self.dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    [self.view addSubview:self.dataTableView];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.tableHeaderView = [self getHeaderView];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self showLoadingView];
    [self addPayButton];
}
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
    
    payButton.hidden = YES;
    [payButton setTitleColor:WHITE forState:UIControlStateNormal];
    [payButton setTitle:@"支付定金" forState:UIControlStateNormal];
    payButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    [payButton setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
    [payButton addTarget:self action:@selector(payButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)payHandleState
{
    stateLabel.text = @"定金已支付";
    NSString *str = @"您已成功付款";
    alert_payed = [[WTAlertView alloc] initWithText:str centerImage:nil];
    alert_payed.buttonTitles = @[@"确定"];
    alert_payed.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidPayed object:nil];
    };
    
    [alert_payed show];
}

- (void)payFailHandleState
{
    NSString *str = @"付款失败，请稍候再试";
    WTAlertView *alert = [[WTAlertView alloc] initWithText:str centerImage:nil];
    alert.buttonTitles = @[@"取消"];
    alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
        [alert close];
    };
    [alert show];
}

- (void)payButtonAction
{
    if (_ordersate == orderstate_waitToPay) {
        [AliPayManager payOrderWithTrade_no:child_result[@"child_order_no"] Blcok:^(NSDictionary *result) {
            NSNumber *resultStatus = result[@"resultStatus"];
            if (resultStatus.integerValue == 6001 || resultStatus.integerValue == 6002 || resultStatus.integerValue == 4000) {
                [[NSNotificationCenter defaultCenter] postNotificationName:AlipayFailCallBack object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:AlipayCallBack object:nil];
            }
        }];
    }
}
- (void)changePayButtonStyle
{
    if (self.ordersate == orderstate_waitToGet) {
        [payButton setBackgroundColor:rgba(210, 210, 210, 1)];
        payButton.hidden = NO;
    } else
    if (self.ordersate == orderstate_waitToPay) {
        [payButton setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
        payButton.hidden = NO;
    } else
    if (self.ordersate == orderstate_isrefunding_nok) {
        [payButton setBackgroundColor:rgba(210, 210, 210, 1)];
        payButton.hidden = YES;
    } else
    if (self.ordersate == orderState_isrefunding_ok) {
        [payButton setBackgroundColor:[WeddingTimeAppInfoManager instance].baseColor];
        payButton.hidden = YES;
    } else {
        payButton.hidden = YES;
    }
    if (self.ordersate == orderstate_hasPayed) {
        [stateButton setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    } else {
        [stateButton setTitleColor:rgba(170, 170, 170, 1) forState:UIControlStateNormal];
    }
    if (self.ordersate == orderstate_refundDone) {
        OrderDetailTC *cell = (OrderDetailTC *)[self.dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        NSString *str = [LWUtil getString:child_result[@"total_fee"] andDefaultStr:@""];
        NSString *text = [NSString stringWithFormat:@"￥%@已退款",str];
        [cell setvaluelabeltext:text];
        [cell setValueLabelTextColor:rgba(204, 204, 204, 1)];
    } else
    if (self.ordersate == OrderState_hasCancael)
    {
        
        OrderDetailTC *cell = (OrderDetailTC *)[self.dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [cell setValueLabelTextColor:rgba(204, 204, 204, 1)];
        NSString *str = [LWUtil getString:child_result[@"total_fee"] andDefaultStr:@""];
        NSString *text = [NSString stringWithFormat:@"￥%@已取消",str];
        [cell setvaluelabeltext:text];
    } else if (self.ordersate == orderstate_hasPayed || self.ordersate == orderState_isrefunding_ok || self.ordersate == orderstate_isrefunding_nok)
    {
        OrderDetailTC *cell = (OrderDetailTC *)[self.dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [cell setValueLabelTextColor:[WeddingTimeAppInfoManager instance].baseColor];
        NSString *str = [LWUtil getString:child_result[@"total_fee"] andDefaultStr:@""];
        NSString *text = [NSString stringWithFormat:@"%@%@已支付", @"￥", str];
        [cell setvaluelabeltext:text];
    }
    else {
        OrderDetailTC *cell = (OrderDetailTC *)[self.dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [cell setValueLabelTextColor:[WeddingTimeAppInfoManager instance].baseColor];
        NSString *str = [LWUtil getString:child_result[@"total_fee"] andDefaultStr:@""];
         NSString *text = [NSString stringWithFormat:@"%@%@", @"￥", str];
        [cell setvaluelabeltext:text];
    }
}

- (void)jumpToSupplierDetail
{
    WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
    supplier.supplier_id = _result[@"supplier_user_id"];
    [self.navigationController pushViewController:supplier animated:YES];
}

- (UIView *)getHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 337 * Height_ato - 64)];
    view.backgroundColor = WHITE;
    UIImageView *avatarImage = [UIImageView new];
    avatarImage.layer.cornerRadius = 40 * Width_ato;
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:order.supplier_logo] placeholderImage:[UIImage imageNamed:@"supplier"]];//todo
    avatarImage.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToSupplierDetail)];
    avatarImage.userInteractionEnabled = YES;
    [avatarImage addGestureRecognizer:tap];
    [view addSubview:avatarImage];
    int height;
    if (84 * Height_ato < 64) {
        height = 64;
    } else {
        height = 84 * Height_ato;
    }
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height - 64);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(80 * Width_ato, 80 * Width_ato));
    }];
    
    stateLabel = [UILabel new];
    stateLabel.textColor = rgba(51, 51, 51, 1);
    stateLabel.textAlignment = NSTextAlignmentCenter;
    stateLabel.font = [UIFont boldSystemFontOfSize:18];
    [view addSubview:stateLabel];
    [stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height+110 * Height_ato - 64);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(20 * Height_ato);
    }];
    
    stateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    stateButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:13];
    [stateButton setTitleColor:rgba(170, 170, 170, 1) forState:UIControlStateNormal];
    [view addSubview:stateButton];
    [stateButton addTarget:self action:@selector(stateButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [stateButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(height+130 * Height_ato - 64);
//        make.left.mas_equalTo(145 * Width_ato);
//        make.right.mas_equalTo(-145 * Width_ato);
//        make.height.mas_equalTo(15 * Height_ato);
//    }];
    stateButton.size = CGSizeMake(56, 100);
    
    
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
    
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:stateButton];
    NSArray *array = @[negativeSpacer, right];
    self.navigationItem.rightBarButtonItems = array;
    
    stateLabel.text = order.parent_title;
    if ([order.child_title isEqualToString:@"cancel"]) {
        [stateButton setTitle:@"取消订单" forState:UIControlStateNormal];
        
    } else if([order.child_title isEqualToString:@"refund"]){
        [stateButton setTitle:@"七日退款" forState:UIControlStateNormal];
        [stateButton setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
    }
//    [stateButton setTitle:order.child_title forState:UIControlStateNormal];
    CustomButton *telButton = [CustomButton new];
    [telButton addTarget:self action:@selector(telButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [telButton setImage:[UIImage imageNamed:@"tel_supplier"] text:@"电话联系"];//todo
    [view addSubview:telButton];//todo 自定义button
    [telButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height+164 * Height_ato - 64);
        make.left.mas_equalTo(60 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(140 * Width_ato, 43 * Height_ato));
    }];
    CustomButton *convButton = [CustomButton new];
    [convButton setTintColor:WeddingTimeBaseColor];
    [convButton addTarget:self action:@selector(convButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:convButton];
    [convButton setImage:[UIImage imageNamed:@"con_supplier"] text:@"在线咨询"];
    [convButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height+164 * Height_ato - 64);
        make.left.mas_equalTo(217 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(140 * Width_ato, 43 * Height_ato));
    }];
    
    return view;
}
- (void)telButtonAction
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView mp_setImageWithURL:order.supplier_logo placeholderImage:[UIImage imageNamed:@"male_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        WTAlertView *alert = [[WTAlertView alloc] initWithText:@"是否拨打该商家电话" centerImage:image];
        //        alert.delegate = self;
        
        alert.buttonTitles = @[@"取消", @"拨打"];
        alert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            [alert close];
            
            if (index == 0) {
                
            } else if (index == 1) {
                NSString *telStr = _result[@"supplier_phone"];
                if (!telStr) {
                    [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
                    return;
                }
                
                if (![telStr isNotEmptyCtg])
                {
                    [WTProgressHUD ShowTextHUD:@"该商家没有留下电话哦" showInView:KEY_WINDOW];
                    return;
                }
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",telStr];
                if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]) {
                    [WTProgressHUD ShowTextHUD:@"号码无效" showInView:KEY_WINDOW];
                    return;
                }
            }
            
        };
        [alert show];
    }];

    
 
}

- (void)convButtonAction
{
    [self conversationSelectType:0 supplier_id:_result[@"supplier_user_id"] hotelDic:nil name:_result[@"supplier_company"] phone:[LWUtil getString:_result[@"supplier_phone"] andDefaultStr:@""] avatar:order.supplier_logo];
}

- (void)stateButtonAction
{
    if ([order.child_title isEqualToString:@"cancel"]) {
        WTAlertView *wtAlert = [[WTAlertView alloc] initWithText:@"确定取消订单" centerImage:nil];
        wtAlert.buttonTitles = @[@"取消", @"确定"];
        wtAlert.onButtonTouchUpInside = ^(WTAlertView *alert, int index){
            if (index == 0) {
                [alert close];
            } else if (index == 1) {
                [alert close];
                if (_ordersate == orderstate_waitToGet) {
                    
                    [PostDataService postOrderCancelOut_trade_no:[LWUtil getString: _result[@"out_trade_no"] andDefaultStr:@""] child_trade_no:[LWUtil getString: child_result[@"child_trade_no"] andDefaultStr:@""] WithBlock:^(NSDictionary *result, NSError *error) {
                        if (error) {
                            NSNumber *status = error.userInfo[@"status"];
                            if (status.intValue == 1006) {
                                [WTProgressHUD ShowTextHUD:@"这是您另一半的订单，您无权改动哦" showInView:self.view];
                            }
//                            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@""] showInView:self.view];
                            return ;
                        } else {
                            [WTProgressHUD ShowTextHUD:@"取消订单成功" showInView:self.view];
                            [self loadData];
                            [self.delegate orderlistrefresh];
                        }
                    }];
                    
                } else{
                    [PostDataService postOrderCancelChild_order_no:child_id withBlock:^(NSDictionary *result, NSError *error) {
                        if (error) {
                            
                            [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@""] showInView:self.view];
                            return ;
                        } else {
                            
                            [self loadData];
                            [self.delegate orderlistrefresh];
                        }
                    }];
                }
            }

        };
        
        [wtAlert show];
    } else if([order.child_title isEqualToString:@"refund"]) {
        WTRefundViewController *refund = [[WTRefundViewController alloc] init];
        refund.delegate = self;
        [self.navigationController pushViewController:refund animated:YES];
    } else{
        
    }
}

- (void)getOrderState
{
    NSNumber *number = _result[@"trans_status"];
    if (number.intValue == 1) {
        self.ordersate = orderstate_waitToGet;
    }
    if (childNum.intValue == 1) {
        self.ordersate = OrderState_hasCancael;
    }
    if (childNum.intValue == 2) {
        self.ordersate = orderstate_waitToPay;
    }
    if (childNum.intValue == 3) {
        self.ordersate = orderstate_hasPayed;
    }
    if (childNum.intValue == 4) {
        self.ordersate = orderstate_isrefunding_nok;
    }
    if (childNum.intValue == 5) {
        self.ordersate = orderstate_refundDone;
    }
    if (childNum.intValue == 6) {
        self.ordersate = orderstate_refundFailed;
    }
}

- (void)loadData
{
    strArray = @[@"订单发起人", @"预定商家", @"预定婚期", @"预定城市", @"定金"];
    if (!self.order_id) {
        _order_id = @"0";
    }
    [GetService getOrderDetailWithOrder_id:self.order_id Blcok:^(NSDictionary *dic, NSError *error) {
        if (error) {
            NSString *str = [LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出错啦，请稍候再试"];
//            [WTProgressHUD showLoadingHUDWithTitle:str showInView:self.view ];
            [WTProgressHUD ShowTextHUD:str showInView:self.view afterDelay:1];
        } else {
            [self doFinishGetOrderListResult:dic Block:^{
                _result = dic[@"data"];
                
                [self getCashOrderDetail:^{
                    OrderDetail *detail = _array[0];
                    NSString *child_orders = detail.child_orders;
                    NSData *thedata = [child_orders dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray *array = [LWUtil toArrayOrNSDictionary:thedata];
                    if (array.count > 0) {
                        NSDictionary *dic = array[0];
                        childNum = dic[@"pay_status"];
                        child_id = dic[@"child_order_no"];
                    }

                    [self getOrderState];
                    self.dataTableView.tableHeaderView = [self getHeaderView];
                    [self.dataTableView reloadData];
                    [self changePayButtonStyle];
                }];
                
            }];
            
        }
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return strArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailTC *cell = [tableView orderDetailTC];
    if (_array.count > 0) {
        id info = _array[0];
        
        [cell setInfo:info index:indexPath];
        if (indexPath.row == 4) {
            [cell setValueLabelTextColor:[WeddingTimeAppInfoManager instance].baseColor];
        }
    }
    NSString *str = strArray[indexPath.row];
    [cell setPromptLabelText:str];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        [self jumpToSupplierDetail];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50 * Height_ato > 38 ? 50 * Height_ato:38;
}

- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payHandleState) name:AlipayCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFailHandleState) name:AlipayFailCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderRefresh) name:UserDidPayed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
