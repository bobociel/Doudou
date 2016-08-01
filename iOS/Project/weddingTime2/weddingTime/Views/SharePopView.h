//
//  SharePopView.h
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class SharePopViewInfo;

typedef NS_ENUM(NSUInteger,WTShareType) {
    WTShareTypeWX      = 0,
    WTShareTypeQQ      = 1,
    WTShareTypeSina    = 2,
    WTShareTypeMessage = 3,
    WTShareTypeCopy    = 4,

	WTShareTypeNormal  = 5,
	WTShareTypeBless   = 6
};

@interface SharePopView : UIView <MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) SharePopViewInfo *shareInfo;
+ (instancetype)viewWithhareTypes:(NSArray *)shareTypes;
- (void)show;
- (void)hide;
- (void)showInViewAlways:(UIView *)superView;
@end

@interface SharePopViewInfo : NSObject

@property (nonatomic,copy) NSString  *title;
@property (nonatomic,copy) NSString  *sharedescription;
@property (nonatomic,copy) NSString  *urlStr;
@property (nonatomic,copy) NSString *imageURL;

+ (instancetype)SharePopViewInfoWithTitle:(NSString *)aTitle
							andDescription:(NSString *)aDescription
								andUrlStr:(NSString *)aUrl
								andImageURL:(NSString *)imageURL;
@end