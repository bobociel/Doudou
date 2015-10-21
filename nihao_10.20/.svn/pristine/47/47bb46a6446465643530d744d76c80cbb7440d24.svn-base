//
//  ShareWithViewController.m
//  nihao
//
//  Created by 刘志 on 15/6/18.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ShareWithViewController.h"
#import "UserVisibilityCell.h"

@interface ShareWithViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSArray *_labelArray1;
    NSArray *_labelArray2;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation ShareWithViewController

static NSString *cellIdentifier = @"UserVisibilityIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Share with";
    [_table registerNib:[UINib nibWithNibName:@"UserVisibilityCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _table.tableFooterView = [[UIView alloc] init];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _labelArray1 = @[@"Public",@"Friends Circle"];
    _labelArray2 = @[@"Public",@"Visible to Friends"];
    
    UIButton *cancelButton = [self createNavBtnByTitle:@"Cancel" icon:nil action:@selector(cancel)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_table deselectRowAtIndexPath:indexPath animated:YES];
    self.typeChanged(indexPath.row);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _labelArray1.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserVisibilityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.title1.text = _labelArray1[indexPath.row];
    cell.title2.text = _labelArray2[indexPath.row];
    cell.statusImage.image = (_type == indexPath.row) ? [UIImage imageNamed:@"icon_checkbox_selected"] : [UIImage imageNamed:@"icon_checkbox_unselected"];
    return cell;
}


@end
