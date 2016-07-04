//
//  WTTopView.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTTopView.h"
#import "LWUtil.h"
#import "CommAnimationForControl.h"
#define kTopViewHeight 64.0
@interface WTTopView ()
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *ciryFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *bigSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@property (weak, nonatomic) IBOutlet UIControl *backControl;
@property (weak, nonatomic) IBOutlet UIControl *setControl;
@property (weak, nonatomic) IBOutlet UIControl *likeControl;
@property (weak, nonatomic) IBOutlet UIControl *shareControl;
@property (weak, nonatomic) IBOutlet UIControl *ciryFilterControl;
@property (weak, nonatomic) IBOutlet UIControl *bigSearchControl;
@property (weak, nonatomic) IBOutlet UIControl *chatControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityFilterLeft;
@property (assign, nonatomic) BOOL goLike;
@end

@implementation WTTopView
+ (instancetype)topViewInView:(UIView *)superView withType:(NSArray *)types
{
	WTTopView *view = (WTTopView *)[[NSBundle mainBundle] loadNibNamed:@"WTTopView" owner:self options:nil][0];
	view.frame = CGRectMake(0, 0, screenWidth, 64.0);
	if(types)
	{
		view.backControl.hidden = ![types containsObject:@(WTTopViewTypeBack)] ;
		view.likeControl.hidden = ![types containsObject:@(WTTopViewTypeLike)];
		view.shareControl.hidden = ![types containsObject:@(WTTopViewTypeShare)] ;
        view.filterControl.hidden = ![types containsObject:@(WTTopViewTypeFilter)] ;
        view.searchControl.hidden = ![types containsObject:@(WTTopViewTypeSearch)] ;
		view.ciryFilterControl.hidden = ![types containsObject:@(WTTopViewTypeCityFilter)] ;
		view.bigSearchControl.hidden = ![types containsObject:@(WTTopViewTypeBigSearch)] ;
		view.setControl.hidden = ![types containsObject:@(WTTopViewTypeSet)] ;
		view.chatControl.hidden = ![types containsObject:@(WTTopViewTypeChat)] ;
		view.setBGButton.hidden = ![types containsObject:@(WTTopViewTypeSetBG)] ;
		view.segmentCon.hidden = ![types containsObject:@(WTTopViewTypeSegment)] ;
	}
	view.goLike = [types containsObject:@(WTTopViewTypeChat)] && [types containsObject:@(WTTopViewTypeLike)];

	if([types containsObject:@(WTTopViewTypeBack)] && [types containsObject:@(WTTopViewTypeCityFilter)]){
		view.cityFilterLeft.constant = 50;
	}
	return view;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	_segmentCon.layer.cornerRadius = 5.0;
	_unreadLabel.text = @"0";
	_unreadLabel.textColor = rgba(153, 153, 153, 153);
	self.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];
}

- (void)setIs_like:(BOOL)is_like
{
	_is_like = is_like;
	_likeButton.selected = is_like;
}

- (void)setUnreadCount:(double)unreadCount
{
	_unreadCount = unreadCount;
	_unreadLabel.text = unreadCount > 99 ? @"99+" : @(unreadCount).stringValue ;
	_unreadLabel.textColor = _unreadCount <= 0 ? LightGragyColor : WeddingTimeBaseColor ;
}

- (IBAction)backAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedBack:)])
	{
		[self.delegate topView:self didSelectedBack:sender];
	}
}

- (IBAction)filterCityAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedCityFilter:)])
	{
		[self.delegate topView:self didSelectedCityFilter:sender];
	}
}

- (IBAction)setAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedSet:)])
	{
		[self.delegate topView:self didSelectedSet:sender];
	}
}

- (IBAction)setBGAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedSetBG:)]){
		[self.delegate topView:self didSelectedSetBG:sender];
	}
}

- (IBAction)chatAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedChat:)])
	{
		[self.delegate topView:self didSelectedChat:sender];
	}
}


- (IBAction)filterAction:(UIControl *)sender
{
    if([self.delegate respondsToSelector:@selector(topView:didSelectedFilter:)])
    {
        [self.delegate topView:self didSelectedFilter:sender];
    }
}

