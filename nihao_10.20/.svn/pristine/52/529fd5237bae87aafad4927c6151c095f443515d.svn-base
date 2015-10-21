//
//  MailListViewController.m
//  nihao
//
//  Created by HelloWorld on 6/11/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MailListViewController.h"
#import "BATableView.h"
#import "HttpManager.h"
#import "FollowUserCell.h"
#import "FollowUser.h"
#import <MJExtension.h>

@interface MailListViewController () <UISearchBarDelegate, UISearchDisplayDelegate, BATableViewDelegate> {
    NSArray *_data;
    NSMutableArray *_filteredData;
    NSMutableDictionary *_dic;
    BATableView *_baTable;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

static NSString *CellReusableIdentifier = @"FollowUserCell";

@implementation MailListViewController {
    BOOL inSearching;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    [self processData];
    inSearching = NO;
}

/**
 *  控件初始化
 */
- (void) initViews {
    self.title = @"Mobile Contact";
    _baTable = [[BATableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_searchBar.frame) - 64)];
    _baTable.delegate = self;
    _baTable.tableView.tableFooterView = [[UIView alloc] init];
//    [_baTable.tableView registerClass:[FollowUserCell class] forCellReuseIdentifier:CellReusableIdentifier];
    [_baTable.tableView registerNib:[UINib nibWithNibName:@"FollowUserCell" bundle:nil] forCellReuseIdentifier:CellReusableIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FollowUserCell" bundle:nil] forCellReuseIdentifier:CellReusableIdentifier];
    _baTable.tableView.rowHeight = 70;
    _baTable.tableView.sectionHeaderHeight = 30;
    [self.view addSubview:_baTable];

    _dic = [NSMutableDictionary dictionary];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    self.searchDisplayController.searchResultsTableView.rowHeight = _baTable.tableView.rowHeight;
}

- (void)processData {
    NSArray *allUsers = self.allUsedAppFromContactsUsers;
    _data = [FollowUser objectArrayWithKeyValuesArray:allUsers];
    for(FollowUser *user in _data) {
        NSString *userName = user.ci_nikename;
        if (IsStringNotEmpty(userName)) {
            // 取出首字母当作key，将用户放到对应的array里
            NSString *firstChar = [[userName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
            // 判断首字母是否为字母
            NSString *regex = @"[A-Za-z]+";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if ([predicate evaluateWithObject:firstChar]) {
                if([[_dic allKeys] containsObject:firstChar]) {
                    NSMutableArray *users = _dic[firstChar];
                    [users addObject:user];
                } else {
                    NSMutableArray *users = [NSMutableArray array];
                    [users addObject:user];
                    [_dic setObject:users forKey:firstChar];
                }
            } else {
                firstChar = @"#";
                if([[_dic allKeys] containsObject:firstChar]) {
                    NSMutableArray *users = _dic[firstChar];
                    [users addObject:user];
                } else {
                    NSMutableArray *users = [NSMutableArray array];
                    [users addObject:user];
                    [_dic setObject:users forKey:firstChar];
                }
            }
        }
    }
    
    _filteredData = [[NSMutableArray alloc] init];
    [_baTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
    NSArray *keys = [_dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

- (void)followUser:(FollowUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath {
    [HttpManager addRelationBySelfUserID:self.userID toPeerUserID:[NSString stringWithFormat:@"%d", user.ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
//            NSLog(@"message = %@", [resultDict objectForKey:@"message"]);
            user.friend_type = 2;
            if (inSearching) {
                [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [_baTable.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Table view data source

/**
 *  列表右侧字母表
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return [self sortedKeys];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == _baTable.tableView) {
        return [_dic allKeys].count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        NSString *key = [self sortedKeys][section];
        NSArray *data = _dic[key];
        return data.count;
    } else {
        return _filteredData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowUserCell *cell = (FollowUserCell  *)[tableView dequeueReusableCellWithIdentifier:CellReusableIdentifier forIndexPath:indexPath];
    FollowUser *user;
    if(tableView  == _baTable.tableView) {
        NSString *key = [self sortedKeys][indexPath.section];
        user =  _dic[key][indexPath.row];
    } else {
        user = _filteredData[indexPath.row];
    }
    
    if (user) {
        [cell initCellWithUser:user forRowAtIndexPath:indexPath];
        cell.followUser = ^(FollowUser *user, NSIndexPath *indexPath){
            [self followUser:user forRowAtIndexPath:indexPath];
        };
        return cell;
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        NSString *key = [_dic allKeys][section];
        return key;
    } else {
        return nil;
    }
}

#pragma mark - tableview delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        //创建section的header view
        UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        headerSection.backgroundColor = ColorWithRGB(250, 250, 250);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
        label.text = [self sortedKeys][section];
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
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    inSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    inSearching = NO;
    [_baTable.tableView reloadData];
}

#pragma mark Content Filtering
// 根据用户输入的文字筛选
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [_filteredData removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ci_nikename contains[cd] %@", searchText];
    [_filteredData removeAllObjects];
    [_filteredData addObjectsFromArray:[_data filteredArrayUsingPredicate:predicate]];
}

@end
