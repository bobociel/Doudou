//
//  POVoiceHUD.h
//  lovewith
//
//  Created by imqiuhang on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RootView.h"
#define posCenterY 332 
#define HUD_SIZE                226
#define CANCEL_BUTTON_HEIGHT    50

#define SOUND_METER_COUNT       20
#define WAVE_UPDATE_FREQUENCY   0.05
#define maxAudioTime 40

@class QHVoiceHUD;

@protocol QHVoiceHUDDelegate <NSObject>

@optional

- (void)POVoiceHUD:(QHVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)voiceRecordCancelledByUser:(QHVoiceHUD *)voiceHUD;

@end


@interface QHVoiceHUD : RootView <AVAudioRecorderDelegate> {
    UIButton *timeBtn;
    int soundMeters[40];
    CGRect hudRect;
    
	NSDictionary *recordSetting;
	NSString *recorderFilePath;
	AVAudioRecorder *recorder;
	
	SystemSoundID soundID;
	NSTimer *timer;
    
    float recordTime;
    //UILabel *statusLable;
    
    BOOL isRelaceToCance;
}

- (id)initWithParentView:(UIView *)view;

- (void)startForFilePath:(NSString *)filePath;
- (void)cancelRecording;
- (void)commitRecording;

- (void)setAsNomore;
- (void)setAsRelaceToCance;
@property (nonatomic, weak) id<QHVoiceHUDDelegate> delegate;

@end

