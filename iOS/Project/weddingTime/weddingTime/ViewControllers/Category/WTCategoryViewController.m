//
//  CategoryViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <POP/POP.h>
#import "WTCategoryViewController.h"
#import "WTInspirationCategoryViewController.h"
#import "WTSHViewController.h"
#import "SliderListVCManager.h"
#import "NSString+QHNSStringCtg.h"
#import "UIImage+YYAdd.h"
@interface WTCategoryViewController ()<UIScrollViewDelegate>

@end

@implementation WTCategoryViewController
{
    NSMutableArray *categoryBtns;
    UIScrollView *baseScrollView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBlurBackgroundView];
    [self initButtons];
}

-(void)changeBackgroundImage{
    [self showBlurBackgroundView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#define btnSize CGSizeMake(80, 102)
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t onece;
    dispatch_once(&onece, ^{
        int lineNum=3;
        
        CGFloat p=1.5;//倍数
        CGFloat horizontalPaddingBorder=(self.view.width-btnSize.width*lineNum)/(p*(lineNum-1)+2);//按钮距离屏幕左右边缘距离
        CGFloat horizontalPadding=horizontalPaddingBorder*p;//按钮之间水平的距离
        
        CGFloat listSpeedDif=3.5;
        CGFloat lineSpeedDif=3;
        
        CGFloat xDif=horizontalPadding+btnSize.width;//相邻左右按钮x坐标的差
        CGFloat yDif=146;//相邻上下按钮x坐标的差
        
        CGFloat minEndY=25;//按钮最终位置y最小值
        CGFloat paddingTopBottomDis=138-67;//上下边距差
        
        int num=(int)((categoryBtns.count+lineNum-1)/lineNum);
        CGFloat allHeight=(num-1)*yDif+btnSize.height;
        CGFloat firstEndY=(baseScrollView.height-paddingTopBottomDis-allHeight)/2;
        if (firstEndY<minEndY) {
            firstEndY=minEndY;
            paddingTopBottomDis=0;
        }
        CGFloat contentSizeHeight=allHeight+firstEndY*2+paddingTopBottomDis;
        if (contentSizeHeight<=baseScrollView.height&&paddingTopBottomDis==0) {
            contentSizeHeight=baseScrollView.height+1;
        }
        
        baseScrollView.contentSize=CGSizeMake(0, contentSizeHeight + 30);
		baseScrollView.showsVerticalScrollIndicator = NO;

        CGPoint firstBeginPoint=CGPointMake(horizontalPaddingBorder+btnSize.width/2, self.view.height+10);
        CGPoint firstEndPoint=CGPointMake(horizontalPaddingBorder+btnSize.width/2, firstEndY+btnSize.height/2);
        for (int i=0; i<categoryBtns.count; i++) {
            int x=i%lineNum;
            int y=i/lineNum;
            UIButton *btn=categoryBtns[i];
            btn.center=CGPointMake(firstBeginPoint.x+x*xDif, firstBeginPoint.y+y*yDif);
            [baseScrollView addSubview:btn];
            
            POPSpringAnimation *transformTopAnimation    = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
            
            transformTopAnimation.toValue                = @(firstEndPoint.y+y*yDif);
            transformTopAnimation.dynamicsTension        =45-x*listSpeedDif-y*lineSpeedDif;
            transformTopAnimation.dynamicsFriction=10;
            transformTopAnimation.dynamicsMass=1.4;
            [btn.layer pop_addAnimation:transformTopAnimation forKey:nil];
        }
    });
}

-(void)plan_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypePlan;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)photo_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypePhoto;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)follow_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeCapture;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)holder_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeHost;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)choth_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeDress;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)sculpt_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeMakeUp;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)video_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeVideo;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)hotel_selected
{
    WTSHViewController *sh = [[WTSHViewController alloc] init];
    sh.supplier_type = WTWeddingTypeHotel;
    [self.navigationController pushViewController:sh animated:YES];
}

-(void)inspiration_selected
{
    WTInspirationCategoryViewController *next = [[WTInspirationCategoryViewController alloc]initWithNibName:@"WTInspirationCategoryViewController" bundle:nil];
    [self.navigationController pushViewController:next animated:YES];
}

-(void)initButtons
{
    baseScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    baseScrollView.delegate = self;
    [self.view addSubview:baseScrollView];
    
    categoryBtns=[[NSMutableArray alloc]initWithCapacity:10];
    NSArray *array=[[NSArray alloc]initWithObjects:
                    @{@"image":@"category_wedding_plan",@"text":@"婚礼策划",@"action":@"plan_selected",@"image_selected":@"category_wedding_plan_selected"}
                    ,@{@"image":@"category_wedding_photo",@"text":@"婚纱写真",@"action":@"photo_selected",@"image_selected":@"category_wedding_photo_selected"}
                    ,@{@"image":@"category_wedding_follow",@"text":@"婚礼摄影",@"action":@"follow_selected",@"image_selected":@"category_wedding_follow_selected"}
                    ,@{@"image":@"category_wedding_holder",@"text":@"婚礼主持",@"action":@"holder_selected",@"image_selected":@"category_wedding_holder_selected"}
                    ,@{@"image":@"category_wedding_choth",@"text":@"婚纱礼服",@"action":@"choth_selected",@"image_selected":@"category_wedding_choth_selected"}
                    ,@{@"image":@"category_wedding_sculpt",@"text":@"新娘跟妆",@"action":@"sculpt_selected",@"image_selected":@"category_wedding_sculpt_selected"}
                    ,@{@"image":@"category_wedding_video",@"text":@"婚礼摄像",@"action":@"video_selected",@"image_selected":@"category_wedding_video_selected"}
                    ,@{@"image":@"category_wedding_hotel",@"text":@"婚宴酒店",@"action":@"hotel_selected",@"image_selected":@"category_wedding_hotel_selected"}
                    ,@{@"image":@"category_wedding_inspiration",@"text":@"婚礼灵感",@"action":@"inspiration_selected",@"image_selected":@"category_wedding_inspiration_selected"}
//                     ,@{@"image":@"",@"text":@"新人话题",@"action":@"",@"image_selected":@""}
                    , nil];
    for (NSDictionary *dic in array) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.size=btnSize;
        [btn setImage:[UIImage imageNamed:dic[@"image"]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:dic[@"image_selected"]] forState:UIControlStateHighlighted];
        
        [btn setTitle:[LWUtil getString:dic[@"text"]andDefaultStr:@""] forState:UIControlStateNormal];
        [btn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:16];
        
        UIImage *oneDcodeImage = [btn imageForState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -oneDcodeImage.size.width,-(btn.size.height-12), 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-(btn.size.height-oneDcodeImage.size.height) , btn.size.width/2- oneDcodeImage.size.width/2, 0, 0)];
        
        SEL target=NSSelectorFromString([LWUtil getString:dic[@"action"] andDefaultStr:@""]) ;
        if (target) {
            [btn addTarget:self action:target forControlEvents:UIControlEventTouchUpInside];
        }
        
        [categoryBtns addObject:btn];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y < 0)
	{
		UIImage *back=[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
		if (!back) {
			back = [UIImage imageNamed:@"Bitmap.jpg"];
		}

		float state = (170 + scrollView.contentOffset.y) / 170;
		if (state >= 0.169) {
			UIImage *blImage = [back imageByBlurRadius:state * 40 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
			[self setBlurImageViewWithImage:blImage state:state];
		}
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
@end
