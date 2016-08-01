//
//  KissViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTKissViewController.h"
#import "QHAudioPlayer.h"
#import "PushNotifyCore.h"
#import "ChatMessageManager.h"
#import "QHNavigationController.h"
@interface WTKissViewController ()

@end

@implementation WTKissViewController
{
    UIImageView *myKissImage;
    UIImageView *patnerImage;
    UIView      *nearColorView;
}

+(void)pushViewControllerWithRootViewController:(UIViewController*)root isFromJoin:(BOOL)isFromJoin
{
    if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"您还未绑定另一半哦" showInView:root?root.view:KEY_WINDOW];
        return;
    }
    WTKissViewController *next=[WTKissViewController new];
    next.isFromJoin=isFromJoin;
    if (root) {
        [root.navigationController pushViewController:next animated:YES];
    }
    else
    {
        if (![KEY_WINDOW.rootViewController isKindOfClass:[UINavigationController class]]) {
            return;//在弹出警告框之类的时候 根视图不是导航视图 push会出错 所以加判断~虽然可能性很小
        }
        QHNavigationController *nav=(QHNavigationController*)KEY_WINDOW.rootViewController;
        [nav pushViewController:next animated:YES];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor=[UIColor whiteColor];
    [self initView];
    [PushNotifyCore pushMessageInviterPartnerKiss];
    [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
        if (ourCov) {
            [ChatConversationManager sendCustomMessageWithPushName:nil andConversationTypeKey:ConversationTypeInviteKiss andConversationValue:@"" andCovTitle:_isFromJoin?@"加入了指纹Kiss   " :@"发起指纹kiss   " conversation:ourCov push:YES success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavWithClearColor];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state==UIGestureRecognizerStateBegan) {
        myKissImage.hidden=NO;
    }
    CGPoint translation = [gesture locationInView:self.view];
    myKissImage.centerX = translation.x;
    myKissImage.centerY = translation.y;
    [self sendPostion:YES];
    
    [self nearViewSet];
    if (gesture.state==UIGestureRecognizerStateEnded) {
        [self sendPostion:NO];
        myKissImage.hidden = YES;
        [self nearViewSet];
        [self performSelector:@selector(TouchOut) withObject:nil afterDelay:1];
        return;
    }
    
}

- (void)TouchOut {
    if (myKissImage.isHidden==YES) {
       [self sendPostion:NO];
    }
    
}

- (void)sendPostion:(BOOL)isTouch {
    if ([ChatMessageManager instance].conversationOur) {
        AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:@"kiss" attributes:@{ConversationTypeKey:ConversationTypeKiss,ConversationIsForGameKey:@(YES), @"data":@{@"x":@(myKissImage.centerX/self.view.width),@"y":@(myKissImage.centerY/self.view.height),@"isTouch":@(isTouch)}}];
        [[ChatMessageManager instance].conversationOur sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
            if (error) {
                MSLog(@"发送指纹位置失败");
            } else {
                
            }
        }];
    }
}

- (void)didReceiveKissInfo:(NSNotification *)aNotify {
    
    if (aNotify.object) {
        self.title = @"对方已经加入指纹kiss";
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
           NSForegroundColorAttributeName:[UIColor blackColor]}];
        if ([aNotify.object[@"isTouch"] boolValue]==NO) {
            patnerImage.hidden=YES;
            return;
        }
        patnerImage.hidden=NO;
        float px = [aNotify.object[@"x"]floatValue ];
        float py = [aNotify.object[@"y"]floatValue ];
        [self.view addSubview:patnerImage];
        [self.view bringSubviewToFront:myKissImage];
        patnerImage.centerX=px*self.view.width;;
        patnerImage.centerY=py*self.view.height;;
        [self nearViewSet];
        
    }
}

- (void)nearViewSet {
    
    float distance =sqrtf((myKissImage.centerX-patnerImage.centerX)*(myKissImage.centerX-patnerImage.centerX)+(myKissImage.centerY-patnerImage.centerY)*(myKissImage.centerY-patnerImage.centerY));
    
    if (myKissImage.isHidden==YES||patnerImage.isHidden==YES) {
        nearColorView.alpha=0.f;
    }
    
    if (distance<20.f&&patnerImage.isHidden==NO&&myKissImage.isHidden==NO) {
        [UIView animateWithDuration:0.2 delay:0 options:    UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             nearColorView.alpha=1-(distance/20.f);
                         } completion:^(BOOL finished) {
                             
                         }];
        [QHAudioPlayer playSoundWithSoundId:QHAudioPlayer_sound_kiss];
        [QHAudioPlayer playSoundWithSoundId:QHAudioPlayer_sound_shark];
        
    }else {
        nearColorView.alpha=0.f;
    }
}

- (void)initView {
    
    nearColorView = [[UIView alloc] initWithFrame:self.view.bounds];
    nearColorView.backgroundColor=[WeddingTimeAppInfoManager instance].baseColor;
    nearColorView.alpha = 0;
    [self.view addSubview:nearColorView];
    
    myKissImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 100)];
    myKissImage.layer.masksToBounds=YES;
    myKissImage.centerX = self.view.width/2.f;
    myKissImage.centerY = self.view.height/2.f;
    myKissImage.hidden=YES;
    [myKissImage setImage:[UIImage imageNamed :@"icon_kiss_pink"]];
    [self.view addSubview:myKissImage];
    
    
    patnerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 100)];
    patnerImage.layer.masksToBounds=YES;
    [patnerImage setImage:[UIImage imageNamed :@"icon_kiss_gray"]];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    
    [self.view addGestureRecognizer:pan];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKissInfo:) name:KissDidGetPatarnerKissInfoNotify object:nil];

    self.title=@"等待对方加入指纹kiss";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
       
       NSForegroundColorAttributeName:rgba(153, 153, 153, 1)}];
    [self sendPostion:NO];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}
@end
