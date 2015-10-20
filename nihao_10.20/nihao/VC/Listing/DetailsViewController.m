//
//  DetailsViewController.m
//  nihao
//
//  Created by 罗中华 on 15/10/19.
//  Copyright © 2015年 boru. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailsTableViewCell.h"

@interface DetailsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView *_imageView;
//    UITableView *_detailsTableView;
}
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Details";
    [self dontShowBackButtonTitle];
    [self addChild];
    // Do any additional setup after loading the view from its nib.
}
- (void)addChild{
    UITableView *detailsTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 170, SCREEN_WIDTH, SCREEN_HEIGHT-280) style:UITableViewStyleGrouped];
    detailsTableView.scrollEnabled  = NO;
    detailsTableView.delegate =self;
    detailsTableView.dataSource =self;
    [self.view addSubview:detailsTableView];

}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    DetailsTableViewCell *cell = [DetailsTableViewCell cellWithTableView:tableView];
    if (0==indexPath.section) {
        if (2==indexPath.row||3==indexPath.row) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 2:
                    cell.logLabel.text = @"September 14th KTV Singing and House";
                      cell.imageView.image = [UIImage imageNamed:@"icon_locate"];
                 
                    break;
                case 3:
                    cell.logLabel.text = @"September 14th KTV Singing and House";
                      cell.imageView.image = [UIImage imageNamed:@"icon_personal"];
                    break;
                    
                    
                default:
                    break;
            }
        }
        if (0==indexPath.row||1==indexPath.row||4==indexPath.row) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"September 14th KTV Singing and House ";
                    cell.textLabel.font = [UIFont systemFontOfSize:16]
                    ;
                    cell.textLabel.textColor = RGB(50, 50, 50);
                    break;
                case 1:
                    cell.logLabel.text = @"September 14th KTV Singing and House";
                    cell.imageView.image = [UIImage imageNamed:@"time_icon"];
                   break;
                case 4:
                    cell.logLabel.text = @"September 14th KTV Singing and House";
                      cell.imageView.image = [UIImage imageNamed:@"icon_count"];
                    break;
                    
                default:
                    break;
            }
        }
    }
    if (1==indexPath.section) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"September 14th KTV Singing and House September 14th KTV Singing and House September 14th KTV Singing and House September 14th KTV Singing and House September 14th KTV Singing and House";
        cell.textLabel.font =[UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGB(87, 87, 87);
        cell.textLabel.numberOfLines = 0;
    }
    return  cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (0==section) {
        return 5;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0==indexPath.section) {
        return 50;
    }
    return 97;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0==section) {
        return 0.1;
    }
    return 6;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
