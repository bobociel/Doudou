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

@interface SharePopView : UIView<MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)SharePopViewInfo *shareInfo;

- (void)show;
- (void)hide;
- (void)showInViewAlways:(UIView *)view andEmptyInfo:(NSString *)errstr;

//邀请用的接口  这样就没朋友圈之类的,不要问我为什么，需求改改改！！
- (void)setAsInvite;
@end

@interface SharePopViewInfo : NSObject

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *sharedescription;
@property (nonatomic,strong)NSString *urlStr;
@property (nonatomic,strong)UIImage *image;

+ (instancetype)SharePopViewInfoMakeWithTitle:(NSString *)aTitle
                               andDescription:(NSString *)aDescription
                                    andUrlStr:(NSString *)aUrl
                                     andImage:(UIImage *)aImage;
@end