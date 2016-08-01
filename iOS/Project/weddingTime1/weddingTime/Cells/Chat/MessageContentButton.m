//
//  MessageContentButton.m
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "MessageContentButton.h"
#import "LWUtil.h"

@implementation MessageContentButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backImageView                        = [[UIImageView alloc]init];
        self.backImageView.userInteractionEnabled = YES;
//        self.backImageView.layer.cornerRadius     = 20-backImageLeftMargin;
//        self.backImageView.layer.masksToBounds    = YES;
        self.backImageView.contentMode=UIViewContentModeScaleAspectFill;
        [self addSubview:self.backImageView];
        
        //语音
        self.voiceBackView = [[UIView alloc]init];
        
        [self addSubview:self.voiceBackView];
        self.second = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.second.textAlignment = NSTextAlignmentCenter;
        self.second.font = [UIFont systemFontOfSize:14];
        self.voice = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        
        self.voice.animationDuration    = 1;
        self.voice.animationRepeatCount = 0;
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.center=CGPointMake(80, 15);
        
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.voice];
        [self.voiceBackView addSubview:self.second];
        
        self.backImageView.userInteractionEnabled = NO;
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled        = NO;
        self.voice.userInteractionEnabled         = NO;

        self.second.backgroundColor        = [UIColor clearColor];
        self.voice.backgroundColor         = [UIColor clearColor];
        self.voiceBackView.backgroundColor = [UIColor clearColor];
        
        

    }
    return self;
}

- (void)benginLoadVoice {
    self.voice.hidden = YES;
    [self.indicator startAnimating];
    
}

- (void)didLoadVoice {
    self.voice.hidden = NO;
    [self.indicator stopAnimating];
    [self.voice startAnimating];
}

-(void)stopPlay {
    [self.voice stopAnimating];
}

- (void)setIsMyMessage:(BOOL)isMyMessage {
    _isMyMessage = isMyMessage;
    if (isMyMessage) {
       // self.backImageView.frame = CGRectMake(backImageLeftMargin, backImageLeftMargin, 220, 220);
        self.voiceBackView.frame = CGRectMake(15, 10, 130, 35);
        self.second.textColor    = [UIColor whiteColor];
        
        
    }else{
       // self.backImageView.frame = CGRectMake(backImageRightMargin, backImageLeftMargin, 220, 220);
        self.voiceBackView.frame = CGRectMake(25, 10, 130, 35);
        self.second.textColor    = [LWUtil colorWithHexString:@"#666666"];
    }
    self.backImageView.frame = CGRectMake(0, 0, 220, 220);
    
    self.second.centerY=self.voiceBackView.height/2;
    self.voice.centerY=self.voiceBackView.height/2;
    
    if (isMyMessage){
        self.voice.tintColor = [UIColor whiteColor];
        self.voice.image = [UIImage imageNamed :@"talk_voice_animation3_white"];
        self.voice.animationImages = @[
                                      [UIImage imageNamed :@"talk_voice_animation1_white"],
                                      [UIImage imageNamed :@"talk_voice_animation2_white"],
                                      [UIImage imageNamed :@"talk_voice_animation3_white"]];
    }else {
        self.voice.image =[UIImage imageNamed :@"talk_voice_animation3"];
        self.voice.animationImages = @[
                                      [UIImage imageNamed :@"talk_voice_animation1"],
                                      [UIImage imageNamed :@"talk_voice_animation2"],
                                      [UIImage imageNamed :@"talk_voice_animation3"]];
    }

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
}

-(void)setHeight:(CGFloat)height
{
    [super setHeight:height];
    self.voiceBackView.centerY=height/2;
}
@end
