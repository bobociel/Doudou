//
//  AboutLovewithViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTAboutLovewithViewController.h"

@interface WTAboutLovewithViewController ()

@end

@implementation WTAboutLovewithViewController
{
    UIImageView *logoImageView;
    UILabel     *versionLabel;
    UILabel     *sinaLabel;
    UILabel     *tencentLabel;
    UILabel     *weichatLabel;
    UILabel     *companyLabel;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title=@"关于婚礼时光";
    self.view.backgroundColor=[UIColor whiteColor];
    logoImageView=[[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-90)/2, 100, 90, 90)];
    logoImageView.image=[UIImage imageNamed:@"icon_logo"];
    [self.view addSubview:logoImageView];
    versionLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-66)/2, logoImageView.bottom+20, 66, 20)];
    versionLabel.backgroundColor=[UIColor clearColor];
    versionLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.5];
    versionLabel.textAlignment=NSTextAlignmentCenter;
    versionLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    versionLabel.text=[NSString stringWithFormat:@"版本:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ];
    [self.view addSubview:versionLabel];
    
    sinaLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-166)/2, logoImageView.bottom+40, 166, 20)];
    sinaLabel.backgroundColor=[UIColor clearColor];
    sinaLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8];
    sinaLabel.textAlignment=NSTextAlignmentCenter;
    sinaLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    sinaLabel.text=@"新浪微博:我的婚礼时光";
    [self.view addSubview:sinaLabel];
    
    tencentLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-166)/2, sinaLabel.bottom+10, 166, 20)];
    tencentLabel.backgroundColor=[UIColor clearColor];
    tencentLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8];
    tencentLabel.textAlignment=NSTextAlignmentCenter;
    tencentLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    tencentLabel.text=@"腾讯微博:婚礼时光";
    [self.view addSubview:tencentLabel];
    
    weichatLabel=[[UILabel alloc]initWithFrame:CGRectMake((screenWidth-166)/2, tencentLabel.bottom+10, 166, 20)];
    weichatLabel.backgroundColor=[UIColor clearColor];
    weichatLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8];
    weichatLabel.textAlignment=NSTextAlignmentCenter;
    weichatLabel.font=[WeddingTimeAppInfoManager fontWithSize:12];
    weichatLabel.text=@"微信号:lovewith_me";
    [self.view addSubview:weichatLabel];
    
    companyLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bottom-100, screenWidth, 20)];
    companyLabel.backgroundColor=[UIColor clearColor];
    companyLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8];
    companyLabel.textAlignment=NSTextAlignmentCenter;
    companyLabel.font=[WeddingTimeAppInfoManager fontWithSize:11];
    companyLabel.text= @"Copyright © 2012-2015 Lovewith.Me All Rights Reserved"; //@"@ lovewith.me All rights reserver";
    [self.view addSubview:companyLabel];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
