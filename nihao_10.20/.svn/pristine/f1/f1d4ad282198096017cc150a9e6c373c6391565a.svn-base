//
//  AddFriendsViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "GroupAddFriendsViewController.h"
#import "HttpManager.h"
#import "BATableView.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension.h>
#import "AppConfigure.h"
#import "HttpManager.h"
#import "NihaoContact.h"
#import "ContactCell.h"
#import "BaseFunction.h"
#import "UserInfoViewController.h"
#import "GroupAddFriendsViewController.h"
#import "FriendDao.h"
#import "UserInfoViewController.h"
#import "FindFriendsViewController.h"
#import "GuideView.h"
#import "UIImageView+WebCache.h"

 // 只要添加了这个宏，就不用带mas_前缀
#define MAS_SHORTHAND
 // 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"
#import "NoResultView.h"

@interface GroupAddFriendsViewController () <BATableViewDelegate,UISearchDisplayDelegate,UITextFieldDelegate,UISearchBarDelegate>{
    //,UISearchBarDelegate
    /*! 联系人列表*/
    BATableView *_table;
    /*! 列表加载状态*/
    ListingLoadingStatusView *_statusView;
    /*! 
     @brief: 用户联系人数据,key为用户昵称的首字母，value为拥有同个首字母的用户昵称的联系人对象的数据列表
     @code @{@"A":@[NihaoContact]} @endcode
     */
    NSMutableDictionary *_friendsData;
    FriendDao *_friendDao;
    UISearchDisplayController *_searchDisplayController;
    UISearchBar *_searchBar;
    //查询结果的数列
    NSMutableArray *_filterFriendsData;
    NoResultView *_noresults;
    NihaoContact *_contact;
    UIScrollView *_headerview;
    //群组联系人名单数组
    NSMutableArray *_groupListArray;
    //群组联系人头像数组
    NSMutableArray *_groupUserImageArray;
}
@property (strong, nonatomic) UIView             *gInView;  //内边框
@end

@implementation GroupAddFriendsViewController

static const CGFloat SEARCHBAR_HEIGHT = 44;


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title=@"Contact";
    _friendDao = [[FriendDao alloc] init];
    _friendsData = [[NSMutableDictionary alloc] init];
    _filterFriendsData = [NSMutableArray array];
    _groupListArray=[[NSMutableArray alloc]initWithObjects:self.firstUserName, nil];
    _groupUserImageArray=[[NSMutableArray alloc]init];
     NSLog(@"_groupListArray=%@",_groupListArray);
    
  
    
    [self initScrollView];
    
    [self initSearchView];
    
    [self initViews];
    [self initData];
    
    
    _noresults = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
    [self reqFriendsData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 初始化控件
-(void)initScrollView{
    _headerview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SEARCHBAR_HEIGHT, SCREEN_WIDTH,70)];
    _headerview.tag=777;
    [self.view addSubview:_headerview];
    _headerview.backgroundColor=[UIColor whiteColor];
    //滚动范围
    [_headerview setContentSize:CGSizeMake(((_groupUserImageArray.count+1)*55), 0)];
//    if (_groupUserImageArray.count!=0) {
      //  [_headerview setContentOffset:CGPointMake((_groupUserImageArray.count-1)*60, 0)];
//    }
    //禁止画出边界
//    _headerview.bounces=NO;
    //设置是否可以进行画面切换
    _headerview.pagingEnabled = YES;
    //隐藏滚动条设置（水平方向）
   _headerview.showsHorizontalScrollIndicator = YES;
   _headerview.userInteractionEnabled=YES;
    [self addHeaderImage];
}

