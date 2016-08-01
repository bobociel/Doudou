//
//  OrderListViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTOrderListViewController.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "OrderListTableViewCell.h"
#import "WTOrderDetailViewController.h"
#import "UserInfoManager.h"
#import "WTLocalDataManager.h"
@interface WTOrderListViewController ()<UITableViewDataSource, UITableViewDelegate, orderListRefresh>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *logoArray;
@end

@implementation WTOrderListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.array = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
//    if ([UserInfoManager instance].notFirstGetOrderList) {
        [self getCashOrderList:^{
            [self.tableView reloadData];
            [[UserInfoManager instance] saveToUserDefaults];
        }];
//    }
    [self loadData];
    [self addNotify];
    // Do any additional setup after loading the view.
}

-(void)swapWithData:(NSMutableArray *)aData index1:(NSInteger)index1 index2:(NSInteger)index2{
    NSNumber *tmp = [aData objectAtIndex:index1];
    [aData replaceObjectAtIndex:index1 withObject:[aData objectAtIndex:index2]];
    [aData replaceObjectAtIndex:index2 withObject:tmp];
}

-(NSArray *)bunbleSortWithArray:(NSArray *)aData{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:aData];
    if (array.count == 0) {
        return array;
    }
    for (int i=0; i<[array count]-1; i++) {
        for (int j =0; j<[array count]-1-i; j++) {
            OrderList *listj = [array objectAtIndex:j];
            OrderList *listJ = [array objectAtIndex:j+1];
            if (listj.wedding_timestamp.intValue < listJ.wedding_timestamp.intValue) {
                [self swapWithData:array index1:j index2:j+1];
            }
        }
    }
    return array;
}

- (void)getCashOrderList:(void (^)())finishBlock
{
    self.array = [NSMutableArray array];
    NSArray *selfArray = [NSArray arrayWithArray:[OrderList getOrderListFromDB]];
    NSArray *partnerArray = [NSArray arrayWithArray:[OrderList getPartnerOrderListfromDB]];
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObjectsFromArray:selfArray];
    [tempArray addObjectsFromArray:partnerArray];
//    [UserInfoManager instance].num_order = [NSString stringWithFormat:@"%lu", (unsigned long)tempArray.count + partnerArray.count];
    NSArray *marray = [self bunbleSortWithArray:tempArray];
    
//    [[UserInfoManager instance] saveToUserDefaults];
    [self.array addObjectsFromArray: marray];
    finishBlock();
}

- (void)doFinishGetOrderListResult:(NSDictionary *)result Block:(void(^)())block
{
    [UserInfoManager instance].notFirstGetOrderList = YES;
    self.logoArray = [NSMutableArray array];
    NSArray *array = result[@"data"];
    if (array.count == 0) {
        [NetWorkingFailDoErr errWithView:self.tableView content:@"还没有预约过商家" tapBlock:^{
            [self loadData];
        }]; //您目前还没有订单哦，请在预约和需求中创建订单
    }
    [UserInfoManager instance].num_order = [NSString stringWithFormat:@"%lu", (unsigned long)array.count];
    [[UserInfoManager instance] saveToUserDefaults];
    for (NSDictionary *dic in array) {
        NSString *str = dic[@"logo"];
        [_logoArray addObject:str];
        NSString *jsonStr;
        NSArray *array = [dic objectForKey:@"child_orders"];
        if (array == nil) {
            jsonStr = @"";
        }
        else {jsonStr = [LWUtil toJSONString:array];}
        NSMutableDictionary *nseDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [nseDic setObject:jsonStr forKey:@"child_orders"];
       [OrderList insertOrderListToDB:nseDic] ;
        
    }
    block();
}

- (void)initView
{
    [self.view addSubview:[UIView new]];
    self.title  =@"订单";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
//    [self showLoadingView];
}

- (void)loadData
{
    [GetService getOrderListWithBlcok:^(NSDictionary *result, NSError *error) {
//        [self hideLoadingView];
        if (error) {
//            [WTProgressHUD ShowTextHUD:@"服务器出现点问题，请稍候再试" showInView:self.view afterDelay:1];
//            [NetWorkingFailDoErr errWithView:self.view tapBlock:^{
//                [self loadData];
//            }];
        } else {
            WS(ws);
            [self doFinishGetOrderListResult:result Block:^{
                [ws getCashOrderList:^{
                    [self.tableView reloadData];
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
    return _array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    OrderListTableViewCell *cell = [tableView orderListCell];
    [cell setInfo:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTOrderDetailViewController *orderDetail = [[WTOrderDetailViewController alloc] init];
    OrderList *order = _array[indexPath.row];
    orderDetail.order_id = order.out_trade_no;
    orderDetail.delegate = self;
    [self.navigationController pushViewController:orderDetail animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (void)orderlistrefresh
{
    [self loadData];
}

- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderlistrefresh) name:UserDidPayed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payHandleState) name:AlipayCallBack object:nil];
}

-(void)payHandleState
{
    
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
