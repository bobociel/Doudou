//
//  FSDropDownMenu.m
//  FSDropDownMenu
//
//  Created by xiang-chen on 14/12/17.
//  Copyright (c) 2014年 chx. All rights reserved.
//

#import "FSDropDownMenu.h"
#import "Constants.h"

#define LeftTableViewTag 1101
#define RightTableViewTag 1102
#define LeftTableViewWidthRatio 0.5
#define RightTableViewWidthRatio 0.5

struct MySelectedRows {
    long leftRow;
    long rightRow;
};
typedef struct MySelectedRows MySelectedRows;

@interface FSDropDownMenu()

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic) NSIndexPath *selectedLeftIndexPath;
@property (nonatomic) NSIndexPath *selectedRightIndexPath;

@property (nonatomic, assign) MySelectedRows mySelectedRows;

@end

#define ScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)

@implementation FSDropDownMenu {
    NSIndexPath *nearbyDefaultSelectedIndexPath;
    BOOL hasSelected;
    BOOL hasNearby;
}

static NSString *identifier = @"DropDownMenuCell";

#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, 0)];
    if (self) {
        _origin = origin;
        _show = NO;
        _height = height;
        _selectedLeftIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        _selectedRightIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        nearbyDefaultSelectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        hasSelected = NO;
        hasNearby = NO;
        _mySelectedRows.leftRow = 0;
        _mySelectedRows.rightRow = -1;
        _lastChooseLeftRow = 0;
        _currentSelectedLeftRow = 0;
        
        //tableView init
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, ScreenWidth * LeftTableViewWidthRatio, 0) style:UITableViewStylePlain];
        [_leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        _leftTableView.rowHeight = 40;
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
		_leftTableView.tag = LeftTableViewTag;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.backgroundColor = RootBackgroundWhitelyColor;
        
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x+ScreenWidth*LeftTableViewWidthRatio, self.frame.origin.y + self.frame.size.height, ScreenWidth*LeftTableViewWidthRatio, 0) style:UITableViewStylePlain];
        [_rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        _rightTableView.rowHeight = 30;
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
		_rightTableView.tag = RightTableViewTag;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_rightTableView.backgroundColor = [UIColor whiteColor];
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5)];
        bottomShadow.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bottomShadow];
    }
    return self;
}



#pragma mark - gesture handle

- (void)menuTapped{
    if (!_show) {
        [self.leftTableView selectRowAtIndexPath:_selectedLeftIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self animateBackGroundView:self.backGroundView show:!_show complete:^{
        [self animateTableViewShow:!_show complete:^{
            [self tableView:self.leftTableView didSelectRowAtIndexPath:_selectedLeftIndexPath];
            _show = !_show;
        }];
    }];
}

- (void)hide{
    [self backgroundTapped:nil];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableViewShow:NO complete:^{
            _show = NO;
        }];
    }];
}

#pragma mark - animation method


- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTableViewShow:(BOOL)show complete:(void(^)())complete {
    if (show) {
        _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y, ScreenWidth*LeftTableViewWidthRatio, 0);
        [self.superview addSubview:_leftTableView];
        _rightTableView.frame = CGRectMake(self.origin.x+ScreenWidth*0.7, self.frame.origin.y, ScreenWidth*LeftTableViewWidthRatio, 0);
        [self.superview addSubview:_rightTableView];
        _leftTableView.alpha = 1.f;
        _rightTableView.alpha = 1.f;
        [UIView animateWithDuration:0.2 animations:^{
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y, ScreenWidth*LeftTableViewWidthRatio, _height);
            _rightTableView.frame = CGRectMake(self.origin.x+ScreenWidth*LeftTableViewWidthRatio, self.frame.origin.y, ScreenWidth*LeftTableViewWidthRatio, _height);
            if (self.transformView) {
                self.transformView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _leftTableView.alpha = 0.f;
            _rightTableView.alpha = 0.f;
            if (self.transformView) {
                self.transformView.transform = CGAffineTransformMakeRotation(0);
            }
        } completion:^(BOOL finished) {
            [_leftTableView removeFromSuperview];
            [_rightTableView removeFromSuperview];
        }];
    }
    complete();
}


