//
//  SupplierBaseViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfoManager.h"
#import "ChatConversationManager.h"
#import "WTProgressHUD.h"
#import "WTChatDetailViewController.h"

@interface WTSupplierBaseViewController : BaseViewController

- (void)conversationSelectType:(WTConversationType)type
				   supplier_id:(NSString *)supplier_id
					  sendToAskData:(NSDictionary *)sendToAskData
						  name:(NSString *)serverName
						 phone:(NSString *)phone
						avatar:(NSString *)avatar;
@end
