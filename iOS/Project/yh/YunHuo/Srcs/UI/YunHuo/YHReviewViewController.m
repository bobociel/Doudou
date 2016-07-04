//
//  YHReviewViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/23.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHReviewViewController.h"

@implementation YHReviewCell

@end

@interface YHReviewViewController ()

@end

@implementation YHReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHReviewCell" forIndexPath:indexPath];
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150;
}

//- (IBAction) onAdd
//{
//	[self showAddBoard];
//}
//
//
//- (void) showAddBoard
//{
//	self.addNewView.alpha = 0.0;
//	[UIView animateWithDuration:0.1 animations:^{
//		self.addInputBoard.center = CGPointMake(self.addNewView.bounds.size.width/2,self.addInputBoard.bounds.size.height/2);
//		[self.contentInputView becomeFirstResponder];
//		self.addNewView.alpha = 1.0;
//	}];
//	
//	UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNew)];
//	[self.navigationItem setLeftBarButtonItem:leftitem animated:YES];
//	
//	UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(createNew)];
//	[self.navigationItem setRightBarButtonItem:rightitem animated:YES];
//	
//	self.isAdddNew = YES;
//}
//
//- (void) hideAddBoard
//{
//	[UIView animateWithDuration:0.1 animations:^{
//		self.addInputBoard.center = CGPointMake(self.addNewView.bounds.size.width/2,-self.addInputBoard.bounds.size.height/2);
//		self.addNewView.alpha = 0.0;
//	}];
//	
//	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
//	[self.navigationItem setRightBarButtonItem:nil animated:YES];
//	
//	[self.contentInputView resignFirstResponder];
//	
//	self.isAdddNew = NO;
//}
//
//- (void) cancelNew
//{
//	[self hideAddBoard];
//}
//
//- (void) createNew
//{
//	[self hideAddBoard];
//}



@end
