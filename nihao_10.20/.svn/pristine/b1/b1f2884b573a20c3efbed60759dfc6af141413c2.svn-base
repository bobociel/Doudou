//
//  ChatHistoryCell.m
//  nihao
//
//  Created by 吴梦婷 on 15/10/13.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import "ChatHistoryCell.h"
#import "BaseFunction.h"

@interface ChatHistoryCell()

@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UIImageView *messageImg;

@end

@implementation ChatHistoryCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

-(void)loadData:(ChatHistoryModel *)chatHistory{
    
    _username = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 20, 14)];
    _username.font = FontNeveLightWithSize(14.0);
    _username.text = chatHistory.username;
    _username.textColor = ColorWithRGB(74, 183, 253);
    
    CGSize size = [chatHistory.username sizeWithFont:_username.font constrainedToSize:CGSizeMake(MAXFLOAT, _username.frame.size.height)];
    [_username setFrame:CGRectMake(15, 15, size.width, 14)];
    
    _time = [[UILabel alloc] initWithFrame:CGRectMake(size.width+30, 17, 150, 12)];
    _time.font = FontNeveLightWithSize(12.0);
    _time.text = chatHistory.time;
    _time.textColor = ColorWithRGB(158, 158, 158);
    
    if (chatHistory.messageType == 1) {
        NSLog(@"message = %@",chatHistory.message);
        _message = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH-30, 14)];
        _message.font = FontNeveLightWithSize(14.0);
        _message.text = chatHistory.message;
        _message.numberOfLines = 0;
        _message.textColor = ColorWithRGB(87, 87, 87);
        
        CGSize sizeL = [chatHistory.message sizeWithFont:_message.font  constrainedToSize:CGSizeMake(_message.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        [_message setFrame:CGRectMake(15, 40, SCREEN_WIDTH-30, sizeL.height)];
        
        [self addSubview:_message];
    }else if (chatHistory.messageType == 2){
        
        _messageImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, chatHistory.thumbnailSize.width, chatHistory.thumbnailSize.height)];
        [_messageImg setImage: [UIImage imageWithContentsOfFile:chatHistory.thumbnailFile]];
        if (_messageImg == nil) {
            [_messageImg setImage:[NSURL URLWithString:chatHistory.imageRemote]];
        }
        [self addSubview:_messageImg];
    }
    [self addSubview:_username];
    [self addSubview:_time];
    
}
@end
