//
//  QHAudioPlayer.m
//  lovewith
//
//  Created by imqiuhang on 15/4/26.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "QHAudioPlayer.h"

@implementation QHAudioPlayer

+ (instancetype)instance
{
	static QHAudioPlayer *player;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		player = [[QHAudioPlayer alloc] init];
		[self createVideoWithSystemId:QHAudioPlayer_sound_kiss andFileName:@"kiss.wav"];
		[self createVideoWithSystemId:QHAudioPlayer_sound_record_on andFileName:@"VoiceSearchOn.wav"];
		[self createVideoWithSystemId:QHAudioPlayer_sound_record_off andFileName:@"VoiceSearchOff.wav"];
	});
	return player;
}

+ (void)createVideoWithSystemId:(SystemSoundID)ID andFileName:(NSString *)videoName
{
	NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:nil];
	if (path) {
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&ID);
	}
}

- (void)playSoundWithSoundId:(SystemSoundID)soundId {

	if (soundId==QHAudioPlayer_sound_shark)
	{
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
	else
	{
		AudioServicesPlaySystemSound(soundId);
	}
}


@end
