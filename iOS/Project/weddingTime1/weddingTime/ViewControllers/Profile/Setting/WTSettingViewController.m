//
//  SettingViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "WTSettingViewController.h"
#import "WTChangePasswordViewController.h"
#import "WTAboutLovewithViewController.h"
#import "QHNavigationController.h"
#import "WTAlertView.h"
#import "UserInfoManager.h"
#import "WTFindViewController.h"
#import "FSMediaPicker.h"
#import "GetService.h"
#import "QiniuSDK.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTProfileViewController.h"
#import "FSMediaPicker.h"
#import "UIImage+GaussianBlur.h"
#import "ChatMessageManager.h"
#import "UserService.h"
#import "PushNotifyCore.h"
#import "WTPCViewController.h"
#import "UIImage+Utils.h"
#import "UIImage+FixOrientation.h"
#import "WTChatDetailViewController.h"
#import "UIImage+YYAdd.h"
#import <SDWebImage/SDImageCache.h>
#define kTableHeaderViewHeight 300.0f
#define kCellHeight            50.0f
#define kBingButtonLeft        50.0f
#define kBingButtonHeight      30.0f
@interface WTSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,FSMediaPickerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic)  UIImageView *backgroundImageView;
@property (strong, nonatomic)  UITableView *settingTableView;
@property (nonatomic,strong)   NSArray *settingArray;
@end

@implementation WTSettingViewController
{
    UIImageView *myHeadImageView;
    UIImageView *partnerHeadImageView;
    int avataTag;
    NSString *avataKeySelf;
    NSString *avataKeyPartner;
    UIButton *bindOrRebingBtn;
    UIButton *improveBtn;
    UIButton *rightBtn;
    UIView *view;
    UIView *tableHeadview;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reBlingSucceed) name:UserDidRebindSucceedNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reBlingSucceed) name:UserDidBindingPartnerNotify object:nil];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    [self showBlurBackgroundView];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    [self setNavWithClearColor];
    rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"设置背景" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:16];
    rightBtn.frame=CGRectMake((screenWidth-74), 17, 64, 16);
    [rightBtn addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    UIViewController *pushVC = self.navigationController.viewControllers.lastObject;
    if(pushVC && ![pushVC isKindOfClass:[WTProfileViewController class]]){
     	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserDidRebindSucceedNotify object:nil];
}

-(void)initView{
    [self.view addSubview:[UIView new]];
    self.view.clipsToBounds=YES;
    
    self.settingArray=@[@"完善我们",@"设置背景",@"设置密码",@"清理缓存",@"关于婚礼时光",@"投诉与建议",@"去评价",@"服务条款",@"隐私政策",@"退出"];
    
    tableHeadview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenHeight, kTableHeaderViewHeight)];
    tableHeadview.backgroundColor=[UIColor clearColor];
    
    myHeadImageView=[[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-160)/2, 90, 80, 80)];
    myHeadImageView.tag                         = 0;
    myHeadImageView.backgroundColor=[UIColor clearColor];
    myHeadImageView.layer.cornerRadius=40.f;
    myHeadImageView.clipsToBounds=YES;
    myHeadImageView.layer.borderWidth=2.f;
    myHeadImageView.layer.borderColor=([UIColor whiteColor].CGColor);
    myHeadImageView.userInteractionEnabled      = YES;
    
    partnerHeadImageView=[[UIImageView alloc]initWithFrame:CGRectMake(myHeadImageView.right-10, 90, 80, 80)];
    partnerHeadImageView.tag                         = 0;
    partnerHeadImageView.backgroundColor=[UIColor clearColor];
    partnerHeadImageView.layer.cornerRadius=40.f;
    partnerHeadImageView.clipsToBounds=YES;
    partnerHeadImageView.layer.borderWidth=2.f;
    partnerHeadImageView.layer.borderColor=([UIColor whiteColor].CGColor);
    partnerHeadImageView.userInteractionEnabled      = YES;

	UITapGestureRecognizer *tapMyHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
	UITapGestureRecognizer *tapPartnerHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
	[myHeadImageView addGestureRecognizer:tapMyHeader];
	[partnerHeadImageView addGestureRecognizer:tapPartnerHeader];

    bindOrRebingBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    bindOrRebingBtn.frame=CGRectMake(kBingButtonLeft, partnerHeadImageView.bottom+40, screenWidth - 2 *kBingButtonLeft, kBingButtonHeight);
    bindOrRebingBtn.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:20];
    bindOrRebingBtn.titleLabel.textColor=[UIColor whiteColor];
    bindOrRebingBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    bindOrRebingBtn.backgroundColor=[UIColor clearColor];
    [bindOrRebingBtn addTarget:self action:@selector(bindOrRebindEvent) forControlEvents:UIControlEventTouchUpInside];
    [tableHeadview addSubview:bindOrRebingBtn];
    
    [tableHeadview addSubview:partnerHeadImageView];
    [tableHeadview addSubview:myHeadImageView];
    
    self.settingTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.settingTableView.delegate=self;
    self.settingTableView.dataSource=self;
    self.settingTableView.showsHorizontalScrollIndicator=NO;
    self.settingTableView.backgroundColor=[UIColor clearColor];
    self.settingTableView.scrollEnabled=YES;
    self.settingTableView.tableHeaderView=tableHeadview;
    [self.view addSubview:self.settingTableView];
    view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    view.frame = view.frame=CGRectMake(0, kTableHeaderViewHeight, screenWidth, 2*screenHeight);
    [self.view insertSubview:view belowSubview:self.settingTableView];

	[self reloadValue];
}

