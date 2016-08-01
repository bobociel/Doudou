//
//  MessageFrame.m
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "MessageFrame.h"
#import "NSDate+Utils.h"
#import "ChatConversationManager.h"
//计算文本最大宽度

#define MINWIDTH ChatContentFontSize+ChatContentRight+ChatContentLeft
#define MINSINGLEHEIGHT ChatBackImageEdgeTop+ChatBackImageEdgeBottom
#define MINDOUBLEHEIGHT ChatBackImageEdgeTop+ChatBackImageEdgeBottom
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"


@implementation MessageFrame

-(id)init {
    self = [super init];
    if (self) {
        self.showTime = YES;
    }
    return self;
}

- (void)setMessage:(Message *)message{
    
    _message = message;

	self.isMyMsg = [_message.byClient isEqual:[UserInfoManager instance].userId_self];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    if (!_message.imMessage)
	{
        NSString *notificationText = @"";
        CGFloat timeY = ChatMargin;
        CGSize timeSize = [notificationText sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
        _cellHeight = timeY + timeSize.height + ChatTimeMarginH;
        _iconF      = CGRectMake(0, 0, 0, 0);
        _nameF      = CGRectMake(0, 0, 0, 0);
        _contentF   = CGRectMake(0, 0, 0, 0);
        return;
    }
    
    // 计算时间的位置
    NSString *sendTime = [[NSDate dateWithTimeIntervalSinceReferenceDate:_message.sentTimestamp/1000] string];
    if (_showTime){
        CGFloat timeY = ChatMargin;
        CGSize timeSize = [sendTime sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }else {
        _timeF =CGRectZero;
    }
    
    // 计算头像位置
	CGFloat iconX = _isMyMsg ? screenW - ChatMargin - ChatIconWH :  ChatMargin;

    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);

    // 计算ID位置
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    // 计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
    
    //根据种类分
    CGSize contentSize = CGSizeZero;
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSString *conversationTypeKey=[LWUtil getString:((AVIMTypedMessage*)message.imMessage).attributes[ConversationTypeKey] andDefaultStr:@""];

    if (![_message.imMessage isKindOfClass:[AVIMTypedMessage class]])
	{
        NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:_message.imMessage.content andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
        contentSize = [attrStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                            options:options
                                            context:nil].size;
    }
	else
	{
        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)_message.imMessage;
        switch (typedMessage.mediaType)
		{
            case kAVIMMessageMediaTypeText:
			{
				if (!typedMessage.attributes)
				{
                    NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:((AVIMTextMessage *)typedMessage).text andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
                    contentSize = [attrStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                        options:options
                                                        context:nil].size;
                }
				else
				{
                    if ([conversationTypeKey isEqualToString:ConversationTypeSendFaceImage])
					{
                        UIImage *image = [UIImage imageNamed :typedMessage.attributes[ConversationValueKey]];
                        contentSize = CGSizeMake(image.size.width>0&&image.size.width<ChatPicWH?image.size.width:ChatPicWH, image.size.height>0&&image.size.height<ChatPicWH?image.size.height:ChatPicWH);
                        
                    }
                    else if (![conversationTypeKey isEqualToString:ConversationTypeLike]
							 &&![conversationTypeKey isEqualToString:ConversationTypeChat]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInviteKiss]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInviteDraw]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInvitePlan]
							 &&![conversationTypeKey isEqualToString:ConversationTypeChatWithSupplier]
							 &&![conversationTypeKey isEqualToString:ConversationTypeCreateOrder]
							 &&![conversationTypeKey isEqualToString:ConversationTypeCreateDemand]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInvitePlan])
                    {
                        NSString *contentText=[NSString stringWithFormat:@"%@",((AVIMTextMessage*)message.imMessage).text];
                        NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:contentText andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
                        
                        contentSize = [attrStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                            options:options
                                                            context:nil].size;
                    }
                    else
					{
						NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:((AVIMTextMessage *)typedMessage).text andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
                        
                        contentSize = [attrStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                            options:options
                                                            context:nil].size;
                    }
                }
			}  break;
            case kAVIMMessageMediaTypeImage:
			{
                AVIMImageMessage *imagetypedMessage =(AVIMImageMessage *)typedMessage;
                NSDictionary *dicmetadata=imagetypedMessage.file.metaData;

                float picwidth = ChatPicWH;
                if ([dicmetadata.allKeys containsObject:@"width"]) {
                    picwidth= [dicmetadata[@"width"] floatValue];
                }
                float picheight = ChatPicWH;
                if ([dicmetadata.allKeys containsObject:@"height"]) {
                    picheight= [dicmetadata[@"height"] floatValue];
                }
                
                CGSize imageSize = CGSizeMake(picwidth, picheight);
                contentSize = [[MaskCreator instance] returnSizeWithImageSize:imageSize];
            }  break;
            case kAVIMMessageMediaTypeAudio:
                contentSize = CGSizeMake(120, 20);
                break;
            default:
                break;
        }
    }

    if (_isMyMsg)
	{
        if (((AVIMTypedMessage*)message.imMessage).mediaType==kAVIMMessageMediaTypeImage) {
            contentX = iconX - contentSize.width - ChatMargin;
        }
        else
        {
            contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
        }
    }
    
    if (((AVIMTypedMessage*)message.imMessage).mediaType==kAVIMMessageMediaTypeImage) {
        _contentF = CGRectMake(contentX, contentY, contentSize.width , contentSize.height);
    }
    else
    {
        _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
    }
    
    NSMutableAttributedString *testStr=[LWUtil returnAttributedStringWithString:@"test" andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
    
    CGSize  contentSizeTest = [testStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                    options:options
                                                    context:nil].size;
    
    BOOL isSinge =_contentF.size.height> contentSizeTest.height + ChatContentTop + ChatContentBottom?NO:YES;//判断使用哪一张图
    if (((AVIMTypedMessage*)message.imMessage).mediaType==kAVIMMessageMediaTypeAudio) {
        isSinge=YES;
    }
    
    if (_contentF.size.width<MINWIDTH) {
        if (_isMyMsg) {
            _contentF.origin.x-=MINWIDTH-_contentF.size.width;
        }
        _contentF.size.width=MINWIDTH;
    }
    
    if (isSinge) {
        if (_contentF.size.height<MINSINGLEHEIGHT) {
            _contentF.size.height=MINSINGLEHEIGHT;
        }
    }
    else
    {
        if (_contentF.size.height<MINDOUBLEHEIGHT) {
            _contentF.size.height=MINDOUBLEHEIGHT;
        }
    }
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
}

@end
#pragma clang diagnostic pop