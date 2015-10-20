//
//  ViewController.m
//  PhotoDemo
//
//  Created by hangzhou on 15/9/24.
//  Copyright © 2015年 hangzhou. All rights reserved.
//

#import "ViewController.h"
#import "PhotoViewController.h"
#import "JSONModel/JSONModelLib.h"
#import "AFNetworking/AFNetworking.h"
#import "Note.h"
#define Token  @"TGT-106-sKxUQcyexMNaZaH4k6Undd6Q2M3hxttOf5m61gFYzrfTkeRhAS-cas"
//@"TGT-839-MexlD1TlUgDxb0sSeofkeImCAsqWbm4mEEcgQNHanUWwt0WIUq-cas"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) ALAssetsLibrary *assetLibrary;
@property (nonatomic,retain) NSMutableArray *groups;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,retain) NSMutableArray *noteArray;
@end

@implementation ViewController

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"相册";
    self.noteArray = [NSMutableArray array];
    
    self.assetLibrary = [self.class defaultAssetsLibrary];
    self.groups = [NSMutableArray array] ;
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            [self.groups addObject:group];
        }
        else
        {
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
    [self setupTableView];
    
    //[self setupButton];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = Token;
    [[AFHTTPRequestOperationManager manager] GET:@"http://dev.yunhuoer.com/yunhuo-api/api/ver1.00/note" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [responseObject[@"data"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Note *note = [[Note alloc] initWithDictionary:obj error:nil];
            [self.noteArray addObject:note];
        }];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",error.debugDescription);
    }];
}

- (void)setupButton
{
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeSystem];
    openButton.frame = CGRectMake(0, 80, 100, 40);
    [openButton setTitle:@"打开相册" forState:UIControlStateNormal];
    [self.view addSubview:openButton];
    [openButton addTarget:self action:@selector(openAlbum:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)openAlbum:(UIButton *)btn
{
    UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
    pickerViewController.delegate = self;
    pickerViewController.allowsEditing = YES;
    pickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    pickerViewController.navigationBar.barStyle = UIBarStyleBlack;
    pickerViewController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.noteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    ALAssetsGroup *group = self.groups[indexPath.row];
//    
//    CGImageRef posterImage      = group.posterImage;
//    size_t height               = CGImageGetHeight(posterImage);
//    float scale                 = height / 78.0;
    
//    cell.imageView.image = [UIImage imageWithCGImage:group.posterImage scale:scale orientation:UIImageOrientationUp];
//    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)group.numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",[self.noteArray[indexPath.row] voice] == nil] ;
//    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.noteArray[indexPath.row] note_id]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PhotoViewController *vc = [[PhotoViewController alloc] init];
//    vc.group = self.groups[indexPath.row];
//    [self.navigationController pushViewController:vc animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