//添加用户头像
-(void)addHeaderImage{
    for (int i=0; i<_groupUserImageArray.count; i++) {
        UIImageView *hearView=[[UIImageView alloc]init];
        
        if (i==0){
            [hearView setFrame:CGRectMake(15, 15, 40, 40)];
        }else if(i == 1){
            [hearView setFrame:CGRectMake(65, 15, 40, 40)];
        }else{
            [hearView setFrame:CGRectMake(15+i*50, 15, 40, 40)];
        }
        
        if ( ![_groupUserImageArray[i] hasPrefix:@"http"]) {
            NSURL *url=[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:_groupUserImageArray[i]]];
            [hearView sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
        }else{
            NSURL *url=[NSURL URLWithString:_groupUserImageArray[i]];
            [hearView sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
        }

        [_headerview addSubview:hearView];
    }



}

- (void) initSearchView {
    UIButton *OKBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [OKBtn addTarget:self action:@selector(OKBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [OKBtn setTintColor:[UIColor whiteColor]];
    [OKBtn setTitle:@"OK" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:OKBtn];
    self.navigationItem. rightBarButtonItem = rightItem;
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCHBAR_HEIGHT)];
    _searchBar.placeholder = @"Search";
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    // Change search bar text color
    searchField.font = FontNeveLightWithSize(14.0);
    // Change the search bar placeholder text color
    [searchField setValue:FontNeveLightWithSize(14.0) forKeyPath:@"_placeholderLabel.font"];
    searchField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.view addSubview:_searchBar];
    _searchBar.delegate = self;
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    _searchDisplayController.searchResultsTableView.delegate = self;
    _searchDisplayController.searchResultsTableView.dataSource = self;
    _searchDisplayController.delegate = self;
  
}

#pragma mark - ByttonClick


-(void)OKBtnClick{
    NSLog(@"OK");

}

- (void) initViews {
    _table = [[BATableView alloc] initWithFrame:CGRectMake(0,SEARCHBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-64 - SEARCHBAR_HEIGHT )];
    _table.delegate = self;
    _table.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_table];
    _friendsData = [[NSMutableDictionary alloc] init];
    //将加载列表状态view放到屏幕中间，y ＝ 屏幕高度 － view高度 － statusbar高度 － navigationbar高度 － table.headerview的高度
    _statusView = [[ListingLoadingStatusView alloc]init];
    [_table.tableViewIndex setFrame:CGRectMake(SCREEN_WIDTH-20, 0, 20, SCREEN_HEIGHT-64-70)];
    [_table.flotageLabel setFrame:CGRectMake((SCREEN_WIDTH- 64 ) / 2,(SCREEN_HEIGHT - 64-70) / 2,64,64)];
    __weak typeof(self) weakSelf = self;
    _statusView.refresh = ^() {
        [weakSelf reqFriendsData];
    };
    [self.view addSubview:_table.flotageLabel];
    [self.view addSubview:_table.tableViewIndex];
    [self.view addSubview:_statusView];
}

- (void) initData {
    NSArray *contacts = [_friendDao queryAllFriends];
    if(contacts.count != 0) {
        _friendsData = [self formNihaoContactData:contacts];
        [_table reloadData];
    } else {
        [_statusView showWithStatus:Loading];
    }
}

/**
 *  将好友数列处理成昵称的首字母为key，拥有相同key的用户数列为值的字典
 *
 *  @param contacts 好友数组
 *
 *  @return 字典
 */
- (NSMutableDictionary *) formNihaoContactData : (NSArray *) contacts {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for(NihaoContact *contact in contacts) {
        //用户昵称为空...
        if(IsStringEmpty(contact.ci_nikename)) {
            continue;
        }
        //如果有中文，将中文转化为拼音。取第一个字符，并将其转化为大写
        NSString *alphbet = [[[BaseFunction chineseToPinyin:contact.ci_nikename] substringToIndex:1] uppercaseString];
        if([[data allKeys] containsObject:alphbet]) {
            NSMutableArray *array = data[alphbet];
            [array addObject:contact];
        } else {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:contact];
            [data setObject:array forKey:alphbet];
        }
    }
    return data;
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
    NSArray *keys = [_friendsData allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

#pragma mark - batableview delegate
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return [self sortedKeys];
}

