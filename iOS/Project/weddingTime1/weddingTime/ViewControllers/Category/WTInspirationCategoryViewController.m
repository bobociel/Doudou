//
//  InspirationCategoryViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTInspirationCategoryViewController.h"
#import "GetService.h"
#import "UIImageView+WebCache.h"
#import "WTInspiretionListViewController.h"
#import "WTSearchViewController.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#define margin 10.f
#define colorSliderNavHeigh 44.f
#define colorBtnWidth 30.f
#define colorBtnmargin 10

@interface WTInspirationCategoryViewController ()<UICollectionViewDataSource>
{
    id data;
    NSArray *colorArr;
}
@end

@implementation WTInspirationCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRightBtnWithImage:[UIImage imageNamed:@"btn_search"]];
    self.title=@"婚礼灵感";
    [self.dataCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self loadData];
    [self initColorBtn];
    // Do any additional setup after loading the view from its nib.
}

-(void)rightNavBtnEvent
{
    [self.navigationController pushViewController:[WTSearchViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadData {
    [self showLoadingView];
    [GetService getInspiretionDefaultTagWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [NetWorkingFailDoErr removeAllErrorViewAtView:self.dataCollectionView];
        NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
        if (errorType==NetWorkStatusTypeNone) {
            
            data=result[@"data"];
            [self.dataCollectionView reloadData];
            if ([data count]==0) {
                [NetWorkingFailDoErr errWithView:self.dataCollectionView content:@"暂时没有标签哦" tapBlock:^{
                    [self loadData];
                }];
            }
        }
        else
        {
            NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@"暂时没有标签哦"];
            [WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
            [NetWorkingFailDoErr errWithView:self.dataCollectionView content:errorContent tapBlock:^{
                [self loadData];
            }];
        }
    }];
}

- (void)colorBtnEvent:(UIButton *)sender {
    WTInspiretionListViewController *searchVC = [[WTInspiretionListViewController alloc] init];
    searchVC.searchColor=colorArr[sender.tag];
    //    [searchVC loadData];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)initColorBtn {
    
    colorArr = [WeddingTimeAppInfoManager defaultInspirationColors];
    self.colorNavScrollView.contentSize =CGSizeMake(margin*2+colorBtnWidth*colorArr.count+colorBtnmargin*(colorArr.count-1), self.colorNavScrollView.contentSize.height);
    self.colorNavScrollView.showsVerticalScrollIndicator   = NO;
    self.colorNavScrollView.showsHorizontalScrollIndicator = NO;
    self.colorNavScrollView.bounces=YES;
    self.colorNavScrollView.scrollsToTop=NO;
    for (int i=0; i<colorArr.count; i++) {
        UIButton *colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, colorBtnWidth, colorBtnWidth)];
        colorBtn.left=margin+i*colorBtnWidth+i*colorBtnmargin;
        colorBtn.layer.cornerRadius=colorBtn.height/2.f;
        colorBtn.centerY=self.colorNavScrollView.height/2.f;
        colorBtn.backgroundColor=[LWUtil colorWithHexString:colorArr[i][@"value"]];
        colorBtn.tag=i;
        [self.colorNavScrollView addSubview:colorBtn];
        [colorBtn addTarget:self action:@selector(colorBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        if ([colorArr[i][@"value"] isEqualToString:@"#fefefe"]) {
            colorBtn.layer.borderColor=[LWUtil colorWithHexString:@"dddddd"].CGColor;
            colorBtn.layer.borderWidth=1.f;
        }
    }
    [self.dataCollectionView reloadData];
}


#pragma mark - collectionViewDelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [data count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.width, cell.height)];
    [cell.contentView removeAllSubviews];

	imageView.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	[imageView setImageUsingProgressViewRingWithURL:[NSURL URLWithString:[LWUtil getString:data[indexPath.item][@"link"] andDefaultStr:@""]]
								   placeholderImage:nil
											options:SDWebImageRetryFailed
										   progress:nil
										  completed:nil
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];

    [cell.contentView addSubview:imageView];
    
    UILabel *tabLable      = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 16)];
    tabLable.width         = cell.width-13;
    tabLable.top           = cell.height-15-16;
    tabLable.centerX       = cell.width/2.f;
    tabLable.textAlignment = NSTextAlignmentLeft;
    tabLable.numberOfLines = 1;
    tabLable.textColor=[UIColor whiteColor];
    tabLable.lineBreakMode = NSLineBreakByWordWrapping;
    tabLable.text= [LWUtil getString:data[indexPath.item][@"tag"] andDefaultStr:@"标签"];
    tabLable.font          = defaultFont16;
    [cell.contentView addSubview:tabLable];
    cell.layer.cornerRadius = 5.f;
    cell.clipsToBounds=YES;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((screenWidth-3*margin)/2.f, (screenWidth-3*margin)/2.f);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, margin, margin, margin);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WTInspiretionListViewController *searchVC = [[WTInspiretionListViewController alloc] init];
    searchVC.searchTag= [LWUtil getString:data[indexPath.item][@"tag"] andDefaultStr:@"标签"];
    //  [searchVC loadData];
    [self.navigationController pushViewController:searchVC animated:YES];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end