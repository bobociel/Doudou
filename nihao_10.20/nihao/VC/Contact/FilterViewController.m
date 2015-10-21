//
//  FilterViewController.m
//  nihao
//
//  Created by 刘志 on 15/9/18.
//  Copyright © 2015年 jiazhong. All rights reserved.
//

#import "FilterViewController.h"
#import "GenderViewController.h"
#import "ProfileCell.h"
#import "RegionViewController.h"
#import "NationalityViewController.h"
#import "Nationality.h"
#import "SwitchCityViewController.h"

@interface FilterViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSArray *_titleArray;
    NSMutableDictionary *_filterDic;
    NSInteger _gender;
}

@property (strong,nonatomic) UITableView *table;

@end

@implementation FilterViewController

static NSString *const identifier = @"cellIdentifier";
static NSString *const all = @"All";
static NSString *const gender = @"Gender";
static NSString *const city = @"City";
static NSString *const nationality = @"Nationality";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Filter";
    [self dontShowBackButtonTitle];
    [self addOkButton];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initView {
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 * 4) style:UITableViewStylePlain];
    _table.tableFooterView = [[UIView alloc] init];
    _titleArray = @[all,gender,city,nationality];
    
    //init filter data
    _filterDic = [NSMutableDictionary dictionary];
    for(NSString *key in _titleArray) {
        [_filterDic setObject:@"" forKey:key];
    }
    if(!_all) {
        if(_gender == 1) {
            [_filterDic setObject:@"Male" forKey:gender];
        } else if(_gender == 0) {
            [_filterDic setObject:@"Female" forKey:gender];
        }
        
        if(!IsStringEmpty(_city)) {
            [_filterDic setObject:_city forKey:city];
        }
        
        if(_nationality) {
            [_filterDic setObject:_nationality.country_name_en forKey:nationality];
        }
    }
    
    [_table registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:identifier];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
}

- (void) addOkButton {
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithTitle:@"Ok" style:UIBarButtonItemStylePlain target:self action:@selector(okClick)];
    NSArray *rightButtonItems = @[okItem];
    self.navigationItem.rightBarButtonItems = rightButtonItems;
}

#pragma mark -uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            _all = YES;
            _filterDic = [NSMutableDictionary dictionary];
            for(NSString *key in _titleArray) {
                [_filterDic setObject:@"" forKey:key];
            }
            [_table reloadData];
            break;
        case 1: {
            //性别
            GenderViewController *controller = [[GenderViewController alloc] init];
            controller.genderChoosed = ^(NSInteger sex) {
                if(sex == 0) {
                    [_filterDic setObject:@"" forKey:gender];
                    _all = [self isAllFilter];
                    _gender = -1;
                } else {
                    _all = NO;
                    _gender = sex - 1;
                    [_filterDic setObject:((_gender == 0) ? @"Female" : @"Male") forKey:gender];
                }

                [_table reloadData];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:{
            //居住城市
            RegionViewController *controller = [[RegionViewController alloc] init];
            controller.regionType = RegionFilter;
            controller.allRegionFilterSelected = ^() {
                [_filterDic setObject:@"" forKey:city];
                _city = @"";
                _all = [self isAllFilter];
                [_table reloadData];
            };
            controller.regionSelected = ^(NSString *region) {
                _all = NO;
                [_filterDic setObject:region forKey:city];
                _city = region;
                [_table reloadData];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 3: {
            //国籍
            NationalityViewController *controller = [[NationalityViewController alloc] initWithNibName:@"NationalityViewController" bundle:nil];
            controller.enterSource = CONTACTS_FILTER;
            controller.nationChoosed = ^(Nationality *nation) {
                _all = NO;
                _nationality = nation;
                [_filterDic setObject:nation.country_name_en forKey:nationality];
                [_table reloadData];
            };
            controller.allNationhoosed = ^() {
                _nationality = nil;
                [_filterDic setObject:@"" forKey:nationality];
                _all = [self isAllFilter];
                [_table reloadData];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.cellDescriptionLabel.text = _titleArray[indexPath.row];
    cell.cellValueLabel.text = _filterDic[_titleArray[indexPath.row]];
    if(indexPath.row == 0) {
        if(_all) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - click events
- (void) okClick {
    if([_delegate respondsToSelector:@selector(setFilter : gender :  city : nationality : )]) {
        [_delegate setFilter:_all gender:_gender city:_city nationality:_nationality];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) isAllFilter {
    BOOL isAllFilter = YES;
    for(NSString *key in _filterDic.keyEnumerator) {
        NSString *value = _filterDic[key];
        if(!IsStringEmpty(value)) {
            isAllFilter = NO;
            break;
        }
    }
    
    return isAllFilter;
}

@end
