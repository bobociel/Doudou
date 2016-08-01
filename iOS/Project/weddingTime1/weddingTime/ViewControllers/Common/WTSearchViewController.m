//
//  WTSearchViewController.m
//  weddingTime
//
//  Created by 默默 on 15/10/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSearchViewController.h"
#import "FRDLivelyButton.h"
#import "WTInspiretionListViewController.h"
#import <objc/runtime.h>
#import "GetService.h"
#import "WTSHViewController.h"
#import "WTFindViewController.h"
#import "UserInfoManager.h"

#define tableViewCellHeight 50
@interface WTSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation WTSearchViewController
{
    NSArray *searchTypeArr;
    FRDLivelyButton *chooseTypeArrowbutton;
    UIButton *typeButton;
    
    UITextField *searchTextField;
    
    float tableViewHeight;
    BOOL isShowMenu;
    UITableView *searchTypeTableView;
    UIButton *searchTypeTableViewBackView;
    
    WTSHViewController *weddingCommListViewController;
    WTInspiretionListViewController *weddingInspiretionSearchListViewController;
    
    NSMutableArray *nameArr;
    
    UIScrollView *HotVipScroll;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self GetHotVip];
    [self initView];
    [self initHotView];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)GetHotVip{
    
    //获取热门词 TODO当前城市
    [GetService getHotVipWithCityid:[UserInfoManager instance].curCityId withBlock:^(NSDictionary *result, NSError *error) {
        if (error) {
            return ;
        }
        else{
            NSArray *arr = result[@"data"];
            nameArr = [NSMutableArray array];
            for (NSDictionary *dic in arr) {
                NSString *name = dic[@"name"];
                [nameArr addObject:name];
            }
            [[NSUserDefaults standardUserDefaults]setObject:nameArr forKey:@"HotVip"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self initHotView];
            //[[Constant instance]saveToPlist];
        }
    }];
}

