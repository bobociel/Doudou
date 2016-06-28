//
//  SettingViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "WTSettingViewController.h"
#import "QHNavigationController.h"
#import "WTFindViewController.h"
#import "WTProfileViewController.h"
#import "WTChatDetailViewController.h"
#import "WTChangePasswordViewController.h"
#import "WTBindingViewController.h"
#import "WTAboutLovewithViewController.h"
#import "WTAlertView.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTTopView.h"
#import "PushNotifyCore.h"
#import "UserInfoManager.h"
#import "ChatMessageManager.h"
#import "FSMediaPicker.h"
#import "UserService.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+YYAdd.h"
#define kTableHeaderViewHeight 300.0f
#define kCellHeight            50.0f
#define kBingButtonLeft        50.0f
#define kBingButtonHeight      30.0f
@interface WTSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,FSMediaPickerDelegate,UIScrollViewDelegate,WTTopViewDelegate>
@property (strong, nonatomic)  UIImageView *backgroundImageView;
@property (strong, nonatomic)  UITableView *settingTableView;
@property (nonatomic,strong)   NSArray *settingArray;
@property (nonatomic,strong) WTTopView *topView;
@end

@implementation WTSettingViewController
{
	int avataTag;
	UIView *tableHeadview;
	UIView *whiteView;

    UIImageView *myHeadImageView;
    UIImageView *partnerHeadImageView;

	UIButton *bindOrRebingBtn;
	UIButton *existButton;

    NSString *avataKeySelf;
    NSString *avataKeyPartner;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    [self showBlurBackgroundView];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    [self reloadValue];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reBlingSucceed) name:UserDidRebindSucceedNotify object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UserDidRebindSucceedNotify object:nil];
    UIViewController *pushVC = self.navigationController.viewControllers.lastObject;
    if(pushVC && ![pushVC isKindOfClass:[WTProfileViewController class]]){
     	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
    }
}

