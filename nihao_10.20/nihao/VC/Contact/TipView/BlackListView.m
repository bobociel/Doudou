//
//  blackListView.m
//  demo
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 LP. All rights reserved.
//

#import "BlackListView.h"
#import "UIColor+extend.h"
#import <Masonry.h>

@implementation BlackListView
{
    UIView *_forBlackView;

}

-(instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.frame = frame;
        //[self addBlackView];
        //[self addSubview:_forBlackView];
    }
    
    return self;
}

-(void)BlackListBtnClick:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(BlackListBtnDelegateBtnClick:)]) {
        [self.delegate BlackListBtnDelegateBtnClick:sender];
    }
}

-(void)addBlackView{
    
    _forBlackView =[[UIView alloc]initWithFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    _forBlackView.userInteractionEnabled=YES;
    [_forBlackView setBackgroundColor:[UIColor hexChangeFloat:@"000000" alpha:0.3f]];
  
    UIView *blackListView=[UIView new];
    blackListView.tag=122;
    blackListView.backgroundColor=[UIColor whiteColor];
    blackListView.layer.cornerRadius=2.f;
    [_forBlackView addSubview:blackListView];
    [blackListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_forBlackView.mas_centerX);
        make.centerY.equalTo(_forBlackView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(300, 180));
    }];
    
    UILabel *blackListLable=[UILabel new];
    blackListLable.text=@"Blacklist";
    [blackListLable setTextColor:[UIColor hexChangeFloat:@"323232"]];
    blackListLable.font = FontNeveLightWithSize(14);
    [blackListView addSubview:blackListLable];
    [blackListLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blackListView.mas_top).offset(20);
        make.left.equalTo(blackListView.mas_left).offset(15);
        make.height.mas_equalTo(@14);
    }];
    
    UILabel *textLabel=[UILabel new];
    textLabel.text=@"Do you really want to block this person from sending you messages and seeing your  Moments updates ";
    textLabel.font=FontNeveLightWithSize(14);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textLabel.text length])];
    textLabel.attributedText = attributedString;
    [textLabel sizeToFit];
    //textLabel.textAlignment = UIControlContentVerticalAlignmentTop;
    //textLabel.lineBreakMode = UILineBreakModeWordWrap;
    [textLabel setTextColor:[UIColor hexChangeFloat:@"787878"]];
    textLabel.numberOfLines = 0;//多行显示
    [_forBlackView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blackListLable.mas_bottom).offset(5);
        make.left.equalTo(blackListView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(290, 80));
    }];
    
    //设置按钮的边界颜色
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){158/255,158/255,158/255,0.1});
    
    UIButton *cancelBtn=[UIButton new];
    cancelBtn.tag=122;
    [cancelBtn.layer setBorderWidth:1.0];
    [cancelBtn.layer setBorderColor:color];
    [cancelBtn setTitle:@"Cancel" forState: UIControlStateNormal];
    cancelBtn.titleLabel.font = FontNeveLightWithSize(16);
    [cancelBtn setTitleColor:[UIColor hexChangeFloat:@"9E9E9E"]forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(BlackListBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    [blackListView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(blackListView.mas_bottom);
        make.left.equalTo(blackListView.mas_left);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    UIButton *OKBtn=[UIButton new];
    OKBtn.tag=123;
    [OKBtn.layer setBorderWidth:1.0];
    [OKBtn.layer setBorderColor:color];
    [OKBtn setTitle:@"OK" forState: UIControlStateNormal];
    OKBtn.titleLabel.font = FontNeveLightWithSize(16);
    
    [OKBtn setTitleColor:[UIColor hexChangeFloat:@"4AB7FD"]forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(BlackListBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    [blackListView addSubview:OKBtn];
    [OKBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(blackListView.mas_bottom);
        make.left.equalTo(cancelBtn.mas_right).offset(-1);
        make.size.mas_equalTo(CGSizeMake(151, 40));
    }];
    
}
//-(void)OKBtnClick{
//    
//    [self setFrame:CGRectMake(0,-self.bounds.size.height,self.bounds.size.width,self.bounds.size.height)];
//    
//}
//
//-(void)cancelBtnClick{
//    // [UIView animateWithDuration:0.0 animations:^{
//    
//    [self setFrame:CGRectMake(0,-self.bounds.size.height,self.bounds.size.width,self.bounds.size.height)];
//       // }];
//}

@end
