//
//  UUAVAudioPlayer.h
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#define defaultMessageIdStr @"zzmzmzmzmzm"

#define UUAVPLAYBeaginLoadVoiceNotify @"UUBeaginLoadVoiceNotifydsd"
#define UUAVPLAYBegainPlayVoiceNotify @"UUBegainPlayVoiceNotifysadasd"
#define UUAVPLAYStopPlayVoiceNotify   @"UUStopPlayVoiceNotifyasdasd"
#define UUAVPLAYFaildPlayVoiceNotify  @"UUFaildPlayVoiceNotifysadasd"

typedef enum  {
    AudioStatusNone=0,
    AudioStatusLoading=1,
    AudioStatusPlaying=2
}AudioStatus;

@protocol UUAVAudioPlayerDelegate <NSObject>

@optional
- (void)UUAVAudioPlayerBeiginLoadVoice;
- (void)UUAVAudioPlayerBeiginPlay;
- (void)UUAVAudioPlayerDidFinishPlay;

@end

@interface UUAVAudioPlayer : NSObject

@property (nonatomic, weak)id <UUAVAudioPlayerDelegate>delegate;
@property (nonatomic,strong)NSString *playingAudioUrl;
@property (nonatomic,strong)NSString *loadingAudioUrl;

+ (UUAVAudioPlayer *)sharedInstance;

-(void)playSongWithUrl:(NSString *)songUrl;
-(void)playSongWithData:(NSData *)songData;

- (void)playSongWithOutCachWithUrl:(NSString *)songUrl;

- (void)stopSound;


@end
