/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EMChatViewCell.h"
#import "EMChatVideoBubbleView.h"
#import "UIResponder+Router.h"

NSString *const kResendButtonTapEventName = @"kResendButtonTapEventName";
NSString *const kShouldResendCell = @"kShouldResendCell";

NSString *const kRouterEventAudioBubbleShowTranslationEventName = @"kRouterEventAudioBubbleShowTranslationEventName";
NSString *const kRouterEventAudioBubbleHideTranslationEventName = @"kRouterEventAudioBubbleHideTranslationEventName";
NSString *const kShowTranlationCell = @"kShowTranlationCell";
NSString *const kRouterEventChatCellAtTapEventName = @"kRouterEventChatCellAtTapEventName";


@implementation EMChatViewCell

- (id)initWithMessageModel:(MessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImageView.clipsToBounds = YES;
        self.headImageView.layer.cornerRadius = 3.0;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y;
    
    if (self.messageModel.isSender) {
        bubbleFrame.origin.y = self.headImageView.frame.origin.y;
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.messageModel.status) {
            case eMessageDeliveryState_Delivering:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case eMessageDeliveryState_Delivered:
            {
                [_activtiy stopAnimating];
                [_activityView setHidden:YES];
                
            }
                break;
            case eMessageDeliveryState_Failure:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - HEAD_PADDING;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
		
		_showTranslationBtn.hidden = YES;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        _bubbleView.frame = bubbleFrame;
		
		_showTranslationBtn.hidden = NO;
		_showTranslationBtn.center = CGPointMake(CGRectGetMaxX(bubbleFrame)+_showTranslationBtn.bounds.size.width/2+TRANSLATE_BTN_INTERVAL, CGRectGetMidY(_bubbleView.frame));
		
		_tranlationView.frame =	CGRectMake(CGRectGetMinX(_bubbleView.frame), CGRectGetMaxY(_bubbleView.frame)+10, self.bounds.size.width - _bubbleView.frame.origin.x - 30, 40);
    }
}

- (void)setMessageModel:(MessageModel *)model
{
    [super setMessageModel:model];
    
    if (model.isChatGroup) {
        _nameLabel.text = model.username;
        _nameLabel.hidden = model.isSender;
    }
    
    _bubbleView.model = self.messageModel;
    [_bubbleView sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - action

// 重发按钮事件
-(void)retryButtonPressed:(UIButton *)sender
{
    [self routerEventWithName:kResendButtonTapEventName
                     userInfo:@{kShouldResendCell:self}];
}

- (void) showTranslate
{
	if ( _showTranslationBtn.selected )
	{
		//hide
		_tranlationView.hidden = YES;
		[self routerEventWithName:kRouterEventAudioBubbleHideTranslationEventName userInfo:@{kShowTranlationCell:self}];
	}
	else
	{
		//show
		_tranlationView.hidden = NO;
		[self routerEventWithName:kRouterEventAudioBubbleShowTranslationEventName userInfo:@{kShowTranlationCell:self}];
	}
	_showTranslationBtn.selected = !_showTranslationBtn.selected;
}

#pragma mark - private

- (void)setupSubviewsForMessageModel:(MessageModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
	
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
	
	if (!messageModel.isSender && messageModel.type == eMessageBodyType_Voice)
	{
		//显示翻译按钮
		_showTranslationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
		_showTranslationBtn.frame = CGRectMake(0, 0, TRANSLATE_BTN_WIDTH, self.bounds.size.height);
		_showTranslationBtn.backgroundColor = [UIColor yellowColor];
		[_showTranslationBtn setTitle:@"Show" forState:UIControlStateNormal];
		[_showTranslationBtn setTitle:@"Hide" forState:UIControlStateSelected];
		[_showTranslationBtn addTarget:self action:@selector(showTranslate) forControlEvents:UIControlEventTouchUpInside];
		//		[_showTranslationBtn setImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
		[self.contentView addSubview:_showTranslationBtn];
		
		_tranlationView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_bubbleView.frame), CGRectGetMaxY(_bubbleView.frame)+10, self.bounds.size.width - _bubbleView.frame.origin.x - 30, 40)];
		_tranlationView.backgroundColor = [UIColor lightGrayColor];
		_tranlationView.hidden = YES;
		[self.contentView addSubview:_tranlationView];
		
		_tranlationLabel = [[UILabel alloc] initWithFrame:_tranlationView.bounds];
		_tranlationLabel.text = @"语音文字转换识别中...";
		_tranlationLabel.font = [UIFont systemFontOfSize:13];
		[_tranlationView addSubview:_tranlationLabel];
		
		_tranlatingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_tranlatingIndicator.backgroundColor = [UIColor clearColor];
		_tranlatingIndicator.center = CGPointMake(_tranlationView.bounds.size.width - 80, CGRectGetMidY(_tranlationView.bounds));
		[_tranlatingIndicator startAnimating];
		[_tranlationView addSubview:_tranlatingIndicator];
	}
}

- (EMChatBaseBubbleView *)bubbleViewForMessageModel:(MessageModel *)messageModel
{
    switch (messageModel.type) {
        case eMessageBodyType_Text:
        {
			//检测是否是分享任务，日程等特殊信息
//			if ( [messageModel.content rangeOfString:MSFY_IM_SIDENTIFIER].location == 0 )
//			{
//				return [[EMChatMSFYBubbleView alloc] init];
//			}
//			else
//			{
				return [[EMChatTextBubbleView alloc] init];
//			}
        }
            break;
        case eMessageBodyType_Image:
        {
            return [[EMChatImageBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Voice:
        {
            return [[EMChatAudioBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Location:
        {
            return [[EMChatLocationBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Video:
        {
            return [[EMChatVideoBubbleView alloc] init];
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(MessageModel *)messageModel
{
    switch (messageModel.type) {
        case eMessageBodyType_Text:
        {
//			if ( [messageModel.content rangeOfString:MSFY_IM_SIDENTIFIER].location == 0 )
//			{
//				return [EMChatMSFYBubbleView heightForBubbleWithObject:messageModel];
//			}
//			else
//			{
				return [EMChatTextBubbleView heightForBubbleWithObject:messageModel];
//			}
        }
            break;
        case eMessageBodyType_Image:
        {
            return [EMChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Voice:
        {
            return [EMChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Location:
        {
            return [EMChatLocationBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Video:
        {
            return [EMChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        default:
            break;
    }
    
    return HEAD_SIZE;
}

#pragma mark - public

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MessageModel *)model
{
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_PADDING * 2 + HEAD_SIZE;
    if (model.isChatGroup && !model.isSender) {
        headHeight += NAME_LABEL_HEIGHT;
    }
    return MAX(headHeight, bubbleHeight) + CELLPADDING;
}

- (void) setIsShowTranslation:(BOOL)isShowTranslation
{
	_isShowTranslation = isShowTranslation;
	self.showTranslationBtn.selected = isShowTranslation;
	self.tranlationView.hidden = !isShowTranslation;
}
@end