#pragma mark - tableview datasource


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == _table.tableView) {
        return [[self sortedKeys] count];
    } else {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (section < sortedKeys.count) {
            NSString *key = sortedKeys[section];
            return [_friendsData[key] count];
        } else {
            return 0;
        }
    } else {
        return _filterFriendsData.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId=@"Cell";
    // 通过indexPath创建cell实例 每一个cell都是单独的
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag=8808;
    UIView *cellView=[[UIView alloc]init];
    cellView.backgroundColor=[UIColor clearColor];
    [cell.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView.left);
        make.top.equalTo(cell.contentView.top);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 70));
    }];
    
    //headerImage
    UIImageView *headerImage=[[UIImageView alloc]init];
    [cellView addSubview:headerImage];
    [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cellView.left).offset(15);
        make.top.equalTo(cellView.top).offset(15);
        make.size.equalTo(CGSizeMake(40, 40));
    }];
    //label
    UILabel *userName=[[UILabel alloc]init];
    userName.font=FontNeveLightWithSize(16.0);
    userName.textColor=RGB(50, 50, 50);
    [cellView addSubview:userName];
    [userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerImage.right).offset(12);
        make.centerY.equalTo(headerImage.centerY);
    }];
    //choiceImage
    UIImageView *choiceImageView=[[UIImageView alloc]init];
     choiceImageView.tag=1001;
    [cellView addSubview:choiceImageView];
    [choiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cellView.right).offset(-40);
        make.centerY.equalTo(headerImage.centerY);
        make.size.equalTo(CGSizeMake(24, 24));
    }];
    
    //cell赋值
