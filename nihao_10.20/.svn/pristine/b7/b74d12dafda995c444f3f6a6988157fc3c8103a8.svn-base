//
//  ChatHistoryController.m
//  nihao
//
//  Created by 吴梦婷 on 15/10/12.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import "ChatHistoryController.h"
#import "ChatHistoryCell.h"
#import "ListingLoadingStatusView.h"
#import "ChatHistoryModel.h"

@interface ChatHistoryController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>
{
    UITableView *myTable;
//    NSMutableArray *messageList;
//    NSMutableArray *pageList;
    NSInteger pageControl;
    
    UIImageView *searchIcon;
    
    ListingLoadingStatusView *_statusView;
    
    UISearchDisplayController *_searchDisplayController;
    
    UIView *footBtnview;
    
    UIButton *btnPrepage;
    UIButton *btnNexpage;
    UIButton *btnHedpage;
    UIButton *btnlaspage;
    UIButton *btnClear;
    
}

@property (strong, nonatomic) EMConversation *conversation;
@property (copy, nonatomic) NSMutableArray *messageList;
@property (copy, nonatomic) NSMutableArray *pageList;

@end

@implementation ChatHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Chat history";
    _messageList = [[NSMutableArray alloc] init];
    _pageList = [[NSMutableArray alloc] init];
    pageControl = 0;
    self.view.backgroundColor =ColorWithRGB(200, 200, 200);
    // 根据接收者的username获取当前会话的管理者
    _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_username
                                                                conversationType:eConversationTypeChat];
    
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, SCREEN_HEIGHT - 159)];
    [_statusView setEmptyImage:nil emptyContent:@"No message" imageSize:NO_CONTACT];
    
    [self.view addSubview:_statusView];
    [self initSearchView];
    [self initTableview];
    [self initFootButton];
    [self loadMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initSearchView {
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(14, 6, SCREEN_WIDTH-28, 33)];
    searchField.delegate = self;
    searchField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchField];
    UIImage *img = ImageNamed(@"icon_search");
    searchIcon = [[UIImageView alloc] initWithImage:img];
    [searchIcon setFrame:CGRectMake(20, (33-img.size.height)/2, img.size.width, img.size.height)];
    [searchField addSubview:searchIcon];
}