#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:tableView:numberOfRowsInSection:)]) {
        return [self.dataSource menu:self tableView:tableView
                numberOfRowsInSection:section];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSAssert(self.dataSource != nil, @"menu's datasource shouldn't be nil");
    NSString *title;
    if ([self.dataSource respondsToSelector:@selector(menu:tableView:titleForRowAtIndexPath:)]) {
        title = [self.dataSource menu:self tableView:tableView titleForRowAtIndexPath:indexPath];
        cell.textLabel.text = [title componentsSeparatedByString:@"_"][0];
    } else {
        NSAssert(0 == 1, @"dataSource method needs to be implemented");
    }
    if(tableView == _leftTableView) {
        if ([@"Nearby" isEqualToString:title]) {
            hasNearby = YES;
        }
    }
    
    if(tableView == _rightTableView) {
        if (hasNearby && !hasSelected && _mySelectedRows.leftRow == 0) {
            _mySelectedRows.rightRow = 3;
        } else {
            _mySelectedRows.rightRow = -1;
        }
    }
    
    if(tableView == _rightTableView) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = TextColor575757;
        if (indexPath.row == _mySelectedRows.rightRow || (hasSelected && indexPath == _selectedRightIndexPath && _lastChooseLeftRow == _currentSelectedLeftRow)) {
            [cell.textLabel setHighlighted:YES];
            [cell.detailTextLabel setHighlighted:YES];
        } else {
            [cell.textLabel setHighlighted:NO];
            [cell.detailTextLabel setHighlighted:NO];
        }
        if ([title componentsSeparatedByString:@"_"].count > 1) {
            cell.detailTextLabel.text = [title componentsSeparatedByString:@"_"][1];
            cell.detailTextLabel.textColor = TextColor575757;
            cell.detailTextLabel.font = FontNeveLightWithSize(12.0);
            cell.detailTextLabel.highlightedTextColor = AppBlueColor;
        }
    } else {
        UIView *sView = [[UIView alloc] init];
        sView.backgroundColor = [UIColor whiteColor];
        // 蓝色方块
        UIView *slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 40)];
        slideView.backgroundColor = AppBlueColor;
        [sView addSubview:slideView];
        cell.selectedBackgroundView = sView;
        // [cell setSelected:YES animated:NO];
        cell.backgroundColor = RootBackgroundWhitelyColor;
//		cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = HomeCategoryUnSelectedTextColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.textLabel.font = FontNeveLightWithSize(12.0);
    cell.separatorInset = UIEdgeInsetsZero;
    
    cell.textLabel.highlightedTextColor = AppBlueColor;
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate || [self.delegate respondsToSelector:@selector(menu:tableView:didSelectRowAtIndexPath:)]) {
        if (tableView == self.rightTableView) {
            _mySelectedRows.rightRow = indexPath.row;
            hasSelected = YES;
            _lastChooseLeftRow = _currentSelectedLeftRow;
            _selectedRightIndexPath = indexPath;
            [self animateBackGroundView:_backGroundView show:NO complete:^{
                [self animateTableViewShow:NO complete:^{
                    _show = NO;
                }];
            }];
        } else {
            _mySelectedRows.leftRow = indexPath.row;
            _currentSelectedLeftRow = (int)indexPath.row;
            _selectedLeftIndexPath = indexPath;
        }
        [self.delegate menu:self tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        //TODO: delegate is nil
    }
}

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"tableView == _rightTableView = %@, indexPath.row = %ld, self.selectedRightRow = %ld", tableView == _rightTableView ? @"YES" : @"NO", indexPath.row, self.selectedRightRow);
//    if(tableView == _rightTableView && indexPath.row == self.selectedRightRow){
//        return YES;
//    } else {
//        return NO;
//    }
//}

//- (void)setSelectedRightTableViewIndexPath:(NSIndexPath *)indexPath {
//    _selectedRightIndexPath = indexPath;
//}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
