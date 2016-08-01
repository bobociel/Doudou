//
//  DrawViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTDrawViewController.h"
#import "AlertViewWithBlockOrSEL.h"
#import "ChatConversationManager.h"
#import "PushNotifyCore.h"
#import "ChatMessageManager.h"
#import "QHNavigationController.h"
#import "WTChatDetailViewController.h"
#define margin              20.f
#define colorSliderNavHeigh 44.f
#define colorBtnWidth       30.f
#define colorBtnmargin      10
@interface WTDrawViewController ()

@end

@implementation WTDrawViewController
{
    NSArray      *colorArr;
    UIScrollView *colorNavScrollView;
	UIView       *chooseWidthView;
    NSString     *curHexColor;
    NSString     *lastColor;
    float        curWidth;
    CGPoint      MyBeganpoint;
    CGPoint      MyMovepoint;
    CGFloat       changeWithViewHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initColorBtn];
    [self initView ];
    [PushNotifyCore pushMessageInviterPartnerDraw];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDrawInfo:) name:DrawDidGetPatarnerDrawInfoInfoNotify object:nil];
    [[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
        if (ourCov) {
            [ChatConversationManager sendCustomMessageWithPushName:@"draw" andConversationTypeKey:ConversationTypeInviteDraw andConversationValue:@"" andCovTitle:self.isFromJoin ? @"加入了一起画"
                                                                  : @"发起一起画" conversation:ourCov push:YES success:^{
                                                                      
                                                                  } failure:^(NSError *error) {
                                                                      
                                                                  }];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DrawDidGetPatarnerDrawInfoInfoNotify object:nil];
}

- (void)didReceiveDrawInfo:(NSNotification *)aNotify
{
    self.title=@"另一半已加入一起画";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.drawPaletteView didReceiveDrawInfo:aNotify];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

#pragma mark - valueChanged
- (void)colorBtnEvent:(UIButton *)sender {
    curHexColor = colorArr[sender.tag];
    lastColor = curHexColor;
    self.rubberBtn.tag=0;
    curHexColor=lastColor;
    [self.rubberBtn setImage:[UIImage imageNamed :@"icon_runbbsh_gray"] forState:UIControlStateNormal];
    [self changeColor:self.changeColorBtn];
}

- (IBAction)rubberBtnEvent:(id)sender {
    [self changeColorWithTag:1];
    if (self.rubberBtn.tag==0) {
        curHexColor = @"#ffffff";
        self.rubberBtn.tag=1;
        [self.rubberBtn setImage:[UIImage imageNamed :@"icon_runbbsh_pink"] forState:UIControlStateNormal];
    }else {
        self.rubberBtn.tag=0;
        curHexColor=lastColor;
        [self.rubberBtn setImage:[UIImage imageNamed :@"icon_runbbsh_gray"] forState:UIControlStateNormal];
    }
}

//撤销一步的操作，貌似需求不需要了
- (IBAction)backBtnEvent:(id)sender {
    [self.drawPaletteView myLineFinallyRemove];
}

- (IBAction)cleanBtnEvent:(id)sender {
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"清空画板" message:@"确定清空自己的画板?这将无法撤销."] ;
    [alertView addOtherButtonWithTitle:@"清空" onTapped:^{
        [self.drawPaletteView myalllineclear];
    }];
    [alertView setCancelButtonWithTitle:@"取消" onTapped:^{
    }];
    [alertView show];
    
}

- (IBAction)widthValueChangedEvent:(UISlider *)sender {
    curWidth = sender.value;
}

- (IBAction)changeColor:(UIButton *)sender {
    [self chageWidthWithTag:1];
    [self changeColorWithTag:sender.tag];
}

-(void)changeColorWithTag:(BOOL)tag
{
    self.changeColorBtn.enabled=NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        colorNavScrollView.width =  !tag?screenWidth:0;
    } completion:^(BOOL finished) {
        self.changeColorBtn.tag=!tag;
        self.changeColorBtn.enabled = YES;
    }];
}

- (IBAction)chageWidth:(UIButton *)sender {
    [self changeColorWithTag:1];
    [self chageWidthWithTag:sender.tag];
}

-(void)chageWidthWithTag:(BOOL)tag
{
    self.chooseWidthBtn.enabled=NO;
    chooseWidthView.bottom     = self.bottomView.top;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (tag) {
            chooseWidthView.height=0;
            chooseWidthView.bottom = self.bottomView.top;
        }else {
            chooseWidthView.height=changeWithViewHeight;
            chooseWidthView.bottom = self.bottomView.top;
        }
    } completion:^(BOOL finished) {
        self.chooseWidthBtn.tag=!tag;
        self.chooseWidthBtn.enabled = YES;
    }];
    
}

- (void)selectWidth:(int)index {
    for(UIButton *btn in chooseWidthView.subviews) {
        if (btn.tag==index) {
            btn.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
        }else {
            btn.backgroundColor = [LWUtil colorWithHexString:@"#D8D8D8"];
        }
    }
    curWidth = (index+1)*3;
    
}

- (void)widthBtnEvent:(UIButton *)sender {
    [self selectWidth:(int)sender.tag];
    [self chageWidth:self.chooseWidthBtn];
}

#pragma mark - drawWhileTouch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch=[touches anyObject];
    MyBeganpoint=[touch locationInView:self.drawPaletteView ];
    
    [self.drawPaletteView IntroductionpointHexColor:curHexColor];
    [self.drawPaletteView IntroductionpointWidth:curWidth];
    [self.drawPaletteView IntroductionpointInitPoint];
    [self.drawPaletteView IntroductionpointAddPoint:MyBeganpoint];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray* MovePointArray=[touches allObjects];
    MyMovepoint=[[MovePointArray objectAtIndex:0] locationInView:self.drawPaletteView];
    [self.drawPaletteView IntroductionpointAddPoint:MyMovepoint];
    [self.drawPaletteView setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.drawPaletteView IntroductionpointSavePoint];
    [self.drawPaletteView setNeedsDisplay];
    [self.drawPaletteView sendMyDraw];
}