-(void)initView
{
    self.view.clipsToBounds = YES;
    
    self.settingArray=@[@"完善我们",@"设置密码",@"清理缓存",@"关于婚礼时光",@"联系客服"];
    
    tableHeadview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, kTableHeaderViewHeight)];
    tableHeadview.backgroundColor = [UIColor clearColor];
    
    myHeadImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-160)/2, 90, 80, 80)];
    myHeadImageView.backgroundColor = [UIColor clearColor];
    myHeadImageView.layer.cornerRadius = 40.f;
    myHeadImageView.clipsToBounds = YES;
    myHeadImageView.layer.borderWidth = 3.f;
    myHeadImageView.layer.borderColor = ([UIColor whiteColor].CGColor);
    myHeadImageView.userInteractionEnabled = YES;
    
    partnerHeadImageView=[[UIImageView alloc]initWithFrame:CGRectMake(myHeadImageView.right-10, 90, 80, 80)];
    partnerHeadImageView.backgroundColor = [UIColor clearColor];
    partnerHeadImageView.layer.cornerRadius = 40.f;
    partnerHeadImageView.clipsToBounds = YES;
    partnerHeadImageView.layer.borderWidth = 3.f;
    partnerHeadImageView.layer.borderColor = ([UIColor whiteColor].CGColor);
    partnerHeadImageView.userInteractionEnabled = YES;

	[tableHeadview addSubview:partnerHeadImageView];
	[tableHeadview addSubview:myHeadImageView];

	UITapGestureRecognizer *tapMyHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
	UITapGestureRecognizer *tapPartnerHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
	[myHeadImageView addGestureRecognizer:tapMyHeader];
	[partnerHeadImageView addGestureRecognizer:tapPartnerHeader];

    bindOrRebingBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    bindOrRebingBtn.frame=CGRectMake(kBingButtonLeft, partnerHeadImageView.bottom + 40, screenWidth - 2 *kBingButtonLeft, kBingButtonHeight);
	bindOrRebingBtn.backgroundColor=[UIColor clearColor];
	bindOrRebingBtn.titleLabel.font = [WeddingTimeAppInfoManager blodFontWithSize:20];
    bindOrRebingBtn.titleLabel.textColor = [UIColor whiteColor];
	bindOrRebingBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [bindOrRebingBtn addTarget:self action:@selector(bindOrRebindEvent) forControlEvents:UIControlEventTouchUpInside];
    [tableHeadview addSubview:bindOrRebingBtn];
    
    self.settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight) style:UITableViewStylePlain];
	self.settingTableView.backgroundColor=[UIColor clearColor];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
	self.settingTableView.tableFooterView = [[UIView alloc] init];
    self.settingTableView.tableHeaderView = tableHeadview;
    [self.view addSubview:_settingTableView];

    whiteView=[[UIView alloc] initWithFrame:CGRectMake(0, kTableHeaderViewHeight, screenWidth, 2*screenHeight)];
    whiteView.backgroundColor=[UIColor whiteColor];
    [self.view insertSubview:whiteView belowSubview:self.settingTableView];

	[self reloadValue];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeSetBG)]];
	self.topView.delegate = self;
	[self.view addSubview:_topView];

	existButton = [UIButton buttonWithType:UIButtonTypeCustom];
	existButton.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	existButton.backgroundColor = [UIColor whiteColor];
	[existButton setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
	[existButton setTitle:@"退出" forState:UIControlStateNormal];
	[self.view addSubview:existButton];
	[existButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
	lineView.backgroundColor = rgba(230, 230, 230, 1);
	[existButton addSubview:lineView];
}

- (void)reloadValue
{
	[[UserInfoManager instance] setMyAvatar:myHeadImageView];
	[[UserInfoManager instance] setPartnerAvatar:partnerHeadImageView];

	if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
		partnerHeadImageView.hidden = NO;
		myHeadImageView.frame = CGRectMake((screenWidth-160)/2, 90, 80, 80);
		[bindOrRebingBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
	}else{
		partnerHeadImageView.hidden = YES;
		myHeadImageView.frame = CGRectMake((screenWidth-80)/2, 90, 80, 80);
		[bindOrRebingBtn setTitle:@"绑定另一半" forState:UIControlStateNormal];
	}
}

- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedSetBG:(UIControl *)chatButton
{
	[self chooseImage];
}

- (void)goProfile
{
    [self.navigationController pushViewController:[WTProfileViewController new] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, 0, 104, kCellHeight)];
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentLeft;
        label.font=[WeddingTimeAppInfoManager fontWithSize:16];
        label.textColor=rgba(102, 102, 102, 1);
        label.alpha=0.9;
        label.text=self.settingArray[indexPath.row];
        [cell.contentView addSubview:label];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
	{
		case WTSetTypeProfile: { [self goProfile]; } break;
		case WTSetTypeSetPSW:
		{
			if([UserInfoManager instance].phone_self.length == 0){
				[self.navigationController pushViewController:[WTBindingViewController instanceWTBindingViewControllerWithToken:TOKEN] animated:YES];
			}else{
				[self.navigationController pushViewController:[WTChangePasswordViewController instanceVCWithToken:TOKEN] animated:YES];
			}
		} break;
		case WTSetTypeClearMemory:
		{
			[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
			[self showLoadingView];
			[[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self hideLoadingView];
					[WTProgressHUD ShowTextHUD:@"清理完毕" showInView:KEY_WINDOW afterDelay:1.0];
				});
			}];
		} break;
        case WTSetTypeAboutAs:
		{
			[self.navigationController pushViewController:[WTAboutLovewithViewController new] animated:YES];
		} break;
        case WTSetTypeSuggest:
		{
            NSMutableArray *ids=[[NSMutableArray alloc] initWithArray:@[[UserInfoManager instance].userId_self,kServerID]];

			[[UserInfoManager instance].userId_partner isNotEmptyCtg] ? [ids addObject:[UserInfoManager instance].userId_partner] : nil;

            [self showLoadingViewTitle:@"创建会话中"];
            [ChatConversationManager getConversationWithClientIds:ids type:WTConversationTypeHotelOrCustomer withBlock:^(AVIMConversation *conversation, NSError *error) {
                if (error) {
                    [self hideLoadingView];
					[WTProgressHUD ShowTextHUD:IFDEBUG ? error.localizedDescription : @"服务器出错" showInView:KEY_WINDOW];
                }
                else
                {
                    NSMutableArray *msgList=[[NSMutableArray alloc]init];
                    for (NSString *member in conversation.members) {
                        if (![member isEqualToString:[UserInfoManager instance].userId_self]) {
                            NSDictionary *channel=@{conversation.conversationId:member};
                            [msgList addObject:channel];
                        }
                    }
                    [ChatConversationManager getUserDataWithMember:msgList finish:^{
                        [self hideLoadingView];
                        WTChatDetailViewController *next=[[WTChatDetailViewController alloc] init];
                        next.conversation = conversation;
                        next.keyConversation=[conversation keyedConversation];
                        next.conversationId=conversation.conversationId;
                        [self.navigationController pushViewController:next animated:YES];
                    }];
                }
            }];
        } break;
        default: break;
    }
}

