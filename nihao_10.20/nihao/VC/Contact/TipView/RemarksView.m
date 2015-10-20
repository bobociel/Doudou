//
//  RemarksView.m
//  demo
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 LP. All rights reserved.
//

#import "RemarksView.h"
#import <Masonry.h>
#import "UIColor+extend.h"

@interface RemarksView ()

//@property (nonatomic, strong) UITextField *textField;


@end

@implementation RemarksView
{
    UIView *_forRemarksView;
//    UITextField *_textField;
}

-(void)RemarksBtnClick:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(RemarksDelegateBtnClick:)]) {
        [self.delegate RemarksDelegateBtnClick:sender];
    }
}


-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.frame = frame;
        //[self addSetRemarks];
        //[self addSubview:_forRemarksView];
    }
    
    return self;
}
-(void)addSetRemarks{
   _forRemarksView =[[UIView alloc]initWithFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [_forRemarksView setBackgroundColor:[UIColor hexChangeFloat:@"000000" alpha:0.3f]];
    
    
    UIView *remarksView=[UIView new];
    remarksView.tag=122;
    remarksView.backgroundColor=[UIColor whiteColor];
    remarksView.layer.cornerRadius=2.f;
    [_forRemarksView addSubview:remarksView];
    [remarksView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_forRemarksView.mas_centerX);
        make.centerY.equalTo(_forRemarksView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(300, 160));
    }];
    
    UILabel *remarksTitleLable=[UILabel new];
    remarksTitleLable.text=@"Set Remarks";
    [remarksTitleLable setTextColor:[UIColor hexChangeFloat:@"323232"]];
    remarksTitleLable.font=FontNeveLightWithSize(14);
    [remarksView addSubview:remarksTitleLable];
    [remarksTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarksView.mas_top).offset(20);
        make.left.equalTo(remarksView.mas_left).offset(15);
        make.height.mas_equalTo(@14);
    }];
    
    UITextField *remarksText=[UITextField new];
    _textField=remarksText;
    remarksText.clearsOnBeginEditing = YES;
    remarksText.backgroundColor=[UIColor hexChangeFloat:@"f4f4f4"];
    [remarksText setBorderStyle:UITextBorderStyleNone];
    remarksText.textColor=[UIColor hexChangeFloat:@"323232"];
    remarksText.font=FontNeveLightWithSize(16);
    [remarksView addSubview:remarksText];
    [remarksText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarksTitleLable.mas_bottom).offset(20);
        make.centerX.equalTo(_forRemarksView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(230, 40));
    }];
    
    
    
    //设置按钮的边界颜色
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){158/255,158/255,158/255,0.1});
    UIButton *cancelBtn=[UIButton new];
    cancelBtn.tag=122;
    [cancelBtn.layer setBorderWidth:1.0];
    [cancelBtn.layer setBorderColor:color];
    [cancelBtn setTitle:@"Cancel" forState: UIControlStateNormal];
    cancelBtn.titleLabel.font=FontNeveLightWithSize(16);
    [cancelBtn setTitleColor:[UIColor hexChangeFloat:@"9E9E9E"]forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(RemarksBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    [remarksView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(remarksView.mas_bottom);
        make.left.equalTo(remarksView.mas_left);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    UIButton *OKBtn=[UIButton new];
     OKBtn.tag=123;
    
    [OKBtn.layer setBorderWidth:1.0];
    [OKBtn.layer setBorderColor:color];
    [OKBtn setTitle:@"OK" forState: UIControlStateNormal];
    OKBtn.titleLabel.font=FontNeveLightWithSize(16);
    [OKBtn setTitleColor:[UIColor hexChangeFloat:@"4AB7FD"]forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(RemarksBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    [remarksView addSubview:OKBtn];
    [OKBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(remarksView.mas_bottom);
        make.left.equalTo(cancelBtn.mas_right).offset(-1);
        make.size.mas_equalTo(CGSizeMake(151, 40));
    }];
    
    
}
-(void)OKBtnClick{
    
//    [self setFrame:CGRectMake(0,-self.bounds.size.height,self.bounds.size.width,self.bounds.size.height)];
    self.hidden = YES;
    
}

-(void)cancelBtnClick{
//    // [UIView animateWithDuration:0.0 animations:^{
//    
//    [self setFrame:CGRectMake(0,-self.bounds.size.height,self.bounds.size.width,self.bounds.size.height)];
//    _textField.text=nil;
//    // }];
    
    self.hidden = YES;
}
@end
