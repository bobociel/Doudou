//
//  ChatListViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTChatListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTMainViewController.h"
#import "AVOSCloudIM.h"
#import "ChatListCell.h"
#import "ChatMessageManager.h"
#import "ConversationStore.h"
#import "NetWorkingFailDoErr.h"
#import "UserInfoManager.h"
#import "WTTopView.h"
#import "WTProgressHUD.h"
#import "UIImage+YYAdd.h"
#define maxPageCount 15
@interface WTChatListViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerTransitioningDelegate,ChatMessageManagerDelegate,WTTopViewDelegate>
{
	BOOL bIsLoadingMore;
	BOOL bHaveMore;

	UITableView *dataTableView;

	NSMutableArray *currentConversations;

	ListErrorBtn *errBtn;

	BOOL ifLoadFirstData;
}
@property (nonatomic,strong) WTTopView *topView;
@end

@implementation WTChatListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBlurBackgroundView];
    [self initView];
    [self initData];
    if (![[ChatMessageManager instance] isFirstGetMsg]) {//已经取过数据，可以先显示数据
        [self firstLoadData];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
	[[ChatMessageManager instance] addObserver:self forName:listUpdateObserver];
	[[ChatMessageManager instance] addObserver:self forName:ourUpdateObserver];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:UserDidRebindSucceedNotify object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
}

- (void)dealloc
{
	[[ChatMessageManager instance] removeObserver:self forName:listUpdateObserver];
	[[ChatMessageManager instance] removeObserver:self forName:ourUpdateObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)initData
{
    bHaveMore=YES;
    currentConversations=[[NSMutableArray alloc]init];
}

//加载数据只做一次，其他时候调用永远只是针对用户信息更新，dataTableView重载即可
-(void)firstLoadData
{
    if (!ifLoadFirstData) {
        [currentConversations removeAllObjects];
        [self loadData];
        ifLoadFirstData=YES;
    }
    [dataTableView reloadData];
}

- (void)updateTableView
{
	currentConversations = [NSMutableArray array];
	[dataTableView reloadData];
}

-(void)loadData
{
    [self getConvWithNumber:maxPageCount];
}

-(void)initView
{
    errBtn = [[ListErrorBtn alloc]init];

    dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight ,screenWidth,screenHeight - kNavBarHeight)];
    dataTableView.backgroundColor = [UIColor clearColor];
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	dataTableView.delegate = self;
	dataTableView.dataSource = self;
    [self.view addSubview:dataTableView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack)]];
	self.topView.delegate = self;
	[self.view addSubview:self.topView];
}

- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatListCell getHeight];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatListCell *cell;
    if (indexPath.row == 0) {
        if (![[UserInfoManager instance].userId_partner isNotEmptyCtg])
		{
            cell= [tableView ChatListCellWithCellIdentifier:cellidentifier_bind];
            cell.avatar.image= [[UserInfoManager instance] defaultAvatarPartner];
        }
        else
        {
            //首次显示时没有另一半的信息缓存，会导致null
            cell= [tableView ChatListCellWithCellIdentifier:cellidentifier_listcell];
            Message *dataDic;
            if ([ChatMessageManager instance].keyedConversationOur) {
                NSString*KEY=[ChatMessageManager instance].keyedConversationOur.conversationId;
                if ([[ChatMessageManager instance]containLastMessageByConversationId:KEY]){
                    dataDic=[[ChatMessageManager instance] getLastMessageByConversationId:KEY];
                }
            }
            [cell setOneOneInfo:dataDic partner:[UserInfoManager instance].userId_partner];
        }
    }
    else
    {
        cell = [tableView ChatListCellWithCellIdentifier:cellidentifier_listcell];
        NSInteger index = indexPath.row-1;
        if (currentConversations.count <= index) {
            return nil;
        }
        AVIMKeyedConversation *KeyedConversation=(AVIMKeyedConversation*)currentConversations[index];
        NSString*KEY = KeyedConversation.conversationId;
        
        id dataDic = [[ChatMessageManager instance] getLastMessageByConversationId:KEY];
		WTConversationType type = [KeyedConversation.attributes[@"type"] integerValue];
        if (type != WTConversationTypePartner)
		{
			[cell setGroupInfo:dataDic members:KeyedConversation.members andConversation:KeyedConversation];
        }
        else
        {
            NSString *partner;
            for (NSString *userId in KeyedConversation.members) {
                if (![userId isEqualToString:[UserInfoManager instance].userId_self]
					&&![userId isEqualToString:[UserInfoManager instance].userId_partner]) {
                    partner = userId;
                    break;
                }
            }
            [cell setOneOneInfo:dataDic partner:partner];
        }
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentConversations.count + 1;
}