-(void) initTableview{
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, SCREEN_HEIGHT-159)];
    myTable.delegate = self;
    myTable.dataSource = self;
    myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//    myTable.scrollEnabled = NO;
    [myTable registerNib:[UINib nibWithNibName:@"ChatHistoryCell" bundle:nil] forCellReuseIdentifier:@"ChatHistoryCell"];
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:myTable];
    
}
-(void) initFootButton{
    
    footBtnview = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-114, SCREEN_WIDTH, 59)];
    footBtnview.backgroundColor = [UIColor whiteColor];
    UIImage *lineImg = ImageNamed(@"foot_bar_line");
    UIImageView *line = [[UIImageView alloc]initWithImage:lineImg];
    [line setFrame:CGRectMake(0, 0, SCREEN_WIDTH,lineImg.size.height)];
    
    float buttonW = SCREEN_WIDTH/5;
    btnPrepage = [[UIButton alloc] initWithFrame:CGRectMake(buttonW, 13, buttonW, 24)];
    [btnPrepage setImage:ImageNamed(@"icon_page_previous_normal") forState:UIControlStateNormal];
    [btnPrepage setImage:ImageNamed(@"icon_page_previous_disable") forState:UIControlStateDisabled];
    [btnPrepage addTarget:self action:@selector(btnPrepageClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnNexpage = [[UIButton alloc] initWithFrame:CGRectMake(buttonW*2, 13, buttonW, 24)];
    [btnNexpage setImage:ImageNamed(@"icon_page_next_normal") forState:UIControlStateNormal];
    [btnNexpage setImage:ImageNamed(@"icon_page_next_disable") forState:UIControlStateDisabled];
    [btnNexpage addTarget:self action:@selector(btnNexpageClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btnHedpage = [[UIButton alloc] initWithFrame:CGRectMake(0, 13, buttonW, 24)];
    [btnHedpage setImage:ImageNamed(@"icon_page_head_normal") forState:UIControlStateNormal];
    [btnHedpage setImage:ImageNamed(@"icon_page_head_disable") forState:UIControlStateDisabled];
    [btnHedpage addTarget:self action:@selector(btnHedpageClicked) forControlEvents:UIControlEventTouchUpInside];

    btnlaspage = [[UIButton alloc] initWithFrame:CGRectMake(buttonW*3, 13, buttonW, 24)];
    [btnlaspage setImage:ImageNamed(@"icon_page_last_normal") forState:UIControlStateNormal];
    [btnlaspage setImage:ImageNamed(@"icon_page_last_disable") forState:UIControlStateDisabled];
    [btnlaspage addTarget:self action:@selector(btnLaspageClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnClear = [[UIButton alloc] initWithFrame:CGRectMake(buttonW*4, 13, buttonW, 24)];
    [btnClear setImage:ImageNamed(@"icon_clear_normal") forState:UIControlStateNormal];
    [btnClear setImage:ImageNamed(@"icon_clear_disable") forState:UIControlStateDisabled];
    [btnClear addTarget:self action:@selector(btnClearClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [footBtnview addSubview:line];
    [footBtnview addSubview:btnPrepage];
    [footBtnview addSubview:btnNexpage];
    [footBtnview addSubview:btnHedpage];
    [footBtnview addSubview:btnlaspage];
    [footBtnview addSubview:btnClear];
    
    [self.view addSubview:footBtnview];
}
#pragma mark  - TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_messageList.count == 0) {
        [_statusView showWithStatus:Empty];
        [btnPrepage setEnabled:NO];
        [btnNexpage setEnabled:NO];
        [btnHedpage setEnabled:NO];
        [btnlaspage setEnabled:NO];
        [btnClear setEnabled:NO];
    }
    return _messageList.count;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatHistoryModel *chatModel = _messageList[indexPath.row];
    if (chatModel.messageType == 1) {
        
        CGSize sizeL = [chatModel.message sizeWithFont:FontNeveLightWithSize(14.0)  constrainedToSize:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
        return sizeL.height + 46;
        
    }else if(chatModel.messageType == 2){
        
        return chatModel.thumbnailSize.height + 46;
        
    }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ChatHistoryCell";
    ChatHistoryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[ChatHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }else{
        [cell removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellEditingStyleNone;
//    [_statusView showWithStatus:Done];
    ChatHistoryModel *cellModel = _messageList[indexPath.row];
    [cell loadData:cellModel];
    return cell;
}
#pragma mark - TextFielDelagate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    searchIcon.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text isEqualToString:@""]) {
        _messageList = _pageList[0];
        [myTable reloadData];
    }else{
        NSArray *searchArr = [[EaseMob sharedInstance].chatManager searchMessagesWithCriteria:textField.text withChatter:_username];
        [self anlyseSearch:searchArr];
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField endEditing:YES];
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        
        BOOL ifsuccess = [self.conversation removeAllMessages];
        if (ifsuccess) {
            _messageList = nil;
            _pageList = nil;
            [myTable reloadData];
        }
        
    }
    
}
#pragma mark - ClickEvent
-(void)btnNexpageClicked:(UIButton *)btn{
//    [_messageList removeAllObjects];
    
    pageControl ++;
    _messageList = _pageList[pageControl];
    
    [myTable reloadData];
    if (pageControl == _pageList.count-1) {
        [btnNexpage setEnabled:NO];
        [btnlaspage setEnabled:NO];
    }
    [btnHedpage setEnabled:YES];
    [btnPrepage setEnabled:YES];
}
-(void)btnPrepageClicked{
//    [_messageList removeAllObjects];
    
    pageControl --;
    _messageList = _pageList[pageControl];
    
    [myTable reloadData];
    if (pageControl == 0) {
        [btnPrepage setEnabled:NO];
        [btnHedpage setEnabled:NO];
    }
    [btnlaspage setEnabled:YES];
    [btnNexpage setEnabled:YES];
}
-(void)btnHedpageClicked{
//    [_messageList removeAllObjects];
    
    pageControl = 0;
    _messageList = _pageList[0];
    
    [myTable reloadData];
    [btnHedpage setEnabled:NO];
    [btnPrepage setEnabled:NO];
    
    [btnlaspage setEnabled:YES];
    [btnNexpage setEnabled:YES];
}

-(void)btnLaspageClicked{
//    [_messageList removeAllObjects];
    
    pageControl = _pageList.count - 1;
    _messageList = [_pageList lastObject];
    
    [myTable reloadData];
    [btnNexpage setEnabled:NO];
    [btnlaspage setEnabled:NO];
    
    [btnHedpage setEnabled:YES];
    [btnPrepage setEnabled:YES];
}

-(void)btnClearClicked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Clear all messages?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - HttpRequest
-(void)loadMessage{
    NSArray *messages = [self.conversation loadAllMessages];
    [self analyzeData:messages];
}
-(void)anlyseSearch:(NSArray *)messages{
    _messageList = [[NSMutableArray alloc] init];
    for (EMMessage *mes in messages) {
        NSLog(@"mes == %@",mes);
        ChatHistoryModel *chatModel = [[ChatHistoryModel alloc] init];
        
        chatModel.massageID = mes.messageId;
        
        NSDictionary *ext = mes.ext;
        NSDictionary *em_apns_ext = ext[@"em_apns_ext"];
        chatModel.username = em_apns_ext[@"nickname"];
        
        NSDate *mesD = [NSDate dateWithTimeIntervalSince1970:mes.timestamp/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
        chatModel.time = [dateFormatter stringFromDate:mesD];
        
        id<IEMMessageBody> mesbody = [mes.messageBodies firstObject];
        
        chatModel.messageType = mesbody.messageBodyType;
        
        if (chatModel.messageType == 1) {
            EMTextMessageBody *textbody = (EMTextMessageBody *)mesbody;
            chatModel.message = textbody.text;
        }else if(chatModel.messageType == 2){
            EMImageMessageBody *imagebody = (EMImageMessageBody *)mesbody;
            //本地图片路径
            chatModel.thumbnailFile = imagebody.thumbnailLocalPath;
            chatModel.imageFile = imagebody.localPath;
            
            //网络图片路径
            chatModel.imageRemote = imagebody.remotePath;
            chatModel.trumbnailRemote = imagebody.thumbnailRemotePath;
            
            //图片大小
            chatModel.imageSize = imagebody.size;
            chatModel.thumbnailSize = imagebody.thumbnailSize;
            
        }
        [_messageList addObject:mes];
    }
    [myTable reloadData];
}
-(void)analyzeData:(NSArray *)messages{
//    [_messageList removeAllObjects];
    _messageList = [[NSMutableArray alloc] init];
    int i = 1;
    for (EMMessage *mes in messages) {
        NSLog(@"mes == %@",mes);
        ChatHistoryModel *chatModel = [[ChatHistoryModel alloc] init];
        
        chatModel.massageID = mes.messageId;
        
        NSDictionary *ext = mes.ext;
        NSDictionary *em_apns_ext = ext[@"em_apns_ext"];
        chatModel.username = em_apns_ext[@"nickname"];
        
        NSDate *mesD = [NSDate dateWithTimeIntervalSince1970:mes.timestamp/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
        chatModel.time = [dateFormatter stringFromDate:mesD];
        
        id<IEMMessageBody> mesbody = [mes.messageBodies firstObject];
        
        chatModel.messageType = mesbody.messageBodyType;
        
        if (chatModel.messageType == 1) {
            EMTextMessageBody *textbody = (EMTextMessageBody *)mesbody;
            chatModel.message = textbody.text;
        }else if(chatModel.messageType == 2){
            EMImageMessageBody *imagebody = (EMImageMessageBody *)mesbody;
            //本地图片路径
            chatModel.thumbnailFile = imagebody.thumbnailLocalPath;
            chatModel.imageFile = imagebody.localPath;
            
            //网络图片路径
            chatModel.imageRemote = imagebody.remotePath;
            chatModel.trumbnailRemote = imagebody.thumbnailRemotePath;
            
            //图片大小
            chatModel.imageSize = imagebody.size;
            chatModel.thumbnailSize = imagebody.thumbnailSize;
            
        }
        if (i < 20) {
            [_messageList addObject:chatModel];
              i++;
        }else if (i == 20){
            [_messageList addObject:chatModel];
            [_pageList addObject:_messageList];
            _messageList = [[NSMutableArray alloc] init];
            i = 0;
        }
    }
    if (i < 20 && i != 0) {
        [_pageList addObject:_messageList];
    }
    _messageList = _pageList[0];
    [myTable reloadData];
    if (_pageList.count == 1) {
        [btnlaspage setEnabled:NO];
        [btnNexpage setEnabled:NO];
    }
    [btnHedpage setEnabled:NO];
    [btnPrepage setEnabled:NO];
    NSLog(@"messges.count==%ld",messages.count);
}
@end
