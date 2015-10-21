//
//  MessageDetailController.m
//  nihoo
//
//  Created by 刘志 on 15/4/21.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "MessageDetailController.h"
#import "MessageData.h"

@interface MessageDetailController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate> {
    NSMutableArray *messageArray;
}

@property (nonatomic,strong) UIImage *willSendImage;
@end

@implementation MessageDetailController


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _chatTitle;
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    self.delegate = self;
    self.dataSource = self;
    [self dontShowBackButtonTitle];
    messageArray = [NSMutableArray array];
    [self testData];
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)testData{
    /*MessageData *message1 = [[MessageData alloc] initWithMsgId:@"0001" text:@"hello" date:[NSDate date] msgType:JSBubbleMessageTypeIncoming mediaType:JSBubbleMediaTypeText img:nil];
    
    [messageArray addObject:message1];
    
    MessageData *message2 = [[MessageData alloc] initWithMsgId:@"0002" text:nil date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing mediaType:JSBubbleMediaTypeImage img:@"example.png"];
    
    [messageArray addObject:message2];
    
    MessageData *message3 = [[MessageData alloc] initWithMsgId:@"0003" text:@"hai!" date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing mediaType:JSBubbleMediaTypeText img:nil];
    
    [messageArray addObject:message3];*/
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    int value = arc4random() % 1000;
    NSString *msgId = [NSString stringWithFormat:@"%d",value];
    
    JSBubbleMessageType msgType;
    if((messageArray.count - 1) % 2){
        msgType = JSBubbleMessageTypeOutgoing;
        [JSMessageSoundEffect playMessageSentSound];
    }else{
        msgType = JSBubbleMessageTypeIncoming;
        [JSMessageSoundEffect playMessageReceivedSound];
    }
    
    MessageData *message = [[MessageData alloc] initWithMsgId:msgId text:text date:[NSDate date] msgType:msgType mediaType:JSBubbleMediaTypeText img:nil];
    
    [messageArray addObject:message];
    
    [self finishSend:NO];
}

- (void)cameraPressed:(id)sender{
    
    [self.inputToolBarView.textView resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"camera",@"album", nil];
    [actionSheet showInView:self.view];
}

#pragma mark -- UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        case 1:{
            int value = arc4random() % 1000;
            NSString *msgId = [NSString stringWithFormat:@"%d",value];
            
            JSBubbleMessageType msgType;
            if((messageArray.count - 1) % 2){
                msgType = JSBubbleMessageTypeOutgoing;
                [JSMessageSoundEffect playMessageSentSound];
            }else{
                msgType = JSBubbleMessageTypeIncoming;
                [JSMessageSoundEffect playMessageReceivedSound];
            }
            
            MessageData *message = [[MessageData alloc] initWithMsgId:msgId text:nil date:[NSDate date] msgType:msgType mediaType:JSBubbleMediaTypeImage img:@"example.png"];
            
            [messageArray addObject:message];
            
            [self finishSend:YES];
        }
            break;
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageData *message = messageArray[indexPath.row];
    return message.messageType;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageData *message = messageArray[indexPath.row];
    return message.mediaType;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleCircle;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageData *message = messageArray[indexPath.row];
    return message.text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageData *message = messageArray[indexPath.row];
    return message.date;
}

- (UIImage *)avatarImageForIncomingMessage
{
    return [UIImage imageNamed:@"logo3"];
}

- (SEL)avatarImageForIncomingMessageAction
{
    return @selector(onInComingAvatarImageClick);
}

- (void)onInComingAvatarImageClick
{
    
    NSLog(@"__%s__",__func__);
    [self presentUserViewController];
}

- (SEL)avatarImageForOutgoingMessageAction
{
    return @selector(onOutgoingAvatarImageClick);
}

- (void)onOutgoingAvatarImageClick
{
    [self presentUserViewController];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"logo4"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageData *message = messageArray[indexPath.row];
    return [UIImage imageNamed:message.img];
}

/**
 *  显示用户信息
 */
- (void) presentUserViewController {
    
}

@end