- (void)reBlingSucceed
{
    [LoginManager reblinding];
    [self reloadValue];
}

- (void)logout {
    WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"确定要退出登录吗?" centerImage:nil];
    alertView.buttonTitles=@[@"取消",@"确定"];
    [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
        if (buttonIndex==1) {
            //确认
            [self showLoadingView];
            [LoginManager logoutWithFinishBlock:^{
                [self hideLoadingView];
            }];
        }
    }];
    
    [alertView show];
}

-(void)chooseImage{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"设置背景"
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"拍照",@"从相册中选",@"使用原背景" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"%@",actionSheet.subviews);
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.mediaType      = FSMediaTypePhoto;
    mediaPicker.delegate       = self;
    mediaPicker.editMode = FSEditModeNone;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    } else if (buttonIndex == 2){
        UIImage *image = [UIImage imageNamed:@"defaultBG"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"image"];
        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"image"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PushbackgroundImageChanged object:image];
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo{
    [self showLoadingViewTitle:@"处理中..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image=  [mediaInfo.originalImage fixOrientation];
		image = [image imageByResizeToSize:CGSizeMake(screenWidth, screenHeight) contentMode:UIViewContentModeScaleAspectFill];
		image = [image imageByBlurRadius:20 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"image"];
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"image"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self hideLoadingView];
            [[NSNotificationCenter defaultCenter]postNotificationName:PushbackgroundImageChanged object:image];
            [WTProgressHUD ShowTextHUD:@"设置成功" showInView:self.view];
        });
    });
}

-(void)bindOrRebindEvent{
	if([[UserInfoManager instance].phone_partner isNotEmptyCtg]){
		AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"解除绑定"
																					message:@"确定要与另一半解除绑定吗?"];
		alertView.delegate = self;
		[alertView addOtherButtonWithTitle:@"解除绑定" onTapped:^{
			[self showLoadingView];
			[UserService postDrapReleshipWithBlock:^(NSDictionary *result, NSError *error) {
				[self hideLoadingView];
				if (error) {
					[self showLoadingViewTitle:@"出错啦,请稍后再试"];
				}else {
					[[UserInfoManager instance] updateUserInfoFromServer];
					[self showLoadingViewTitle:@"解除绑定成功"];
					[bindOrRebingBtn setTitle:@"绑定另一半" forState:UIControlStateNormal];
					[[NSNotificationCenter defaultCenter] postNotificationName:UserDidRebindSucceedNotify object:nil];
				}
				[self hideLoadingViewAfterDelay:1.0f];
			}];
		}];
		[alertView setCancelButtonWithTitle:@"取消" onTapped:^{

		}];
		[alertView show];
	}
	else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	scrollView=(UIScrollView *)self.settingTableView;
	whiteView.frame=CGRectMake(0, kTableHeaderViewHeight - scrollView.contentOffset.y, screenWidth, scrollView.contentOffset.y + screenHeight*2);

	if (scrollView.contentOffset.y < 0)
	{
		UIImage *back = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
		if (!back) {
			back = [UIImage imageNamed:@"defaultBG"];
		}
	}
}

@end

//- (void)logoutFinish {
//    [self hideLoadingView];
//    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutSucceedNotify object:nil];
//    QHNavigationController *nav = [[QHNavigationController alloc] initWithRootViewController:[WTFindViewController new]];
//    KEY_WINDOW.rootViewController  = nav;
//}

