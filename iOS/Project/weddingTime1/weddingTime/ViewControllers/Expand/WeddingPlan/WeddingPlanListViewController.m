//
//  WeddingPlanListViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/6.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingPlanListViewController.h"
#import "GetService.h"
#import "WeddingPlanDetailViewController.h"
#import "AlertViewWithBlockOrSEL.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
@interface WeddingPlanListViewController ()

@end

@implementation WeddingPlanListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self getDataFromSever];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadData)
     name:WeddingPlanShouldBeReloadNotify
     object:nil];
    
}

- (void)getDataFromSever {
    [GetService getWeddingPlanListWithStatus:self.status andPage:page WithBlock:^(NSDictionary *result, NSError *error) {
         [self hideLoadingView];
         [self doloadFinishBlock:result[@"data"] And:error];
     }];
}

#pragma mark - tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeddingPlanListCell *cell = [tableView WeddingPlanListCell];
    [cell setInfo:dataArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [dataArray count]) {
        WeddingPlanDetailViewController *weddingPlanDetailViewController =
        [[WeddingPlanDetailViewController alloc] init];
        weddingPlanDetailViewController.data = dataArray[indexPath.row];
        [self.navigationController
         pushViewController:weddingPlanDetailViewController
         animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self delegatePlan:indexPath];
    }
}

- (void)delegatePlan:(NSIndexPath *)indexPath {
    
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"删除待办事项" message:[NSString stringWithFormat:@"确定删除计划:'%@'?",dataArray[indexPath.row][@"title"] ? dataArray[indexPath.row][@"title"] : @"婚礼计划"]];
    [alertView addOtherButtonWithTitle:@"删除" onTapped:^{
         [self showLoadingView];
         [PostDataService postWeddingPlanDelegateWithMatterId:dataArray[indexPath.row][@"matter_id"]?[dataArray[indexPath.row][@"matter_id"]intValue]:-1 withBlock:^(NSDictionary *result, NSError *error) {
             [self hideLoadingView];
             if (error) {
                 [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,请稍后再试"] showInView:self.view];
                 [dataTableView reloadRowsAtIndexPaths:@[ indexPath ]
                                           withRowAnimation:UITableViewRowAnimationRight];

             }else {
                 NSString *content=[NSString stringWithFormat:@"我删除了计划（%@）",dataArray[indexPath.row][@"title"]];
                 
                 [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
                     if (ourCov) {
                        [ChatConversationManager sendMessage:content conversation:ourCov push:NO success:^{
                            
                        } failure:^(NSError *error) {
                            
                        }];
                     }
                 }];

                 NSMutableArray *muData = [dataArray mutableCopy];
                 [muData removeObjectAtIndex:indexPath.row];
                 dataArray = [muData mutableCopy];
                 [dataTableView
                  deleteRowsAtIndexPaths:@[indexPath]
                  withRowAnimation:UITableViewRowAnimationLeft];
                 if ([dataArray count]<=0) {
                     //[self setAsNoresut];
                 }
			}
         }];
         
         
     }];
    [alertView setCancelButtonWithTitle:
     @"取消" onTapped:^{
         [dataTableView reloadRowsAtIndexPaths:@[ indexPath ]
                                   withRowAnimation:UITableViewRowAnimationRight];
     }];
    [alertView show];
}

- (void)initView {
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    dataTableView.frame=CGRectMake(0, 0, self.view.width,  self.view.height);
    dataTableView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleWidth       |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin   |
    UIViewAutoresizingFlexibleHeight      |
    UIViewAutoresizingFlexibleBottomMargin ;

//    noresultTitle =
//    self.status == finishedStatus
//    ? @"还没有已完成的计划哦\n切换到代办事项看看"
//    : @"还没有任何正在进行的婚礼计划哦";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