#pragma mark -init
- (void)initColorBtn {
    
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    colorArr = @[
                 @"#ffc0cb",
                 @"#fb0d0d",
                 @"#d65303",
                 @"#d69803",
                 @"#d6d403",
                 @"#acd603",
                 @"#4ed603",
                 @"#03d666",
                 @"#03d6c0",
                 @"#03b6d6",
                 @"#0366d6",
                 @"#2b03d6",
                 @"#7a03d6",
                 @"#bb03d6",
                 @"#d603ac",
                 @"#d6036b",
                 ];
    
    colorNavScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, colorSliderNavHeigh)];
    colorNavScrollView.bottom = self.view.height-self.bottomView.height;
    colorNavScrollView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    colorNavScrollView.contentSize =CGSizeMake(margin*2+colorBtnWidth*colorArr.count+colorBtnmargin*(colorArr.count-1), colorNavScrollView.contentSize.height);
    colorNavScrollView.showsVerticalScrollIndicator   = NO;
    colorNavScrollView.showsHorizontalScrollIndicator = NO;
    colorNavScrollView.bounces                        = YES;
    [self.view addSubview:colorNavScrollView];
    colorNavScrollView.width = 0;
    colorNavScrollView.layer.borderColor=rgba(221, 221, 221, 1).CGColor;
    colorNavScrollView.layer.borderWidth = 0.5;
    
    for (int i=0; i<colorArr.count; i++) {
        UIButton *colorBtn          = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, colorBtnWidth, colorBtnWidth)];
        colorBtn.left               = margin+i*colorBtnWidth+i*colorBtnmargin;
        colorBtn.centerY            = colorNavScrollView.height/2.f;
        colorBtn.tintColor          = [LWUtil colorWithHexString:colorArr[i]];
        [colorBtn setImage:[[UIImage imageNamed:@"icon_draw_color_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        colorBtn.tag                = i;
        [colorNavScrollView addSubview:colorBtn];
        [colorBtn addTarget:self action:@selector(colorBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        colorBtn.layer.cornerRadius = colorBtn.height/2.f;
    }
}

- (void)sendImage {
    if ([self.drawPaletteView sendImage]) {
        if (self.isFromChat) {
            [self back];
        }
        else
        {
            [[ChatMessageManager instance]makeOurConversation:^{
                [self hideLoadingView];
                AVIMKeyedConversation *KeyedConversation=[ChatMessageManager instance].keyedConversationOur;
                NSString*KEY=KeyedConversation.conversationId;
                AVIMConversation *conversation=[[ChatMessageManager instance]getConversationWithId:KEY];
                if (conversation) {
                    [WTChatDetailViewController pushToChatDetailWithConversation:conversation];
                }
                else
                {
                    [WTChatDetailViewController pushToChatDetailWithKeyConversation:KeyedConversation];
                }
            } failure:^{
                [self hideLoadingView];
                [WTProgressHUD ShowTextHUD:@"获取会话失败" showInView:self.view];
            }];
        }
    }
}

- (void)rightNavBtnEvent {
    [self sendImage];
}

- (void)initView {
    self.rubberBtn.tag=0;
    curHexColor = colorArr[0];
    lastColor = curHexColor;
    curWidth =4;

    self.drawPaletteView.layer.masksToBounds = YES;
    self.drawPaletteView.backgroundColor = [UIColor whiteColor];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.bottomView.layer.borderColor = rgba(221, 221, 221, 1).CGColor;
    self.bottomView.layer.borderWidth = 0.5;
    
    float wwidth               = 32;
    chooseWidthView            = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wwidth, wwidth*3+3*6)];
    changeWithViewHeight=chooseWidthView.height;
    chooseWidthView.centerX    = self.chooseWidthBtn.centerX;
    [self.view addSubview:chooseWidthView];
    chooseWidthView.height     = 0;
    chooseWidthView.clipsToBounds=YES;
    for (int i=0;i<3;i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0+i*(6+wwidth), wwidth, wwidth)];
        btn.backgroundColor = [LWUtil colorWithHexString:@"#D8D8D8"];
        btn.tag=2-i;
        [btn addTarget:self action:@selector(widthBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8+btn.tag*4,  8+btn.tag*4)];
        view.backgroundColor        = [UIColor whiteColor];
        view.userInteractionEnabled = NO;
        view.centerX                = btn.width/2.f;
        view.centerY                = btn.height/2.f;
        view.layer.cornerRadius     = view.width/2.f;
        [btn addSubview:view];
        
        btn.layer.cornerRadius     = 2;
        [chooseWidthView addSubview:btn];
        
    }
    
    [self selectWidth:1];
    
    [self setRightBtnWithTitle:@"发送"];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
       
       NSForegroundColorAttributeName:rgba(153, 153, 153, 1)}];
    self.title=@"等待对方加入";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavWithClearColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

+(void)pushViewControllerWithRootViewController:(UIViewController*)root isFromJoin:(BOOL)isFromJoin isFromChat:(BOOL)isFromChat
{
    if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"您还未绑定另一半哦" showInView:root?root.view:KEY_WINDOW];
        return;
    }

	WTDrawViewController *next = [[WTDrawViewController alloc] initWithNibName:@"WTDrawViewController" bundle:nil];
    next.isFromJoin=isFromJoin;
    next.isFromChat=isFromChat;
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

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
@end
