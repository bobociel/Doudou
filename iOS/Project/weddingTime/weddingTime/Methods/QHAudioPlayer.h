//
//  QHAudioPlayer.h
//  lovewith
//
//  Created by imqiuhang on 15/4/26.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
static SystemSoundID QHAudioPlayer_sound_shark      = 0; //震动
static SystemSoundID QHAudioPlayer_sound_kiss       = 1+533; //指纹kiss
static SystemSoundID QHAudioPlayer_sound_record_on  = 2+533; //开始录音
static SystemSoundID QHAudioPlayer_sound_record_off = 3+533; //结束录音

@interface QHAudioPlayer : NSObject
+ (instancetype)instance;
- (void)playSoundWithSoundId:(SystemSoundID)soundId;
@end
