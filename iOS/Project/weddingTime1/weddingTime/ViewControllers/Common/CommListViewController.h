//
//  CommListViewController.h
//  lovewith
//
//  Created by momo on 15/10/11.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//


#import "BaseViewController.h"
#import "GetService.h"
#import "PostDataService.h"

typedef enum{
    TableStatueTypeNo        = 0, //请勿复选
    TableStatueTypeRefresh   = 1, //请勿复选
    TableStatueTypeNoNetWork = 2<<1, //可复选 
    TableStatueTypeServerBad = 3<<2,
    TableStatueTypeNoresult  = 4<<3,
    TableStatueTypeNeedLogin = 5 //请勿复选
}TableStatueType;

@interface CommListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
{
    /**
     *  @author imqiuhang, 15-06-05 11:06:29
     *
     *  @brief  继承属性
     
     *  @param tableStatueType 当前网络状态 你可以在子类强制设置为TableStatueTypeNoresult来达到显示无结果的效果 或者其他效果 @see TableStatueType
     *  @param tableViewStyle 视图的类型 是列表还是detail
     
     *  @param maxPageCount最大的分页数  也就是一页多少个
     
     *  @param p当前的页数 传给服务器拿取相应的页的数据
    
     */
    @protected
    int page;
    int maxPageCount;
    UITableView *dataTableView;
    NSMutableArray *dataArray;
    /**
     *  @author imqiuhang, 15-06-05 11:06:41
     *
     *  @brief  私有属性 用于控制 是都进行上拉加载更多 无需在其他地方修改
     */
    @private
    BOOL footerOpen;
    BOOL headerOpen;
    BOOL isLoading;
}

-(void)setFootOpen:(BOOL)footOpen HeadOpen:(BOOL)headOpen;

/**
 *  @author imqiuhang, 15-05-05 11:06:31
 *
 *  @brief  在子类请求数据完成后 把结果和error一起交给父类处理
 *
 *  @param result 请求的结果 不需要知道是否有 父类会处理
 *  @param error  请求返回的错误 不需要知道是否有 父类会处理
 */

- (void)doloadFinishBlock:(NSDictionary *)result And:(NSError *)error;
/**
 *  @author imqiuhang, 15-05-05 11:06:12
 *
 *  @brief  实现加载更多的逻辑，当noMore为NO，且渲染最后一个cell时被调用
 */
- (void)loadMore;

- (void)reloadData;

-(void)loadData;

- (void)getDataFromSever;

/**
 *  @author momo, 15-10-11 11:06:51
 *
 *  @brief  ！！！！！！！！！！！注意！！！！！！！！！！
 *  @brief  ！！！！！！！！！！！注意！！！！！！！！！！
 *  @brief  ！！！！！！！！！！！注意！！！！！！！！！！
 *  @brief  以下方法是子类优先实现的tableview的委托方法 方法名都是带custom的 如有特殊需要可实现tabview自带的委托方法 ---除非确定子类已经实现父类的所有公共方法---
 *
 *  @example 比如请在子类用customCellForRowAtIndexPath代替cellForRowAtIndexPath
 *
 */
-(void)custemTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
