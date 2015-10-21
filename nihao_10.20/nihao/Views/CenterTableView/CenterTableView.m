//
//  CenterTableView.m
//  nihao
//
//  Created by HelloWorld on 7/20/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "CenterTableView.h"
#import "CenterTableViewCell.h"
#import "Constants.h"

@interface CenterTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;

@end

static NSString *CELL_IDENTIFIER = @"CenterTableViewCellIdentifier";
static NSInteger const CELL_HEIGHT = 50;

@implementation CenterTableView {
	NSArray *dataSource;
	NSInteger tableViewHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.maxWidth = 200;
		self.maxHeight = 500;
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void)configureViewWithDatas:(NSArray *)data {
	dataSource = data;
	
	self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
	self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	self.backgroundView.opaque = NO;
	[self addSubview:self.backgroundView];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
	[self.backgroundView addGestureRecognizer:tapGesture];
	
	tableViewHeight = dataSource.count * CELL_HEIGHT;
	tableViewHeight = tableViewHeight > self.maxHeight ? self.maxHeight : tableViewHeight;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.maxWidth, tableViewHeight)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [[UIView alloc] init];
	[self.tableView registerNib:[UINib nibWithNibName:@"CenterTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
	self.tableView.rowHeight = CELL_HEIGHT;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
	[self addSubview:self.tableView];
}

- (void)showInView:(UIView *)superView {
	self.frame = superView.bounds;
	self.tableView.center = self.center;
	[superView addSubview:self];
	[self animateViewShow:YES complete:nil];
}

#pragma mark - UIGestureRecognizer

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender {
	[self animateViewShow:NO complete:nil];
}

#pragma mark - Animation

- (void)animateViewShow:(BOOL)show complete:(void(^)())complete {
	if (show) {
//		CGRect frame = CGRectMake(CGRectGetMinX(self.tableView.frame), CGRectGetMinY(self.tableView.frame), self.maxWidth, tableViewHeight);
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
		}];
	} else {
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		} completion:^(BOOL finished) {
			[self removeFromSuperview];
		}];
	}
	
	if (complete) {
		complete();
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CenterTableViewCell *cell = (CenterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
	cell.label.text = dataSource[indexPath.row];
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self animateViewShow:NO complete:^{
		if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:withRowText:)]) {
			[self.delegate didSelectRowAtIndexPath:indexPath withRowText:dataSource[indexPath.row]];
		}
	}];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
