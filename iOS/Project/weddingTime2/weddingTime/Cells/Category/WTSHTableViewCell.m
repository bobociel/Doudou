//
//  WTSHTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "WTSHTableViewCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UserInfoManager.h"
#import "LWAssistUtil.h"
#import "PostDataService.h"
#import "WTProgressHUD.h"
#import "CommAnimationForControl.h"

@interface WTSHTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *topImage;
@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;

@property (weak, nonatomic) IBOutlet UIImageView *VIPImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeft;
@property (nonatomic,assign) int like_count;
@end

@implementation WTSHTableViewCell

- (void)awakeFromNib
{
	[self initView];
}

- (void)initView
{
    _topImage.clipsToBounds = YES;
	_VIPImageView.hidden = YES;

    _nameLabel.font = [UIFont boldSystemFontOfSize:18];
	_priceLabel.font = [UIFont systemFontOfSize:14.0];
	_priceLabel.textColor = WeddingTimeBaseColor;
    _detailLabel.textColor = subTitleLableColor;
    _detailLabel.font = DefaultFont12;

    [_likeButton setImage:[UIImage imageNamed:@"icon_unlike"] forState:UIControlStateNormal];
    [_likeButton setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateSelected];

	_videoIcon.image = [UIImage imageNamed:@"icon_video"];
    _videoIcon.hidden = YES;
}

- (void)dealLikeWithLike:(BOOL)isLike andTitle:(NSString *)title andInfo:(NSDictionary *)info
{
	double numberLike = [UserInfoManager instance].num_like.doubleValue;
	numberLike += isLike ? 1 : -1 ;
	[UserInfoManager instance].num_like = [NSString stringWithFormat:@"%.f",numberLike];
	[[UserInfoManager instance] saveToUserDefaults];

	if ([self.delegate respondsToSelector:@selector(WTSHTableViewCell:isLike:)])
	{
		[UIView animateWithDuration:0.3 animations:^{
			self.alpha = 0;
		} completion:^(BOOL finished) {
			[self.delegate WTSHTableViewCell:self isLike:isLike];
		}];
	}

	if(isLike)
	{
		[[ChatMessageManager instance]sendToOurConversationBeforeFinish:^(AVIMConversation *ourCov) {
			if (ourCov)
			{
				[ChatConversationManager sendCustomMessageWithPushName:title andConversationTypeKey:ConversationTypeLike andConversationValue:info andCovTitle:title  conversation:ourCov push:YES success:^{ } failure:nil];
			}
		}];
	}
}


