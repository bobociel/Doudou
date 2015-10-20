//
//  NewEventsViewController.m
//  nihao
//
//  Created by 罗中华 on 15/10/19.
//  Copyright © 2015年 boru. All rights reserved.
//

#import "NewEventsViewController.h"
#import "CreatEventViewController.h"

@interface NewEventsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *_postButton;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Events";
   
    [self dontShowBackButtonTitle];
    [self setupNav];
    [self addChild];
    
    
    // Do any additional setup after loading the view from its nib.
}
- (void)addChild{
    self.tableView.rowHeight = 98;
}
- (void)setupNav{
    
    _postButton = [self createNavBtnByTitle:@"Post" icon:nil action:@selector(postBtnClick)];
    [_postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:_postButton];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = -15; // To balance action button
    self.navigationItem.rightBarButtonItems = @[fixedSpace,menuItem];
}
- (void)postBtnClick{
    CreatEventViewController *createvent =[[CreatEventViewController alloc]init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createvent animated:YES];
    NSLog(@"点击了添加按钮");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (IBAction)BtnClick:(id)sender {
    [self.tableView reloadData];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return cell;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
