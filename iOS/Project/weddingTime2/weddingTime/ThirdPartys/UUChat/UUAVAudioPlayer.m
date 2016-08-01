//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <AFNetworking/AFNetworking.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbool-conversion"

@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}
@property (nonatomic,strong) NSURLSessionDownloadTask *task;
@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });    
    return sharedInstance;
}

+(NSString*)dataCachePath {
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheDir = [root stringByAppendingPathComponent:@"cacheMsgData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return cacheDir;
}

+ (NSData *)localAudioDataWithFileName:(NSString *)fileName
{
	 return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
}

- (void)cacheSongWithUrl:(NSString *)songUrl callback:(void(^)(NSString *songURL,NSData *songData))callback;
{
	self.loadingAudioUrl=songUrl;
	self.playingAudioUrl=songUrl;

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[songUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSString *cacheFile = [[UUAVAudioPlayer dataCachePath] stringByAppendingPathComponent:songUrl.lastPathComponent];
	NSURL *cacheFileURL = [NSURL fileURLWithPath:cacheFile];

	[self stopTask];
	if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFile isDirectory:NO])
	{
		AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
		_task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * (NSURL * targetPath, NSURLResponse * response) {
			return cacheFileURL;
		} completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
			if(!error){
				NSData *data = [NSData dataWithContentsOfFile:cacheFile];
				dispatch_async(dispatch_get_main_queue(), ^{
					if(callback) { callback(songUrl,data); }
				});
			}else{
				callback(songUrl,nil);
			}
		}];
		[_task resume];
	}
	else
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSData *data = [NSData dataWithContentsOfFile:cacheFile];
			dispatch_async(dispatch_get_main_queue(), ^{
				if(callback) { callback(songUrl,data); }
			});
		});
	}
}

- (void)stopTask
{
	[_task cancel];
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    self.loadingAudioUrl=songUrl;
    self.playingAudioUrl=songUrl;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UUAVPLAYBeaginLoadVoiceNotify object:songUrl];
    
    __weak typeof(self) ws = self;
    NSURL *url = [NSURL URLWithString:songUrl];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *cacheFile = [[UUAVAudioPlayer dataCachePath] stringByAppendingPathComponent:url.path];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFile isDirectory:NO]) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            [data writeToFile:cacheFile atomically:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *songData = [NSData dataWithContentsOfFile:cacheFile];
            [ws playSongWithData:songData andType:AVFileTypeMPEGLayer3];
        });
    });
}

-(void)playSongWithData:(NSData *)songData andType:(NSString *)audioType
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UUAVPLAYBegainPlayVoiceNotify object:self.playingAudioUrl];

    self.loadingAudioUrl=defaultMessageIdStr;
    
    if (player) {
        [player stop];
        player.delegate = nil;
        player = nil;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"VoicePlayHasInterrupt" object:nil];
    NSError *playerError;
    player = [[AVAudioPlayer alloc]initWithData:songData fileTypeHint:audioType error:&playerError];
    if (nil == player) {
        MSLog(@"failed to init AudioPlayer. error: %@", playerError.description);
        [[NSNotificationCenter defaultCenter] postNotificationName:UUAVPLAYFaildPlayVoiceNotify object:self.playingAudioUrl];
    }
    player.volume = 1.0f;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    player.delegate = self;
    [player play];
    [self.delegate UUAVAudioPlayerBeiginPlay];

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.playingAudioUrl=defaultMessageIdStr;
    self.loadingAudioUrl=defaultMessageIdStr;
    [self.delegate UUAVAudioPlayerDidFinishPlay];
}

- (void)stopSound
{
    if (player && player.isPlaying) {
        [player stop];
        self.playingAudioUrl=defaultMessageIdStr;
        self.loadingAudioUrl=defaultMessageIdStr;
        [self.delegate UUAVAudioPlayerDidFinishPlay];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:UUAVPLAYStopPlayVoiceNotify object:self.playingAudioUrl];
}

@end

#pragma clang diagnostic pop