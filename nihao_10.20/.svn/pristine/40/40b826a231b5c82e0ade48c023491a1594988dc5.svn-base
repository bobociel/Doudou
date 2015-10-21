//
//  SettingMenu.m
//  nihao
//
//  Created by 刘志 on 15/7/3.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "SettingMenu.h"
#import "Constants.h"
#import "SettingMenuCell.h"

@interface SettingMenu()<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *_data;
}

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation SettingMenu

//table的宽度
static const NSInteger TABLE_WIDTH = 116;

static const NSInteger TABLE_MARGIN_RIGHT = 14;

//cell的高度
static const NSInteger CELL_HEIGHT = 35;

- (id) init {
    self = [super init];
    if(self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self addSubview:_bgView];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        recognizer.numberOfTouchesRequired = 1;
        [_bgView addGestureRecognizer:recognizer];
        
        _table = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - TABLE_WIDTH - TABLE_MARGIN_RIGHT, 0, TABLE_WIDTH, 0) style:UITableViewStylePlain];
        [_table registerNib:[UINib nibWithNibName:@"SettingMenuCell" bundle:nil] forCellReuseIdentifier:@"SettingMenuIdentifier"];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.delegate = self;
        _table.dataSource = self;
        _data = [NSMutableArray array];
        [self addSubview:_table];
        self.hidden = YES;
    }
    return self;
}

- (void) setData:(NSArray *)data {
    if(_data.count > 0) {
        [_data removeAllObjects];
    }
    [_data addObjectsFromArray:data];
    [_table reloadData];
}

- (void) removeFromSuperview {
    [super removeFromSuperview];
}

- (void) dismiss : (UITapGestureRecognizer *) recognizer {
    [self dismiss];
}

- (void) showInView:(UIView *)view {
    if(self.isHidden) {
        self.hidden = NO;
    }
    NSInteger tableHeight = CELL_HEIGHT * _data.count;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _table.frame;
        frame.size.height = tableHeight;
        _table.frame = frame;
    }];
}

- (void) dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _table.frame;
        frame.size.height = 0;
        _table.frame = frame;
    } completion:^(BOOL finished) {
		if (self.menuDismissed) {
			self.menuDismissed();
		}
        self.hidden = YES;
    }];
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.menuClickAtIndex(indexPath.row);
    [self dismiss];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingMenuIdentifier"];
    cell.label.text = _data[indexPath.row];
    return cell;
}

@end
