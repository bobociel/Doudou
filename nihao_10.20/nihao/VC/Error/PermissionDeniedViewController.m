//
//  PermissionDeniedViewController.m
//  nihao
//
//  Created by HelloWorld on 6/25/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PermissionDeniedViewController.h"

@interface PermissionDeniedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *permissionImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end

@implementation PermissionDeniedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	if (self.permissionDeniedType == PermissionDeniedTypePhotos) {
		self.title = @"Photos";
		self.permissionImageView.image = [UIImage imageNamed:@"img_permission_photos_denied"];
		self.hintLabel.text = @"Please go to Settings - Privacy - Photos to allow Nihao to access your Photos";
		
		UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
		self.navigationController.navigationItem.rightBarButtonItem = cancelBtn;
	} else {
		self.title = @"Mobile Contacts";
		self.permissionImageView.image = [UIImage imageNamed:@"img_permission_contacts_denied"];
		self.hintLabel.text = @"Please go to Settings - Privacy - Contacts to allow Nihao to access your Contacts";
		[self dontShowBackButtonTitle];
	}
}

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
