//
//  TWUploadManager.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/7.
//  Copyright © 2015年 lovewith.me. All rights reserved.
//

typedef enum {
    WTUploadStatueNone          = 0,
    WTUploadStatueUploading ,
    WTUploadStatueCanceled  ,
    WTUploadStatueFinished ,
    WTUploadStatueFailed
}WTUploadStatue;

#define File_Not_Exist   260

#import <Foundation/Foundation.h>
#import <Qiniu/QiniuSDK.h>
#import <Qiniu/QNReachability.h>
#import "WTWeddingStory.h"
@class WTUploadManager;
@protocol WTUploadDelegate <NSObject>
- (void)uploadManager:(WTUploadManager *)uploadManager didFinishedUploadWithKey:(NSString *)key;
- (void)uploadManager:(WTUploadManager *)uploadManager didFailedUpload:(NSError *)error;
- (void)uploadManager:(WTUploadManager *)uploadManager didChangeProgress:(CGFloat)percent;
@optional
- (void)uploadManager:(WTUploadManager *)uploadManager didChangeUploadState:(WTUploadStatue)statue;
@end

@interface WTUploadManager : NSObject  
@property (nonatomic, strong) QNUploadManager     *uploadManager;
@property (nonatomic, strong) QNUploadOption         *uploadOption;
@property (nonatomic, strong) QNFileRecorder          *fileRecord;
@property (nonatomic, strong) QNReachability           *reachebility;
@property (nonatomic, assign) WTUploadStatue        uploadState;
@property (nonatomic, assign) BOOL isCancelUpload;
@property (nonatomic, assign) id <WTUploadDelegate> delegate;

+ (instancetype)manager;
//保存视频Asset到本地
+ (void)saveAsset:(ALAsset *)asset callback:(void(^)(BOOL saved,NSString *filePath))callback;
+ (void)saveMediaWith:(NSDictionary *)mediaInfo callback:(void(^)(BOOL saved,NSString *filePath))callback;

//视频的断点续传
- (BOOL)hasCache;
- (void)resumeUploadCache;
- (void)deleteCache;

//上传文件
- (void)uploadFileWithFileInfo:(id)fileInfo fileType:(WTFileType)fileType fileBucket:(NSString *)fileBucket;

@end