if(tableView == _table.tableView) {
            NSArray *sortedKeys = [self sortedKeys];
      if (indexPath.section < sortedKeys.count) {
            NSString *key = sortedKeys[indexPath.section];
            NSArray *contacts = _friendsData[key];
            _contact = contacts[indexPath.row];
            NSString *nickname = _contact.ci_nikename;
            NSString *headerImageStr = _contact.ci_header_img;
            userName.text = nickname;
            //选择框图片
          if ([_groupListArray containsObject:_contact.ci_username]) {
                if ([_groupListArray.firstObject isEqual:_contact.ci_username]) {
                         choiceImageView.image=ImageNamed(@"friend_Btn_can't_ pressed");
                         cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }else{
                         choiceImageView.image=ImageNamed(@"friend_Btn_pressed");
                     }
        }else{
                      choiceImageView.image=ImageNamed(@"friend_Btn_normal");
             }
        
        if ( ![headerImageStr hasPrefix:@"http"]) {
                      NSURL *url=[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:headerImageStr]];
                      [headerImage sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
        }else{
                      NSURL *url=[NSURL URLWithString:headerImageStr];
                     [headerImage sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
             }
   }else{
        return nil;
        }
}else{
             _contact = _filterFriendsData[indexPath.row];
             NSString *nickname = _contact.ci_nikename;
             NSString *headerImageStr = _contact.ci_header_img;
             userName.text = nickname;
    //选择框图片
        if ([_groupListArray containsObject:_contact.ci_username]) {
                   choiceImageView.image = ImageNamed(@"friend_Btn_can't_ pressed");
                   cell.selectionStyle = UITableViewCellSelectionStyleNone;
       }else{
                   choiceImageView.image = ImageNamed(@"friend_Btn_normal");
            }
    
       if ( ![headerImageStr hasPrefix:@"http"]) {
                    NSURL *url = [NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:headerImageStr]];
                    [headerImage sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
       }else{
                    NSURL *url = [NSURL URLWithString:headerImageStr];
                    [headerImage sd_setImageWithURL:url placeholderImage: ImageNamed(@"profile_imageD")];
            }
}
    return cell;
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        return 30;
    } else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == _table.tableView) {
        NSArray *sortedKeys = [self sortedKeys];
        if (section < sortedKeys.count) {
            UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            headerSection.backgroundColor = RGB(250, 250, 250);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
            label.text = sortedKeys[section];
            label.textColor = [UIColor colorWithRed:120.0 / 255 green:120.0 / 255 blue:120.0 / 255 alpha:1.0];
            label.font = [UIFont systemFontOfSize:12];
            [label sizeToFit];
            [headerSection addSubview:label];
            UIView *lineBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.view.frame), 0.5)];
            lineBottomSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
            [headerSection addSubview:lineBottomSeperator];
            
            UIView *lineTopSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0.5)];
            lineTopSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
            [headerSection addSubview:lineTopSeperator];
            return headerSection;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   UITableViewCell * cell=[tableView cellForRowAtIndexPath:indexPath];
   
    if(tableView == _table.tableView) {
        
            NSArray *sortedKeys = [self sortedKeys];
        if (indexPath.section < sortedKeys.count) {
                  NSString *key = sortedKeys[indexPath.section];
                  NSArray *contacts = _friendsData[key];
                  NihaoContact *contact = contacts[indexPath.row];
            
            if ([_groupListArray.firstObject isEqual:contact.ci_username]) {
                       cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                
                for (UIView *subviews in[self.view subviews]) {
                    if (subviews.tag==777) {
                        [subviews removeFromSuperview];
                    }
                }
                       [[cell viewWithTag:1001] removeFromSuperview];
                       UIImageView *choiceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64, 23, 24, 24)];
                       choiceImageView.tag=1001;
                       [cell.contentView addSubview:choiceImageView];
                
               if ( cell.tag == 8808){
                   
                   if ([_groupListArray containsObject:contact.ci_username]) {
                           choiceImageView.image=ImageNamed(@"friend_Btn_normal");
                           [_groupListArray removeObject:contact.ci_username];
                       [_groupUserImageArray removeObject:contact.ci_header_img];
                        [ self initScrollView];
                         //  NSLog(@"===删除此人===groupListArray==%@",_groupListArray);
                            NSLog(@"===删除此人头像===groupListArray==%@",_groupUserImageArray);
                           cell.tag = 8808;
                   }else{
                           choiceImageView.image=ImageNamed(@"friend_Btn_pressed");
                           [_groupListArray addObject:contact.ci_username];
                           [_groupUserImageArray addObject:contact.ci_header_img];
                        [ self initScrollView];
                         //  NSLog(@"===选择此人===groupListArray==%@",_groupListArray);
                             NSLog(@"===添加此人头像===groupListArray==%@",_groupUserImageArray);
                           cell.tag = 9909;
                        }
                  }else {
                           choiceImageView.image=ImageNamed(@"friend_Btn_normal");
                           [_groupListArray removeObject:contact.ci_username];
                           [_groupUserImageArray removeObject:contact.ci_header_img];
                       [ self initScrollView];
                         //  NSLog(@"===删除此人===groupListArray==%@",_groupListArray);
                          NSLog(@"===删除此人头像===groupListArray==%@",_groupUserImageArray);
                           cell.tag = 8808;
                        }
                  }
          }
        if (_groupUserImageArray.count != 0) {
            [_table setFrame:CGRectMake(0,SEARCHBAR_HEIGHT+70, SCREEN_WIDTH, SCREEN_HEIGHT-64 - SEARCHBAR_HEIGHT )];
            _headerview.hidden=NO;
        }else{
            [_table setFrame:CGRectMake(0,SEARCHBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-64 - SEARCHBAR_HEIGHT )];
            _headerview.hidden=YES;
        }
    } else {
        
            NihaoContact *contact = _filterFriendsData[indexPath.row];
            UIImageView *choiceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64, 23, 24, 24)];
            choiceImageView.tag=1001;
            if ( cell.tag==8808) {
                if ([_groupListArray containsObject: contact.ci_username]){
                       cell.selectionStyle = UITableViewCellSelectionStyleNone;
              }else{
                  for (UIView *subviews in[self.view subviews]) {
                      if (subviews.tag==777) {
                          [subviews removeFromSuperview];
                      }
                  }
                       [cell.contentView addSubview:choiceImageView];
                       choiceImageView.image=ImageNamed(@"friend_Btn_pressed");
                       [_groupListArray addObject:contact.ci_username];
                       [_groupUserImageArray addObject:contact.ci_header_img];
                    NSLog(@"===添加此人头像===groupListArray==%@",_groupUserImageArray);
                       [ self initScrollView];
                       [_table.tableView reloadData];
                    //   NSLog(@"===选择此人===groupListArray==%@",_groupListArray);
                       cell.tag=9909;
                   }
              }else{
                       [cell.contentView addSubview:choiceImageView];
                       choiceImageView.image=ImageNamed(@"friend_Btn_normal");
                       [_groupListArray removeObject:contact.ci_username];
                       [_groupUserImageArray removeObject:contact.ci_header_img];
                       NSLog(@"===删除此人头像===groupListArray==%@",_groupUserImageArray);
                       [_table.tableView reloadData];
                       [ self initScrollView];
                     //  NSLog(@"===删除此人===groupListArray==%@",_groupListArray);
                       cell.tag=8808;
                   }
                _headerview.hidden=YES;
             }
    
   
    }


