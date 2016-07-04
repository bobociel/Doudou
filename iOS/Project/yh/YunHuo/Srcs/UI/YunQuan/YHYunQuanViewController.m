//
//  YHYunQuanViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunQuanViewController.h"
#import "YHFriendsListViewController.h"

@implementation YHYunQuanTopicCell

@end

@interface YHYunQuanViewController ()

@end

@implementation YHYunQuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	if ( self.isAdddNew )
	{
		[self.rzInputView becomeFirstResponder];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 14;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	YHYunQuanTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHYunQuanTopicCell" forIndexPath:indexPath];
	return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 180;
}

- (IBAction) onAdd
{
	[self showRZAddBoard];
	self.realNameCheckBtn.selected = NO;
}

- (IBAction)onRealName
{
	self.realNameCheckBtn.selected = !self.realNameCheckBtn.selected;
}

- (IBAction)onAt:(id)sender {
	YHFriendsListViewController *frdVC = [YHFriendsListViewController showFriendsList];
}

- (IBAction)onEmo:(id)sender {
}

- (IBAction)onImage:(id)sender
{
	
}

- (void) showRZAddBoard
{
	self.rzNewView.alpha = 0.0;
	[UIView animateWithDuration:0.3 animations:^{
		self.rzAddInputBoard.center = CGPointMake(self.rzNewView.bounds.size.width/2,self.rzAddInputBoard.bounds.size.height/2);
		[self.rzInputView becomeFirstResponder];
		self.rzNewView.alpha = 1.0;
	}];
	
	UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNew)];
	[self.navigationItem setLeftBarButtonItem:leftitem animated:YES];
	
	UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addNew)];
	[self.navigationItem setRightBarButtonItem:rightitem animated:YES];
	
	self.isAdddNew = YES;
}

- (void) hideRZAddBoard
{
	[UIView animateWithDuration:0.3 animations:^{
		self.rzAddInputBoard.center = CGPointMake(self.rzNewView.bounds.size.width/2,-self.rzAddInputBoard.bounds.size.height/2);
		self.rzNewView.alpha = 0.0;
	}];
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	
	[self.rzInputView resignFirstResponder];
	
	self.isAdddNew = NO;
}

- (void) cancelNew
{
	[self hideRZAddBoard];
}

- (void) addNew
{
	[self hideRZAddBoard];
}

- (void) kbWillShow:(NSNotification*)notif
{
	CGRect beginF = [notif.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect endF = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	float duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
	int curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] floatValue];
	
	//	self.rzAddInputKBExtView.center = CGPointMake(self.rzAddInputKBExtView.center.x,CGRectGetMinY(beginF)-self.rzAddInputKBExtView.bounds.size.height/2);
	[UIView animateWithDuration:duration delay:0.03 options:curve animations:^{
		self.rzAddInputKBExtView.center = CGPointMake(self.rzAddInputKBExtView.center.x,CGRectGetMinY(endF)-self.rzAddInputKBExtView.bounds.size.height/2 - 60);
	} completion:^(BOOL finished) {
	}];
}

- (void) kbWillHide:(NSNotification*)notif
{
	CGRect beginF = [notif.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect endF = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	float duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
	int curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] floatValue];
	
	//	self.rzAddInputKBExtView.center = CGPointMake(self.rzAddInputKBExtView.center.x,CGRectGetMinY(beginF)-self.rzAddInputKBExtView.bounds.size.height/2);
	[UIView animateWithDuration:duration delay:0 options:curve animations:^{
		self.rzAddInputKBExtView.center = CGPointMake(self.rzAddInputKBExtView.center.x,CGRectGetMinY(endF)-self.rzAddInputKBExtView.bounds.size.height/2);
	} completion:^(BOOL finished) {
	}];
}


@end