#pragma mark - TableViewEdit
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        int row=(int)indexPath.row-1;
        [self deleteFinish:row];
    }
}

-(void)deleteFinish:(NSInteger)row
{
    [[ConversationStore sharedInstance] deleteConversation:currentConversations[row]];
    [[ConversationStore sharedInstance] saveConversations];
    [currentConversations removeObjectAtIndex:row];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row+1 inSection:0];
    [dataTableView deleteRowsAtIndexPaths:[[NSArray alloc]initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    if ([currentConversations count]<maxPageCount) {
        NSArray*indexArr=  [self getConvWithNumber:1];
        if (indexArr&&indexArr.count>0) {
            [dataTableView insertRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

-(NSArray*)getConvWithNumber:(int)num
{
    if (bIsLoadingMore||!bHaveMore) {
        return nil;
    }
    bIsLoadingMore=YES;
    
    NSMutableArray *indexArr=[NSMutableArray arrayWithCapacity:maxPageCount];
    NSArray *KeyedConversations = [ChatMessageManager instance].keyedConversations;
    int beginI=(int)[currentConversations count];
    int allcount=(int)KeyedConversations.count;
    NSMutableArray *resultArray=[[NSMutableArray alloc]init];
    int getNum=0;
    for(int i=beginI;i<allcount&&getNum<num;i++) {
        AVIMKeyedConversation *conversation=(AVIMKeyedConversation*)KeyedConversations[i];
        NSString*KEY=conversation.conversationId;
        if ([[ChatMessageManager instance]containLastMessageByConversationId:KEY])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
            [indexArr addObject:indexPath];
            [resultArray addObject:conversation];
            getNum++;
        }
    }
    [currentConversations addObjectsFromArray:resultArray];
    if (resultArray.count<maxPageCount) {
        bHaveMore=NO;
    }
    bIsLoadingMore=NO;
    return indexArr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
            WTAlertView *alertviewwt=[[WTAlertView alloc]initWithText:@"切换至个人中心绑定另一半？" centerImage:nil];
            [alertviewwt setButtonTitles:@[@"取消",@"确定"]];
            [alertviewwt setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                [alertView close];
                if (buttonIndex==1) {
					[UserInfoManager instance].showBling = YES;
					[[UserInfoManager instance] saveOtherToUserDefaults];
					[self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
            [alertviewwt show];
        }
        else
        {
            [self showLoadingViewTitle:@"获取会话中..."];
            [[ChatMessageManager instance] makeOurConversation:^{
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
                [WTProgressHUD ShowTextHUD:@"获取会话失败" showInView:KEY_WINDOW];
            }];
        }
    }
    else
    {
        NSInteger index=indexPath.row-1;
        if (currentConversations.count<=index) {
            return;
        }
        
        AVIMKeyedConversation *KeyedConversation=(AVIMKeyedConversation*)currentConversations[index];
        NSString*KEY=KeyedConversation.conversationId;
        AVIMConversation *conversation=[[ChatMessageManager instance]getConversationWithId:KEY];
        if (conversation) {
            [WTChatDetailViewController pushToChatDetailWithConversation:conversation];
        }
        else
        {
            [WTChatDetailViewController pushToChatDetailWithKeyConversation:KeyedConversation];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return NO;
    }
    return YES;
}

-(void)cleanData//退出登录清空数据
{
    bHaveMore=YES;
    [currentConversations removeAllObjects];
    [dataTableView reloadData];
    ifLoadFirstData=NO;
}

#pragma mark ChatMessageManagerDelegate
-(void)getListStateChanged:(WTChatMessageGetListState)state
{
    switch (state) {
        case WTChatMessageGetListStateNone:
            break;
        case WTChatMessageGetListStateClosed:
            [self cleanData];
            break;
        case WTChatMessageGetListStateError:
        {
            [errBtn setBtnWithTitle:@"连接失败，点击重连" tapBlock:^{
                [[ChatMessageManager instance] openClient];
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
        }
            break;
        case WTChatMessageGetListStatePaused:
            [errBtn setBtnWithTitle:@"连接中断，稍后自动重连" tapBlock:^{
                [[ChatMessageManager instance] openClient];
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
            break;
        case WTChatMessageGetListStateReconnecting:
            [errBtn setBtnWithTitle:@"重连中..." tapBlock:^{
                
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
            break;
        case WTChatMessageGetListStateOpening:
            [errBtn setBtnWithTitle:@"连接中..." tapBlock:^{
                
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
            break;
        case WTChatMessageGetListStatePullConversations:
            [errBtn setBtnWithTitle:@"拉取中..." tapBlock:^{
                
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
            break;
        case WTChatMessageGetListStatePullConversationFailed:
        {
            [errBtn setBtnWithTitle:@"拉取失败，点击重新拉取" tapBlock:^{
                [[ChatMessageManager instance]updateConversations];
            }];
            [errBtn showInView:self.view center:CGPointMake(screenWidth/2, 75)];
            WTAlertView *alertviewwt=[[WTAlertView alloc]initWithText:@"是否重新拉取？" centerImage:nil];
            [alertviewwt setButtonTitles:@[@"取消",@"确定"]];
            [alertviewwt setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
                [alertView close];
                if (buttonIndex==1) {
                    [[ChatMessageManager instance]updateConversations];
                }
            }];
            [alertviewwt show];
        }
            break;
        case WTChatMessageGetListStateUpdateConversations:
            [errBtn setBtnWithTitle:@"获取会话中..." tapBlock:^{
                
            }];
            break;
        case WTChatMessageGetListStateUpdateUsers:
            [errBtn setBtnWithTitle:@"用户信息更新中..." tapBlock:^{
                
            }];
            break;
        case WTChatMessageGetListStateOpen:
            [errBtn hide];
            [[ChatMessageManager instance] updateConversations];
            break;
        case WTChatMessageGetListStateGetListDone:
            [errBtn hide];
            [self hideLoadingView];
            [self firstLoadData];
            break;
        default:
            break;
    }
}

-(void)listShouldUpdate:(AVIMKeyedConversation *)conversation
{
    for (AVIMKeyedConversation *kconversation in currentConversations) {
        if([kconversation.conversationId isEqualToString:conversation.conversationId])
        {
            [currentConversations removeObject:kconversation];
            break;
        }
    }
    [currentConversations insertObject:conversation atIndex:0];
    [dataTableView reloadData];
}

-(void)ourConversationMessageArrive
{
    [dataTableView reloadData];
}

//实现加载更多的逻辑，当noMore为NO，且渲染最后一个cell时被调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float contentSizeHeight = scrollView.contentSize.height;
    float heightD=contentSizeHeight-scrollView.height;
    heightD=heightD>0?heightD:0;
    if (scrollView.contentOffset.y>=heightD+30) {
        [self loadData];
        [dataTableView reloadData];
    }

	if (scrollView.contentOffset.y < 0)
	{
		UIImage *back=[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
		if (!back) {
			back = [UIImage imageNamed:@"defaultBG"];
		}
		
//		float state = (170 + scrollView.contentOffset.y) / 170;
//		if (state >= 0.169) {
//			UIImage *blImage = [back imageByBlurRadius:state * 40 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
//			[self setBlurImageViewWithImage:blImage state:state];
//		}
	}
}

@end

@implementation ListErrorBtn
{
    void(^tapBlock)();
}
-(instancetype)init
{
    self=[super init];
    if (self) {
        self.alpha=0;
        self.backgroundColor=rgba(255, 16, 16, 0.5);
        self.bounds=CGRectMake(0, 0, 257, 50);
        self.layer.cornerRadius=10;
        self.layer.masksToBounds=YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:16];
        [self addTarget:self action:@selector(tapListErrorBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setBtnWithTitle:(NSString*)title tapBlock:(void(^)())tap
{
    [self setTitle:title forState:UIControlStateNormal];
    tapBlock=tap;
}

-(void)tapListErrorBtn
{
    if (tapBlock) {
        tapBlock();
    }
}

-(void)showInView:(UIView*)view center:(CGPoint)point
{
    [self removeFromSuperview];
    [view addSubview:self];
    self.center=point;
    [UIView beginAnimations:@"alpha" context:(__bridge void *)(self)];
    [UIView setAnimationDuration:1];
    self.alpha=1;
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView commitAnimations];
}

-(void)hide
{
    [UIView beginAnimations:@"alpha" context:(__bridge void *)(self)];
    [UIView setAnimationDuration:1];
    self.alpha=0;
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView commitAnimations];
}
@end
