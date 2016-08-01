//
//  QHAudioPlayer.m
//  lovewith
//
//  Created by imqiuhang on 15/4/26.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "QHAudioPlayer.h"

@implementation QHAudioPlayer

+ (void)playSoundWithSoundId:(SystemSoundID)soundId {
    

    if (soundId==QHAudioPlayer_sound_kiss) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"kiss2" ofType:@"wav"];
        if (path) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&QHAudioPlayer_sound_kiss);
            AudioServicesPlaySystemSound(QHAudioPlayer_sound_kiss);
        }
    }else if (soundId==QHAudioPlayer_sound_record_on) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VoiceSearchOn" ofType:@"wav"];
        if (path) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&QHAudioPlayer_sound_record_on);
            AudioServicesPlaySystemSound(QHAudioPlayer_sound_record_on);
        }
    }else if (soundId==QHAudioPlayer_sound_record_off) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VoiceSearchOff" ofType:@"wav"];
        if (path) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&QHAudioPlayer_sound_record_off);
            AudioServicesPlaySystemSound(QHAudioPlayer_sound_record_off);
        }
    }else if (soundId==QHAudioPlayer_sound_shark) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }else {
        return;
    }
        
}


@end
