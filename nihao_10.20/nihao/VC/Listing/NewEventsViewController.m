//
//  NewEventsViewController.m
//  nihao
//
//  Created by 罗中华 on 15/10/19.
//  Copyright © 2015年 boru. All rights reserved.
//

#import "NewEventsViewController.h"
#import "CreatEventViewController.h"
#import "NewEventsTableViewCell.h"
@interface NewEventsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *_postButton;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *parButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) UIButton *currentButton;
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
    
    [self.parButton setBackgroundColor:RGB(230, 230, 230)];
    [self.createButton setBackgroundColor:RGB(255, 255, 255)];
    self.currentButton = self.parButton;
    
    self.tableView.rowHeight = 98;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
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

- (IBAction)BtnClick:(UIButton *)sender
{
    if([_currentButton isEqual:sender])
    {
        return;
    }
    [_currentButton setBackgroundColor:[UIColor whiteColor]];
    [sender setBackgroundColor:RGB(230, 230, 230)];
    _currentButton = sender;
    [self.tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_currentButton isEqual:_createButton]? 2 : 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewEventsTableViewCell *cell = (NewEventsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewEventsTableViewCell"];
    if(!cell)
    {
        cell = (NewEventsTableViewCell *)[[NSBundle mainBundle] loadNibNamed:@"NewEventsTableViewCell" owner:self options:nil][0];
    }
    return cell;
}


@end
