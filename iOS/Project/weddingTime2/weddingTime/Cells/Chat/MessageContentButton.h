//
//  MessageContentButton.h
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

@interface MessageContentButton : UIButton
@property (nonatomic, retain) UIImageView             *backImageView;
@property (nonatomic, retain) UIView                  *voiceBackView;
@property (nonatomic, retain) UILabel                 *second;
@property (nonatomic, retain) UIImageView             *voice;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL isMyMessage;


- (void)benginLoadVoice;

- (void)didLoadVoice;

-(void)stopPlay;

@end
