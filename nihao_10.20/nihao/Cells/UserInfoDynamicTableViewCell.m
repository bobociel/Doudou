//
//  UserInfoDynamicTableViewCell.m
//  nihao
//
//  Created by 刘志 on 15/8/25.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "UserInfoDynamicTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <pop/POP.h>
#import "Constants.h"
#import "MMGridView.h"
#import "UserPost.h"
#import "BaseFunction.h"
#import "AppDelegate.h"
#import "HttpManager.h"
#import "CopyLabel.h"
#import "AppConfigure.h"

@interface UserInfoDynamicTableViewCell() <MMGridViewDataSource,MMGridViewDelegate>{
    NSInteger _picWidth;
    NSInteger _picHeight;
    SDWebImageManager *_sdWebImageManager;
    UserPost *_post;
    MWPhotoBrowser *_photoBrowser;
    NSIndexPath *_indexPath;
}

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet CopyLabel *postContentLabel;
@property (weak, nonatomic) IBOutlet MMGridView *gridView;
@property (weak, nonatomic) IBOutlet UILabel *commentNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gridViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
- (IBAction)likePost:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *postAddress;
@property (weak, nonatomic) IBOutlet UIView *viewNumsView;
@property (weak, nonatomic) IBOutlet UILabel *viewNumsLabel;

@end

@implementation UserInfoDynamicTableViewCell

static const NSInteger PIC_MARGIN = 1.5;

- (void)awakeFromNib {
    _sdWebImageManager = [SDWebImageManager sharedManager];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureUserInfoDynamic:(UserPost *)post indexPath:(NSIndexPath *)indexPath {
    _post = post;
    _indexPath = indexPath;
    _nicknameLabel.text = post.ci_nikename;
    _timeLabel.text = [BaseFunction dynamicDateFormat:post.cd_date];
    _postContentLabel.text = post.cd_info;
    _commentNumLabel.text = [NSString stringWithFormat:@"%d",post.cd_sum_cmi_count];
    _likeNumLabel.text = [NSString stringWithFormat:@"%d",post.cd_sum_pii_count];
    
    //是否已经点赞
    NSString *likeImageName = (post.pii_is_praise == 0) ? @"common_icon_like" : @"common_icon_liked";
    _goodImageView.image = [UIImage imageNamed:likeImageName];
    
    //配置九宫格
    if(post.pictures.count == 0) {
        for(UIView *subView in _gridView.subviews) {
            subView.hidden = YES;
        }
        _gridViewHeightConstraint.constant = 0.0;
    } else {
        for(UIView *subView in _gridView.subviews) {
            subView.hidden = NO;
        }
        
        NSUInteger column = (post.pictures.count / 3 > 0) ? 3 : post.pictures.count % 3;
        NSUInteger row = (post.pictures.count % 3 == 0) ? post.pictures.count / 3 : (post.pictures.count / 3 + 1);
        _picWidth = 80;
        _picHeight = _picWidth;
        
        _gridView.numberOfRows = row;
        _gridView.numberOfColumns = column;
        _gridView.cellMargin = PIC_MARGIN;
        _gridViewHeightConstraint.constant = _picHeight * row;
        [_gridView reloadData];
    }
    _gridView.delegate = self;
    _gridView.dataSource = self;
    
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:_viewNumsView];
    _viewNumsLabel.text = [NSString stringWithFormat:@"%ld",post.cd_look_count];
    
    if(IsStringEmpty(post.cd_address)) {
        _postAddress.hidden = YES;
    } else {
        _postAddress.hidden = NO;
        _postAddress.text = post.cd_address;
    }
}

#pragma mark - MMGridViewDataSource
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView {
    return _post.pictures.count;
}

- (UIView *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index {
    UIButton *cell = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _picWidth, _picHeight)];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *placeHolder = [UIImage imageNamed:@"img_is_loading"];
    Picture *picture = _post.pictures[index];
    [_sdWebImageManager downloadImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture.picture_thumbnail_network_url]]
                                     options:0
                                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                       if(image && finished && !error) {
                                           [cell setImage:image forState:UIControlStateNormal];
                                       } else {
                                           [cell setImage:placeHolder forState:UIControlStateNormal];
                                       }
                                   }];
    return cell;
}

#pragma mark - MMGridViewDelegate
- (void)gridView:(MMGridView *)gridView didSelectCell:(UIView *)cell atIndex:(NSUInteger)index {
    if([_delegate respondsToSelector:@selector(postPhotoClickAtIndex : cellIndexPath :)]) {
        [_delegate postPhotoClickAtIndex:index cellIndexPath:_indexPath];
    }
}

#pragma mark - click events
- (IBAction)likePost:(id)sender {
    NSInteger distance = 8;
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_goodImageView.frame) + distance, CGRectGetHeight(_goodImageView.frame) + distance)];
    anim.springBounciness = 20;
    anim.completionBlock = ^(POPAnimation *anim,BOOL finished) {
        if(finished) {
            POPSpringAnimation *animSmaller = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
            animSmaller.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_goodImageView.frame) - distance, CGRectGetHeight(_goodImageView.frame) - distance)];
            animSmaller.springBounciness = 20;
            animSmaller.removedOnCompletion = YES;
            [_goodImageView.layer pop_addAnimation:animSmaller forKey:@"size_smaller"];
            
            NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:uid forKey:@"pii_ci_id"];
            [params setObject:[NSString stringWithFormat:@"%d",_post.cd_id] forKey:@"pii_source_id"];
            [params setObject:@"1" forKey:@"pii_source_type"];
            //点赞或取消点赞
            if(_post.pii_is_praise == 0) {
                [HttpManager userPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                _post.cd_sum_pii_count ++;
                _post.pii_is_praise = 1;
            } else {
                [HttpManager userCancelPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                _post.cd_sum_pii_count --;
                _post.pii_is_praise = 0;
            }
            _likeNumLabel.text = [NSString stringWithFormat:@"%d",_post.cd_sum_pii_count];
        }
    };
    anim.removedOnCompletion = YES;
    [_goodImageView.layer pop_addAnimation:anim forKey:@"size_bigger"];
    NSString *likeImageName = (_post.pii_is_praise == 0) ? @"common_icon_liked" : @"common_icon_like";
    _goodImageView.image = [UIImage imageNamed:likeImageName];
}
@end
