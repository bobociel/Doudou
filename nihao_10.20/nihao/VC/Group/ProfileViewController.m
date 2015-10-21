//
//  ProfileViewController.m
//  nihao
//
//  Created by Apple on 15/10/12.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSString *reNickname;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _titleArray = @[@"",@"",@"Chat History",@"",@"Report"];
    
    [self initTableView];
}


#pragma mark - init views
-(void) initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 600)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = ColorWithRGB(244, 244, 244);
    self.view.backgroundColor = ColorWithRGB(244, 244, 244);
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces=YES;
    [self.view addSubview:_tableView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - Navigation
-(void)addBtnClick{

    NSLog(@"===Click====");

}
#pragma mark - Table Delegate Methods（tableView代理方法）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 100;
    }
    if (indexPath.row == 1) {
        return 15;
    }
    if (indexPath.row == 3) {
        return 15;
    }
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"basis-cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0 ) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //头像
        UIImageView *profileImageView=[[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 60, 60)];
        [profileImageView setImage:[UIImage imageNamed:@"imageName"]];
        [cell.contentView addSubview:profileImageView];
        //名称
        UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 79, 60, 17)];
        nameLabel.text=self.profileName;
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.font = FontNeveLightWithSize(12.0);
        nameLabel.textColor = ColorWithRGB(50, 50, 50);
        [cell.contentView addSubview:nameLabel];
        //按钮
        UIButton *addBtn= [[UIButton alloc] initWithFrame:CGRectMake(90, 15, 60, 60)];
        [addBtn setBackgroundImage:[UIImage imageNamed:@"profile_add"] forState:UIControlStateNormal];
        
        [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addBtn];
    }
    if (indexPath.row == 1  || indexPath.row == 3 ) {
        cell.contentView.backgroundColor = ColorWithRGB(244, 244, 244);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 2  || indexPath.row == 4 ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    }
    
    
    
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.font = FontNeveLightWithSize(14.0);
    cell.textLabel.textColor = ColorWithRGB(50, 50, 50);
    return cell;
}
//tableView点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
}

@end