#pragma mark - 请求好友联系人数据
- (void) reqFriendsData {
    NSDictionary *dic = @{@"cr_relation_ci_id":[AppConfigure objectForKey:LOGINED_USER_ID]};
    [HttpManager requestFriendsList:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_statusView showWithStatus:Done];
            NSArray *items = responseObject[@"result"][@"items"];
            NSArray *friendsFromServer = [NihaoContact objectArrayWithKeyValuesArray:items];
            if(friendsFromServer.count == 0) {
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_contact" emptyContent:@"No friend yet,invite them to join now!" imageSize:NO_CONTACT];
            } else {
                if(_friendsData.allKeys.count > 0) {
                    //friend数据库是否需要更新
                    //数据库里的好友数据
                    NSArray *friendsArraysInDb = _friendsData.allValues;
                    NSMutableArray *friendsInDb = [NSMutableArray array];
                    for(NSArray *array in friendsArraysInDb) {
                        [friendsInDb addObjectsFromArray:array];
                    }
                    NSMutableArray *addedFriends = [NSMutableArray array];
                    NSMutableArray *updatedFriends = [NSMutableArray array];
                    for(NihaoContact *friendFromServer in friendsFromServer) {
                        BOOL isNewFriend = YES;
                        for(NihaoContact *friendInDb in friendsInDb) {
                            if(friendInDb.ci_id == friendFromServer.ci_id) {
                                isNewFriend = FALSE;
                                //若字段有不一样的，需要更新本地数据库
                                if(![friendInDb isEqual:friendFromServer]) {
                                    [updatedFriends addObject:friendFromServer];
                                }
                                break;
                            }
                        }
                        
                        //新添加的好友
                        if(isNewFriend) {
                            [addedFriends addObject:friendFromServer];
                        }
                    }
                    
                    //是否有好友被删除
                    NSMutableArray *deletedFriends = [NSMutableArray array];
                    for(NihaoContact *friendInDb in friendsInDb) {
                        BOOL isDelete = YES;
                        for(NihaoContact *friendFromServer in friendsFromServer) {
                            if(friendInDb.ci_id == friendFromServer.ci_id) {
                                isDelete = NO;
                                break;
                            }
                        }
                        if(isDelete) {
                            [deletedFriends addObject:friendInDb];
                        }
                    }
                    
                    //将增加，删除，修改数据更新到数据库和列表
                    BOOL isNeedUpdateTable = NO;
                    if(addedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao insertFriends:addedFriends];
                        NSDictionary *dic = [self formNihaoContactData:addedFriends];
                        for(NSString *key in [dic allKeys]) {
                            if([[_friendsData allKeys] containsObject:key]) {
                                NSMutableArray *array = _friendsData[key];
                                [array addObjectsFromArray:dic[key]];
                            } else {
                                [_friendsData setObject:dic[key] forKey:key];
                            }
                        }
                    }
                    if(deletedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao deleteFriends:deletedFriends];
                        NSDictionary *dic = [self formNihaoContactData:deletedFriends];
                        for(NSString *key in [dic allKeys]) {
                            NSArray *array = dic[key];
                            for(NihaoContact *contact in array) {
                                [_friendsData[key] removeObject:contact];
                            }
                            
                            if([_friendsData[key] count] == 0) {
                                [_friendsData removeObjectForKey:key];
                            }
                        }
                    }
                    if(updatedFriends.count > 0) {
                        isNeedUpdateTable = YES;
                        [_friendDao updateFriends:updatedFriends];
                        NSDictionary *dic = [self formNihaoContactData:updatedFriends];
                        for(NSString *key in [dic allKeys]) {
                            NSArray *arrayNew = dic[key];
                            NSMutableArray *arrayOld = _friendsData[key];
                            for(NihaoContact *contactNew in arrayNew) {
                                NSInteger index = 0;
                                for(NihaoContact *contactOld in arrayOld) {
                                    if(contactNew.ci_id == contactOld.ci_id) {
                                        [arrayOld replaceObjectAtIndex:index withObject:contactNew];
                                        break;
                                    }
                                    index++;
                                }
                            }
                        }
                    }
                    
                    if(isNeedUpdateTable) {
                        [_table reloadData];
                    }
                    [_friendDao closeDB];
                } else {
                    _friendsData = [self formNihaoContactData:friendsFromServer];
                    [_friendDao insertFriends:friendsFromServer];
                    [_table reloadData];
                }
            }
        } else {
            if(_friendsData.count == 0) {
                [_statusView showWithStatus:NetErr];
            } else {
                if(_statusView.superview) {
                    [_statusView showWithStatus:Done];
                }
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(_friendsData.count == 0) {
            [_statusView showWithStatus:NetErr];
        } else {
            if(_statusView.superview) {
                [_statusView showWithStatus:Done];
            }
        }
    }];
}


