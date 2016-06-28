//
//  YHProjectsViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHProjectsViewController.h"
#import "YHProject.h"
#import "YHConfig.h"

@implementation YHProjectCell

- (void) setProject:(YHProject *)project
{
	_project = project;
	self.projectLogo.image = project.logo;
	self.projectTitle.text = project.title;
}

@end

@interface YHProjectsViewController ()<UIAlertViewDelegate,SKSTableViewDelegate>
@property (nonatomic) NSMutableArray *selectStatus;

@end

@implementation YHProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.selectStatus = [NSMutableArray array];
	if ( self.projects == nil )
	{
		self.projects = [YHDataCache instance].projects;
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ( self.projects.count == 0 && ![YHConfig instance].projectsLanuchedBefore )
	{
		[YHConfig instance].projectsLanuchedBefore = YES;
		[[YHConfig instance] save];
		[self showProjectCreate:nil];
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
	
	self.combineBtn.hidden = self.projects.count <= 1;
}

- (IBAction)showProjectCreate:(id)sender
{
	UIViewController *createVC = [[UIStoryboard storyboardWithName:@"YunHuo" bundle:nil] instantiateViewControllerWithIdentifier:@"ProjectCreateVC"];
	[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:createVC animated:YES completion:nil];
}

- (IBAction)onCombine:(id)sender
{
	self.isInCombine = YES;
	self.actionBoard.hidden = YES;
	self.combineBoard.hidden = NO;
	self.tableView.allowsMultipleSelection = YES;
	[self.tableView reloadData];
}

- (IBAction)onClock:(id)sender
{
	
}

- (IBAction)onCancelCombine:(id)sender {
	self.isInCombine = NO;
	self.actionBoard.hidden = NO;
	self.combineBoard.hidden = YES;
	self.tableView.allowsMultipleSelection = NO;
	[self.tableView reloadData];
	[self.selectStatus removeAllObjects];
}

- (IBAction)onDoCombine:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入名字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alertView show];
}

- (void) doCombine:(NSString*)name
{
	NSMutableArray *projs = [NSMutableArray array];
	for ( NSNumber *index in self.selectStatus )
	{
		[projs addObject:self.projects[[index integerValue]]];
	}
	YHProject *proj = [YHProject combineProjects:projs withName:name];
	[self.projects removeObjectsInArray:projs];
	[self.projects addObject:proj];
	
	[[YHDataCache instance] save];
	
	self.actionBoard.hidden = NO;
	self.combineBoard.hidden = YES;
	self.tableView.allowsMultipleSelection = NO;
	[self.tableView reloadData];
	[self.selectStatus removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	self.isInCombine = NO;
	if ( buttonIndex == alertView.cancelButtonIndex )
	{
		[self onCancelCombine:nil];
	}
	else
	{
		UITextField *tf = [alertView textFieldAtIndex:0];
		[self doCombine:tf.text];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.projects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	YHProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHProjectCell" forIndexPath:indexPath];
	YHProject *proj = self.projects[indexPath.row];
	cell.project = proj;
	cell.isExpandable = proj.subProjects.count > 0;
	cell.selectedMark.hidden = !self.isInCombine;
	cell.selectedMark.highlighted = [self.selectStatus indexOfObject:@(indexPath.row)] != NSNotFound;
	cell.accessoryType = tableView.allowsMultipleSelection?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 73;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( tableView.allowsMultipleSelection )
	{
		if ( [self.selectStatus indexOfObject:@(indexPath.row)] == NSNotFound )
		{
			[self.selectStatus addObject:@(indexPath.row)];
		}
		else
		{
			[self.selectStatus removeObject:@(indexPath.row)];
		}
		[tableView beginUpdates];
		[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		[tableView endUpdates];
	}
	else
	{
		YHProjectCell *cell = (YHProjectCell*)[tableView cellForRowAtIndexPath:indexPath];
		YHProject *project = cell.project;
		if ( project.subProjects.count == 0 )
		{
			//select project
			[self performSegueWithIdentifier:@"showProject" sender:nil];
		}
		else
		{
//			self.projects = project.subProjects;
//			[self.tableView reloadData];
		}
	}
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
	YHProject *proj = self.projects[indexPath.row];
	return proj.subProjects.count;
}

- (UITableViewCell *)tableView:(SKSTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
	YHProject *proj = self.projects[indexPath.row];
	YHProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHProjectCell" forIndexPath:indexPath];
	if ( indexPath.subRow < proj.subProjects.count )
	{
		proj = proj.subProjects[indexPath.row];
		cell.project = proj;
		cell.isExpandable = proj.subProjects.count > 0;
		cell.selectedMark.hidden = !self.isInCombine;
		cell.selectedMark.highlighted = [self.selectStatus indexOfObject:@(indexPath.row)] != NSNotFound;
		cell.accessoryType = tableView.allowsMultipleSelection?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;

}

@end