- (IBAction)likeIconAction:(UIButton *)sender
{
    if (![LWAssistUtil isLogin]) { return; }

    sender.selected = !sender.selected;
    [sender.layer pop_addAnimation:[CommAnimationScale LayerScaleAnimationDefault]
                            forKey:@"layerScaleAnimationUnDefault"];
    
    if(_hotel)
    {
        [PostDataService postLikeWithHotel_id:_hotel.ID Block:^(NSDictionary *result, NSError *error)
        {
            if (error){
                [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
            }
            else
            {
				_hotel.is_like = !_hotel.is_like;
				_detailLabel.text = [NSString stringWithFormat:@"套餐 %.f·喜欢 %.f", _hotel.menuCount, _hotel.likeCount += _hotel.is_like ? 1 : -1 ];
                
                NSString *title=[NSString stringWithFormat:@"喜欢了一个酒店\n%@   ",_hotel.name];
                NSDictionary *likeInfo = @{@"id":_hotel.ID,@"type":@"h",@"title":title,@"name":_hotel.name};
				[self dealLikeWithLike:_hotel.is_like andTitle:title andInfo:likeInfo];
            }
        }];
    }
    else if(_supplier)
    {
        [PostDataService postLikeWithService_id:_supplier.supplierUserId Block:^(NSDictionary *result, NSError *error)
        {
            if (error)
            {
                [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"服务器出现问题，可能请求失败"] showInView:[UIApplication sharedApplication].keyWindow];
            }
            else
            {
				_supplier.is_like = !_supplier.is_like;
				_detailLabel.text = [NSString stringWithFormat:@"作品 %.f·喜欢 %.f", _supplier.workCount, _supplier.likeCount += _supplier.is_like ? 1 : -1 ];

                NSString *title=[NSString stringWithFormat:@"喜欢了一个服务商\n%@   ",_supplier.company];
                NSDictionary *likeInfo = @{@"id":_supplier.supplierUserId,@"type":@"s",@"title":title,@"name":_supplier.company};
				[self dealLikeWithLike:_supplier.is_like andTitle:title andInfo:likeInfo];
            }
        }];
    }
	else if(_post)
	{
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
}

- (void)setSupplier:(WTSupplier *)supplier
{
    _supplier = supplier;
    _videoIcon.hidden = (self.supplier_type != WTWeddingTypeVideo);
    _likeButton.selected = supplier.is_like;

	_nameLabel.text = supplier.company;
	_nameLabelLeft.constant = _supplier.level == WTSupplierLevelV0 ? 20 : 45;
	_VIPImageView.hidden = _supplier.level == WTSupplierLevelV0;
	_VIPImageView.image = [LWUtil getVIPImageWithSupplierLevel:_supplier.level];

	if([LWUtil getString:@"" andDefaultStr:_supplier.price].length > 0){
		_priceLabel.attributedText = [LWUtil attributeStringWithPrice:supplier.price];
	}else{
		_priceLabel.text = @"暂无报价";
	}

	_detailLabel.font = DefaultFont12;
    _detailLabel.text = [NSString stringWithFormat:@"作品 %.f·喜欢 %.f", supplier.workCount, supplier.likeCount];
    __weak UIImageView *top = _topImage;
    _topImage.contentMode = UIViewContentModeCenter;
    _topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];

	NSString *imageURL = [NSString stringWithFormat:@"%@%@",supplier.logo_path,kSmall600];
    [_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
                                  placeholderImage:nil
                                           options:SDWebImageRetryFailed
                                          progress:nil
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if (image != nil) {
                                                 top.contentMode =  UIViewContentModeScaleAspectFill;
                                             }
                                         }
                              ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
                            ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
                                          Diameter:50];
}

- (void)setHotel:(WTHotel *)hotel
{
    _hotel = hotel;
    _likeButton.selected = hotel.is_like;
    _nameLabel.text = hotel.name;
	_detailLabel.font = DefaultFont12;
    _detailLabel.text = [NSString stringWithFormat:@"套餐 %.f·喜欢 %.f", hotel.menuCount, hotel.likeCount];
	if([LWUtil getString:@"" andDefaultStr:_hotel.price_start].length > 0)
	{
		_priceLabel.attributedText = [LWUtil attributeStringWithPrice:_hotel.price_start];
	}
	else
	{
		_priceLabel.text = @"暂无报价";
	}

    __weak UIImageView *top = _topImage;
    _topImage.contentMode = UIViewContentModeCenter;
    _topImage.backgroundColor = [LWUtil colorWithHexString:@"f1f2f4"];

	NSString *imageURL = [NSString stringWithFormat:@"%@%@",hotel.main_pic,kSmall600];
    [_topImage setImageUsingProgressViewRingWithURL:[NSURL URLWithString:imageURL]
                                  placeholderImage:nil
                                           options:SDWebImageRetryFailed
                                          progress:nil
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if (image != nil) {
                                                 top.contentMode =  UIViewContentModeScaleAspectFill;
                                             }
                                         }
                              ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor]
                            ProgressSecondaryColor:[LWUtil colorWithHexString:@"e3e3e3"]
                                          Diameter:50];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation UITableView(WTSHTableViewCell)

- (WTSHTableViewCell *)WTSHTableViewCell{

	static NSString *CellIdentifier = @"WTSHTableViewCell";

	WTSHTableViewCell * cell = (WTSHTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = (WTSHTableViewCell *)[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil][0];
		cell.backgroundColor = rgba(247, 247, 247, 1);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}
@end
