//
//  WTSHTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WTWeddingShopCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UserInfoManager.h"
#import "LWAssistUtil.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "CommAnimationForControl.h"

@interface WTWeddingShopCell ()
@property (weak, nonatomic) IBOutlet UIImageView *topImage;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *VIPImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) CALayer *gradientLayer;
@end

@implementation WTWeddingShopCell

- (void)awakeFromNib {
	[self initView];
}

- (void)initView
{
	_gradientLayer = [LWUtil gradientLayerWithFrame:CGRectMake(0, 200*Height_ato, screenWidth, 100*Height_ato)];
	[_topImage.layer insertSublayer:_gradientLayer below:_avatarImageView.layer];

    _topImage.clipsToBounds = YES;
	_VIPImageView.hidden = YES;
	_topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];
	_topImage.contentMode = UIViewContentModeScaleAspectFill;
	_avatarImageView.layer.masksToBounds = YES;
	_avatarImageView.layer.cornerRadius = _avatarImageView.height / 2.0;
	_avatarImageView.contentMode = UIViewContentModeScaleAspectFill;

    _nameLabel.font = [UIFont boldSystemFontOfSize:20];
	_priceLabel.font = DefaultFont12;
	_priceLabel.textColor = rgba(153, 153, 153, 1);
    _detailLabel.font = DefaultBlodFont16;
	_detailLabel.textColor = WeddingTimeBaseColor;
	_companyLabel.font = DefaultFont12;
	_companyLabel.textColor = rgba(153, 153, 153, 1);
	_couponLabel.font = DefaultFont12;
	_couponLabel.textColor = rgba(153, 153, 153, 1);
}

- (void)setPost:(WTSupplierPost *)post{
	_post = post;
	_likeButton.selected = _post.is_like;
	_companyLabel.text = [LWUtil getString:_post.company andDefaultStr:@""];
	_nameLabel.text = [LWUtil getString:_post.title andDefaultStr:@""];
	_priceLabel.text = [NSString stringWithFormat:@"%@·%@·¥%@起",
						[LWUtil getString:_post.service_name andDefaultStr:@""],
						[LWUtil getString:_post.city andDefaultStr:@""],
						[LWUtil getString:_post.price andDefaultStr:@"0"]];

	_VIPImageView.hidden = _post.level == WTSupplierLevelV0;
	_VIPImageView.image = [LWUtil getVIPImageWithSupplierLevel:_post.level];

	if(!_post.min_coupon){
		_detailLabel.text = @"暂无优惠";
	}else if([_post.min_coupon isEqualToString:_post.max_coupon]){
		_detailLabel.text = [NSString stringWithFormat:@"￥%@",_post.min_coupon];
	}else{
		_detailLabel.text = [NSString stringWithFormat:@"￥%@-%@",_post.min_coupon,_post.max_coupon];
	}

	[_avatarImageView setImageWithURL:[NSURL URLWithString:_post.avatar]
						  placeholder:[WeddingTimeAppInfoManager avatarPlcehold]];

	NSString *imageURL = [NSString stringWithFormat:@"%@%@",_post.cover,kSmall600];
	[_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
								   placeholderImage:nil
											options:SDWebImageRetryFailed
										   progress:nil
										  completed:nil
							   ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
							 ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
										   Diameter:50];
}

- (IBAction)likeAction:(UIButton *)sender
{
	if (![LWAssistUtil isLogin]) { return; }

	sender.selected = !sender.selected;
	[sender.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault]
							forKey:@"layerScaleAnimationUnDefault"];

	[PostDataService postLikeWithPostID:_post.ID Block:^(NSDictionary *result, NSError *error)
	 {
		 if (error)
		 {
			 [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
		 }
		 else
		 {
			 _post.is_like = !_post.is_like;
			 NSString *title=[NSString stringWithFormat:@"喜欢了一个作品\n%@   ",_post.title];
			 NSDictionary *likeInfo = @{@"id":_post.ID,@"type":@"post",@"title":title,@"name":_post.company};
			 [self dealLikeWithLike:_post.is_like andTitle:title andInfo:likeInfo];
		 }
	 }];
}

- (void)dealLikeWithLike:(BOOL)isLike andTitle:(NSString *)title andInfo:(NSDictionary *)info
{
	double numberLike = [UserInfoManager instance].num_like.doubleValue;
	numberLike += isLike ? 1 : -1 ;
	[UserInfoManager instance].num_like = [NSString stringWithFormat:@"%.f",numberLike];
	[[UserInfoManager instance] saveToUserDefaults];

	if ([self.delegate respondsToSelector:@selector(WTWeddingShopCell:isLike:)])
	{
		[UIView animateWithDuration:0.3 animations:^{
			self.alpha = 0;
		} completion:^(BOOL finished) {
			[self.delegate WTWeddingShopCell:self isLike:_post.is_like];
		}];
	}

	if(isLike)
	{
		[[ChatMessageManager instance] sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
			if (ourCov)
			{
				[ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:info andCovTitle:title  conversation:ourCov push:YES success:^{ } failure:nil];
			}
		}];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView(WTWeddingShopCell)

- (WTWeddingShopCell *)WTWeddingShopCell{

	static NSString *CellIdentifier = @"WTWeddingShopCell";

	WTWeddingShopCell * cell = (WTWeddingShopCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTWeddingShopCell *)[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		cell.backgroundColor = rgba(233, 233, 233, 1);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
@end