- (IBAction)searchAction:(UIControl *)sender
{
    if([self.delegate respondsToSelector:@selector(topView:didSelectedSearch:)])
    {
        [self.delegate topView:self didSelectedSearch:sender];
    }
}

- (IBAction)shareAction:(UIControl *)sender
{
	if([self.delegate respondsToSelector:@selector(topView:didSelectedShare:)])
	{
		[self.delegate topView:self didSelectedShare:sender];
	}
}

- (IBAction)segmentAction:(UISegmentedControl *)sender {
	if([self.delegate respondsToSelector:@selector(topView:didSelectedSegment:)])
	{
		[self.delegate topView:self didSelectedSegment:sender];
	}
}

- (IBAction)likeAction:(UIControl *)sender
{
	if(_goLike){
		if([self.delegate respondsToSelector:@selector(topView:didSelectedLike:)]){
			[self.delegate topView:self didSelectedLike:sender];
		}
		return ;
	}

	if (![LWAssistUtil isLogin] || (!_hotel_id && !_supplier_id && !_post_id)) { return; }

	_likeButton.selected = !_likeButton.selected;
	[_likeButton.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault] forKey:@"layerScale"];

	if(self.hotel_id)
	{
		[PostDataService postLikeWithHotel_id:_hotel_id Block:^(NSDictionary *restult, NSError *error) {
			[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			if (!error)
			{
				_is_like = !_is_like;
				double num = [UserInfoManager instance].num_like.integerValue;
				num += self.is_like ? 1 : -1 ;
				[UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
				[[UserInfoManager instance] saveToUserDefaults];

				if(_is_like)
				{
					NSString *title=[NSString stringWithFormat:@"喜欢了一个酒店\n%@   ",_name];
					[[ChatMessageManager instance] sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
						if (ourCov) {
							[ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_hotel_id,@"type":@"h",@"title":title,@"name":_name} andCovTitle:title  conversation:ourCov push:YES success:^{

							} failure:nil];
						}
					}];
				}

				if([self.delegate respondsToSelector:@selector(topView:didSelectedLike:)])
				{
					[self.delegate topView:self didSelectedLike:sender];
				}
			}
		}];
	}
	else if(self.supplier_id)
	{
		[PostDataService postLikeWithService_id:_supplier_id  Block:^(NSDictionary *result, NSError *error) {
			[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			if (!error) {
				_is_like = !_is_like;
				double num = [UserInfoManager instance].num_like.doubleValue;
				num += self.is_like ? 1 : -1 ;
				[UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
				[[UserInfoManager instance] saveToUserDefaults];

				if(_is_like)
				{
					NSString *title = [NSString stringWithFormat:@"喜欢了一个服务商\n%@   ",_name];
					[[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
						if (ourCov) {
							[ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_supplier_id,@"type":@"s",@"title":title,@"name":_name} andCovTitle:title  conversation:ourCov push:YES success:^{
							} failure:nil];
						}
					}];
				}

				if([self.delegate respondsToSelector:@selector(topView:didSelectedLike:)])
				{
					[self.delegate topView:self didSelectedLike:sender];
				}
			}
		}];
	}
	else if (self.post_id)
	{
		[PostDataService postLikeWithPostID:_post_id  Block:^(NSDictionary *result, NSError *error) {
			[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			if (!error) {
				_is_like = !_is_like;
				double num = [UserInfoManager instance].num_like.doubleValue;
				num += self.is_like ? 1 : -1 ;
				[UserInfoManager instance].num_like = [NSString stringWithFormat:@"%ld", (long)num];
				[[UserInfoManager instance] saveToUserDefaults];

				if(_is_like)
				{
					NSString *title = [NSString stringWithFormat:@"喜欢了一个作品\n%@   ",_name];
					[[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
						if (ourCov) {
							[ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:@{@"id":_post_id,@"type":@"post",@"title":title,@"name":_name} andCovTitle:title  conversation:ourCov push:YES success:^{
							} failure:nil];
						}
					}];
				}

				if([self.delegate respondsToSelector:@selector(topView:didSelectedLike:)])
				{
					[self.delegate topView:self didSelectedLike:sender];
				}
			}
		}];
	}
}

@end