-(void)initHotView
{
    //热门搜索
    float HotVipScrollHeight=screenHeight-64-150;
    float HotBtnHeight=35;
    if (!HotVipScroll) {
        HotVipScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 222, HotVipScrollHeight)];
    }
    
    nameArr=[[NSUserDefaults standardUserDefaults]objectForKey:@"HotVip"];
    CGFloat realHeight=(nameArr.count+1)*HotBtnHeight;
    HotVipScroll.height=realHeight;
    if (HotVipScroll.height>HotVipScrollHeight) {
        HotVipScroll.height=HotVipScrollHeight;
    }
    
    HotVipScroll.centerX=screenWidth/2;
    HotVipScroll.centerY=screenHeight/2-64;
    
    HotVipScroll.contentSize=CGSizeMake(0, realHeight);
    HotVipScroll.showsHorizontalScrollIndicator=NO;
    HotVipScroll.showsVerticalScrollIndicator=NO;
    [self.view insertSubview:HotVipScroll belowSubview:searchTypeTableViewBackView];
    
    [HotVipScroll removeAllSubviews];
    for (int i = 0 ; i<nameArr.count; i++) {
        UIButton *hotBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        hotBtn.frame=CGRectMake(0, i*HotBtnHeight, 222, HotBtnHeight);
        hotBtn.backgroundColor=[UIColor clearColor];
        [hotBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [hotBtn setTitle:nameArr[i] forState:UIControlStateNormal];
        hotBtn.titleLabel.font=defaultFont14;
        [hotBtn addTarget:self action:@selector(HotBtnClickEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        hotBtn.tag=100+i;
        [HotVipScroll addSubview:hotBtn];
    }
}

-(void)HotBtnClickEvent:(UIButton *)HotBtn{
    searchTextField.text=nameArr[HotBtn.tag-100];
    [self begainSearch];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)initView{
    searchTypeArr = @[@"服务商",@"灵感",@"酒店"];
    
    searchTextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, screenWidth-85-50, 44)];
    searchTextField.placeholder = @"输入关键词";
    searchTextField.textAlignment = NSTextAlignmentLeft;
    searchTextField.font=defaultFont16;
    searchTextField.returnKeyType   = UIReturnKeySearch;
    searchTextField.enablesReturnKeyAutomatically=YES;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.delegate        = self;
    self.navigationItem.titleView=searchTextField;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
    
    tableViewHeight=tableViewCellHeight*searchTypeArr.count;
    searchTypeTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, -tableViewHeight, screenWidth, tableViewHeight) style:(UITableViewStylePlain)];
    searchTypeTableView.delegate=self;
    searchTypeTableView.dataSource=self;
    searchTypeTableView.bounces=NO;
    [self.view addSubview:searchTypeTableView];
    
    if (!searchTypeTableViewBackView) {
        searchTypeTableViewBackView=[UIButton buttonWithType:UIButtonTypeCustom];
        searchTypeTableViewBackView.backgroundColor=rgba(0, 0, 0, 1);
        searchTypeTableViewBackView.frame=self.view.bounds;
        [searchTypeTableViewBackView addTarget:self action:@selector(showSearchTypeMenuEvent) forControlEvents:UIControlEventTouchUpInside];
        searchTypeTableViewBackView.alpha=0;
        [self.view insertSubview:searchTypeTableViewBackView belowSubview:searchTypeTableView];
    }
    
    typeButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 100)];
    typeButton.titleLabel.font=defaultFont16;
    [typeButton setTitle:searchTypeArr[self.curSearchType] forState:UIControlStateNormal];
    [typeButton setTitleColor:rgba(51, 51, 51, 1) forState:UIControlStateNormal];
    typeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    chooseTypeArrowbutton = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0, 0, 14, 24)];
    chooseTypeArrowbutton.right=typeButton.width;
    chooseTypeArrowbutton.centerY=typeButton.height/2;
    chooseTypeArrowbutton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [chooseTypeArrowbutton setStyle:kFRDLivelyButtonStyleCaretDown animated:NO];
    [chooseTypeArrowbutton setOptions:@{kFRDLivelyButtonLineWidth: @(2.0f),kFRDLivelyButtonColor:[WeddingTimeAppInfoManager instance].baseColor}];
    
    [typeButton addSubview:chooseTypeArrowbutton];
    
    UIBarButtonItem *showSearchTypeMenuItem= [[UIBarButtonItem alloc] initWithCustomView:typeButton];
    [typeButton addTarget:self action:@selector(showSearchTypeMenuEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:showSearchTypeMenuItem];
    
    [self setRightBtnWithTitle:@"取消"];
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    lineView.backgroundColor=defaultLineColor;
    [self.view addSubview:lineView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setChooseImage:(BOOL)isOpen {
    if (isOpen) {
        [chooseTypeArrowbutton setStyle:kFRDLivelyButtonStyleCaretUp animated:YES];
    }else {
        [chooseTypeArrowbutton setStyle:kFRDLivelyButtonStyleCaretDown animated:YES];
    }
}

-(void)showSearchTypeMenuEvent
{
    float y;
    if(isShowMenu)
    {
        y=-tableViewHeight;
        searchTypeTableViewBackView.alpha=0.5;
        [UIView animateWithDuration:0.3 animations:^{
            searchTypeTableViewBackView.alpha=0;
        }
                         completion:^(BOOL finished) {
                         }
         ];
    }
    else
    {
        y=0;
        searchTypeTableViewBackView.alpha=0;
        [UIView animateWithDuration:0.3 animations:^{
            searchTypeTableViewBackView.alpha=0.5;
        }
                         completion:^(BOOL finished) {
                         }
         ];
    }
    [UIView animateWithDuration:0.3 animations:^{
        searchTypeTableView.top=y;
        isShowMenu=!isShowMenu;
        [self setChooseImage:isShowMenu];
    }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

-(void)rightNavBtnEvent
{
    [self back];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark-<UITableViewDelegate,UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchTypeArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableViewCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    }
    [cell.contentView removeAllSubviews];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(14, 0,screenWidth-14, tableViewCellHeight)];
    label.text=searchTypeArr[indexPath.row];
    label.font=defaultFont16;
    label.textColor=rgba(51, 51, 51, 1);
    label.textAlignment=NSTextAlignmentLeft;
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(15, tableViewCellHeight-0.5, screenWidth-15, 0.5)];
    if (indexPath.row==searchTypeArr.count-1) {
        lineView.left=0;
        lineView.width=screenWidth;
    }
    lineView.backgroundColor=defaultLineColor;
    [cell.contentView addSubview:lineView];
    [cell.contentView addSubview:label];
    objc_setAssociatedObject(cell, @"label", label,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(cell, @"cell" ,   cell,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UILabel *label=objc_getAssociatedObject(cell, @"label");
    cell=objc_getAssociatedObject(cell, @"cell");
    cell.accessoryType=UITableViewCellAccessoryCheckmark;
    cell.tintColor=[WeddingTimeAppInfoManager instance].baseColor;
    label.textColor=[WeddingTimeAppInfoManager instance].baseColor;
    [self tapMenuItem:(int)indexPath.row];
}

-(void)tapMenuItem:(int)index{
    [self showSearchTypeMenuEvent];
    _curSearchType=index;
    [typeButton setTitle:searchTypeArr[_curSearchType] forState:UIControlStateNormal];
    if ([searchTextField.text isNotEmptyCtg]) {
        [self begainSearch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [searchTextField resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    cell=objc_getAssociatedObject(cell, @"cell");
    cell.accessoryType=UITableViewCellAccessoryNone;
    UILabel *label=objc_getAssociatedObject(cell, @"label");
    label.textColor=rgba(51, 51, 51, 1);
}

- (void)begainSearch {
    HotVipScroll.hidden=YES;
    [weddingInspiretionSearchListViewController.view removeFromSuperview];
    [weddingCommListViewController.view removeFromSuperview];
    if (self.curSearchType== SearchTypeInspiretion){
        if (!weddingInspiretionSearchListViewController) {
            weddingInspiretionSearchListViewController = [[WTInspiretionListViewController alloc] initWithNibName:@"WTInspiretionListViewController" bundle:nil];
            [self addChildViewController:weddingInspiretionSearchListViewController];
            weddingInspiretionSearchListViewController.isFromSearch=YES;
            weddingInspiretionSearchListViewController.searchTag=searchTextField.text;
            weddingInspiretionSearchListViewController.view.frame=CGRectMake(0, 0, screenWidth, screenHeight-64);
        }
        else
        {
            [weddingInspiretionSearchListViewController beginSearchWithsearchTag:searchTextField.text];
        }
        [self.view insertSubview:weddingInspiretionSearchListViewController.view belowSubview:searchTypeTableViewBackView];
    }
    else  if (self.curSearchType != SearchTypeDiscover)
    {
        ListType listType;
        switch (self.curSearchType) {
            case SearchTypeSupplier:
                listType=supplier_type;
                break;
            case SearchTypeHotel:
                listType=hotel_type;
                break;
            default:
                break;
        }
        if (!weddingCommListViewController) {
            weddingCommListViewController = [WTSHViewController new];
            weddingCommListViewController.isFromSearch=YES;
            [self addChildViewController:weddingCommListViewController];
            weddingCommListViewController.view.frame=CGRectMake(0, 0, screenWidth, screenHeight-64);
        }
        weddingCommListViewController.listType=listType;
        [self.view insertSubview:weddingCommListViewController.view belowSubview:searchTypeTableViewBackView];
        [weddingCommListViewController beginSearchWithKwyWord:searchTextField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField  // return NO to disallow editing.
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
}

- (BOOL)textFieldShouldClear:(UITextField *)textField            // called when clear button pressed. return NO to ignore (no notifications)
{
    return YES;
}

-(void)textFieldTextDidChangeNotification:(NSNotification*)notification
{
    UITextField *textField=searchTextField;
    
    UITextRange *selectedRange = [textField markedTextRange];
    
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    if (!position){//非高亮
        if ([textField.text isNotEmptyCtg]) {
            [self begainSearch];
        }
        else
        {
            [weddingInspiretionSearchListViewController.view removeFromSuperview];
            [weddingCommListViewController.view removeFromSuperview];
            HotVipScroll.hidden=NO;
        }
    }
}
@end


