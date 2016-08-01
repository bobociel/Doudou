//
//  WeddingHomePageMusicCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingHomePageMusicCell.h"

@implementation UITableView(WeddingHomePageMusicCell)

- (WeddingHomePageMusicCell *)WeddingHomePageMusicCell{
    
    static NSString *CellIdentifier = @"WeddingHomePageMusicCell";
    
    WeddingHomePageMusicCell * cell = (WeddingHomePageMusicCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (WeddingHomePageMusicCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@implementation WeddingHomePageMusicCell
{
    BOOL isPlaying;
    NSString *voiceURL;
    UIActivityIndicatorView *loadingView ;
}
- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
    
    self.selectimage.hidden=YES;
    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.centerY = 40/2.f;
    loadingView.right = screenWidth-20;
    self.musicNamelable.textColor = subTitleLableColor;
    
    [LWAssistUtil imageViewSetAsLineView:self.selectedLine color:[WeddingTimeAppInfoManager instance].baseColor];
    [LWAssistUtil imageViewSetAsLineView:self.lineView color:rgba(221, 221, 221, 1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UUBegainLoad:) name:UUAVPLAYBeaginLoadVoiceNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UUBeiginPlay:) name:UUAVPLAYBegainPlayVoiceNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UUFaildPlay:) name:UUAVPLAYFaildPlayVoiceNotify object:nil];
}

- (void)setInfo:(id)info withSelectedId:(NSInteger)selectedId{
    self.musicNamelable.text = [LWUtil getString:info[@"name"] andDefaultStr:@"音乐"];

    voiceURL = [LWUtil getString:info[@"path"] andDefaultStr:@""];
    
    if ([[UUAVAudioPlayer sharedInstance].playingAudioUrl isEqualToString:voiceURL]) {
        [self didBegainPlay];
    }else if ([[UUAVAudioPlayer sharedInstance].loadingAudioUrl isEqualToString:voiceURL]) {
        [self didLoading];
    }else {
        [self didStopPlay];
    }

    if (selectedId==[info[@"id"] intValue]) {
        self.selectimage.hidden=NO;
        self.musicNamelable.textColor = [WeddingTimeAppInfoManager instance].baseColor;
    }
}

- (void)tap {
    if (isPlaying) {
        [[UUAVAudioPlayer sharedInstance] stopSound];
        [self didStopPlay];
        if ([self.delegate respondsToSelector:@selector(cancelChooseMusic)]) {
            [self.delegate cancelChooseMusic];
        }

    }else {
        [self didLoading];
        
        [[UUAVAudioPlayer sharedInstance] playSongWithOutCachWithUrl:voiceURL];
        
        if ([self.delegate respondsToSelector:@selector(didChooseMusicWithIndex:)]) {
            [self.delegate didChooseMusicWithIndex:self.index];
        }
    }
    
}

- (void)UUBeiginPlay:(NSNotification *)sender {
    if (![sender.object isEqualToString:voiceURL]) {
        [self didStopPlay];
    }else {
        [self didBegainPlay];
    }
}

- (void)UUBegainLoad:(NSNotification *)sender {
    if (![sender.object isEqualToString:voiceURL]) {
        [self didStopPlay];
    }else {
        [self didLoading];
    }
}

- (void)UUFaildPlay:(NSNotification *)sender {
    if (![sender.object isEqualToString:voiceURL]) {
        
    }else {
        [self didLoading];
    }
}


- (void)didLoading {
    self.selectimage.hidden=YES;
    self.selectedLine.hidden=YES;
    self.musicNamelable.textColor = [WeddingTimeAppInfoManager instance].baseColor;
    [self addSubview:loadingView];
    [loadingView startAnimating];
}

- (void)didStopPlay {
    isPlaying =NO;
    self.musicNamelable.textColor = subTitleLableColor;
    [loadingView removeFromSuperview];
    self.selectimage.hidden=YES;
    self.selectedLine.hidden=YES;
    [loadingView stopAnimating];
}

- (void)didBegainPlay {
    isPlaying =YES;
    self.selectimage.hidden=NO;
    self.selectedLine.hidden=NO;
    [loadingView stopAnimating];
    [loadingView removeFromSuperview];
}


@end
