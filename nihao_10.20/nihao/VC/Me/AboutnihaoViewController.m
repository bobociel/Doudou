//
//  AboutnihaoViewController.m
//  nihao
//
//  Created by YW on 15/7/6.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "AboutnihaoViewController.h"
#import "DWTagList.h"
@interface AboutnihaoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollContainer;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet DWTagList *tagView;
@end

@implementation AboutnihaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    [self.tagView setTags:@[@"1",@"3"]];
    self.title = @"About Nihao";
    self.view.backgroundColor=ColorWithRGB(255, 255, 255);
    _scrollContainer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_contentView.frame));
    [_scrollContainer addSubview:_contentView];
    _scrollContainer.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetHeight(_contentView.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