- (void)reloadValue
{
	[[UserInfoManager instance]setMyAvatar:myHeadImageView];
	[[UserInfoManager instance]setPartnerAvatar:partnerHeadImageView];

	if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
		[bindOrRebingBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
	}else{
		[bindOrRebingBtn setTitle:@"绑定另一半" forState:UIControlStateNormal];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView=(UIScrollView *)self.settingTableView;
    view.frame=CGRectMake(0, kTableHeaderViewHeight - scrollView.contentOffset.y, screenWidth, scrollView.contentOffset.y + screenHeight*2);

	if (scrollView.contentOffset.y < 0)
	{
		UIImage *back=[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
		if (!back) {
			back = [UIImage imageNamed:@"Bitmap.jpg"];
		}

		float state = (170 + scrollView.contentOffset.y) / 170;
		if (state >= 0.169) {
			UIImage *blImage = [back imageByBlurRadius:state * 40 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
			[self setBlurImageViewWithImage:blImage state:state];
		}
	}
}

-(void)goProfile{
    [self.navigationController pushViewController:[WTProfileViewController new] animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return kCellHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.settingArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor whiteColor];
        if (indexPath.row == WTSetTypeExit) {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
		case WTSetTypeProfile: { [self goProfile]; } break;
		case WTSetTypeSetBG: { [self chooseImage]; } break;
		case WTSetTypeSetPSW: { [self.navigationController pushViewController:[WTChangePasswordViewController new] animated:YES];}
			break;
		case WTSetTypeClearMemory:{
			[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
			//NSLog(@"%lu",(unsigned long)[[SDImageCache sharedImageCache] getSize]);
			[[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
				//NSLog(@"%lu",(unsigned long)[[SDImageCache sharedImageCache] getSize]);
				[WTProgressHUD ShowTextHUD:@"清理完毕" showInView:KEY_WINDOW afterDelay:2.0];
			}];
			break;
		}
        case WTSetTypeAboutAs: { [self.navigationController pushViewController:[WTAboutLovewithViewController new] animated:YES];}
            break;
        case WTSetTypeSuggest: {
            NSMutableArray *ids=[[NSMutableArray alloc] initWithArray:@[[UserInfoManager instance].userId_self,hotelHunlishiguangId]];
            
            if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
                [ids addObject:[UserInfoManager instance].userId_partner];
            }
            [self showLoadingViewTitle:@"创建会话中"];
            [ChatConversationManager getConversationWithClientIds:ids type:kConversationType_Group withBlock:^(AVIMConversation *conversation, NSError *error,BOOL iscreated) {
                if (error) {
                    [self hideLoadingView];
                    [WTProgressHUD ShowTextHUD:@"服务器出错" showInView:KEY_WINDOW];
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
                    [ChatConversationManager getUserDataWithMember:msgList finish:^{//当取完缓存后获取用户数据并刷新
                        [self hideLoadingView];
                        WTChatDetailViewController *next=[[WTChatDetailViewController alloc]initWithNibName:@"WTChatDetailViewController" bundle:nil];
						next.convType = WTConversationTypeCustomer;
                        next.conversation=conversation;
                        next.keyConversation=[conversation keyedConversation];
                        next.conversationId=conversation.conversationId;
                        [self.navigationController pushViewController:next animated:YES];
                    }];
                }
            }];
        }
            break;
        case WTSetTypeComment:
        {
            NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d",1005404187 ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
        }
            break;
        case WTSetTypeProtocol:
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/service_term"]];
        }
            break;
        case WTSetTypePolicy:
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/privacy_term"]];
        }
            break;
        case WTSetTypeExit:
        {
            [self logout];
        }
            break;
            
        default:
            break;
    }
}

-(void)reBlingSucceed{
    [LoginManager reblinding];
    [self reloadValue];
}

- (void)logout {
    WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"确定要退出登录吗?" centerImage:nil];
    alertView.buttonTitles=@[@"取消",@"确定"];
    [alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
        if (buttonIndex==1) {
            //确认
            [self showLoadingView];
            [LoginManager logoutWithFinishBlock:^{
                [self hideLoadingView];
            }];
        }else{
        }
    }];
    
    [alertView show];
    
}

- (void)logoutFinish {
    [self hideLoadingView];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutSucceedNotify object:nil];
    QHNavigationController *nav = [[QHNavigationController alloc] initWithRootViewController:[WTFindViewController new]];
    KEY_WINDOW.rootViewController  =nav;
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
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.mediaType      = FSMediaTypePhoto;
    mediaPicker.delegate       = self;
    mediaPicker.editMode = FSEditModeNone;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    } else if (buttonIndex == 2){
        UIImage *image = [UIImage imageNamed:@"Bitmap.jpg"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"image"];
        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"image"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:PushbackgroundImageChanged object:image];
    } else {
        
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo{
    [self showLoadingViewTitle:@"处理中..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        UIImage *image=  [mediaInfo.originalImage fixOrientation];
        float width=image.size.width;
        float height=width*screenHeight/screenWidth;
        if(height>image.size.height)
        {
            height=image.size.height;
            width=height*screenWidth/screenHeight;
        }
        float x=(image.size.width-width)/2;
        float y=(image.size.height-height)/2;
        image=[image getSubImage:CGRectMake(x, y, width, height)];
        image =[image renderAtSize:KEY_WINDOW.bounds.size];
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"image"];
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

@end