#pragma mark - UISearchDisplayController delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_table setFrame:CGRectMake(0,SEARCHBAR_HEIGHT+70, SCREEN_WIDTH, SCREEN_HEIGHT-64 - SEARCHBAR_HEIGHT )];
    _headerview.hidden=NO;

}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    if(!IsStringEmpty(searchString)) {
        NSArray *array = [self filterFriendsByKeyword : searchString];
        [_filterFriendsData removeAllObjects];
        [_filterFriendsData addObjectsFromArray:array];
        [_searchDisplayController.searchResultsTableView reloadData];
    }
    // Return YES to cause the search result table view to be reloaded.
    
    for(UIView *subview in _searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:nil];
            [_searchDisplayController.searchResultsTableView addSubview: _noresults];
        }
    }
    
    return YES;
    
}


/**
 *  searchbar will show
 *
 *  @param controller
 *  @param tableView
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    //[self setTabBarHidden:YES];
}

/**
 *  searchbar will hide
 *
 *  @param controller
 *  @param tableView
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    //[self setTabBarHidden:NO];
}

- (UITabBar *) getTabBar {
    return self.navigationController.tabBarController.tabBar;
}

/**
 *  根据关键字筛选本地好友数据
 *
 *  @return friends对象的数列
 */
- (NSArray *) filterFriendsByKeyword : (NSString *) keyword {
    NSMutableArray *friendsArray = [NSMutableArray array];
    for(NSString *key in [_friendsData allKeys]) {
        NSArray *array = _friendsData[key];
        [friendsArray addObjectsFromArray:array];
    }
    
    //模糊查询
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ci_nikename contains[c] %@",keyword];
    NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predicate];
    return tempArray;
}

/**
 *  隐藏tabbarcontroller
 *
 *  @param hide 当hide为yes时，隐藏tabbar，否则隐藏tabbar
 */
-(void)setTabBarHidden:(BOOL)hide {
    UITabBarController *tabBarController = self.navigationController.tabBarController;
    ////隐藏
    if(hide == YES) {
        [tabBarController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 50)];
        tabBarController.tabBar.hidden = YES;
    } else {//显示
        [tabBarController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        tabBarController.tabBar.hidden = NO;
    }
}

#pragma mark - contact change notification
- (void) contactListChanged : (NSNotification *) notification {
    [self reqFriendsData];
}



@end
