//
//  webViewCellTableViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/16.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "webViewCellTableViewCell.h"
#define youku @"http://player.youku.com/embed/"

@interface webViewCellTableViewCell ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webVideo;
@end

@implementation UITableView (webViewCell)

- (webViewCellTableViewCell *)webViewCell
{
    static NSString *CellIdentifier = @"webViewCellTableViewCell";
    webViewCellTableViewCell * cell = (webViewCellTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[webViewCellTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end

@implementation webViewCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
//    if (self.webVideo) {
//        return;
//    }
    self.webVideo = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-10)];
    self.webVideo.delegate = self;
    _webVideo.scalesPageToFit = NO;
    _webVideo.scrollView.pagingEnabled = NO;
    _webVideo.scrollView.backgroundColor = [UIColor colorWithRed:230 green:230 blue:230 alpha:0.8];
    _webVideo.scrollView.scrollEnabled=NO;
    _webVideo.scrollView.scrollsToTop=NO;
    [self.contentView addSubview:_webVideo];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _webVideo.frame = CGRectMake(0, 0, screenWidth, self.height - 10);
}

- (void)setInfo:(id)info
{
    NSString *url;
    if ([info isNotEmptyCtg]) {
        url = [NSString stringWithFormat:@"%@%@",youku,info];
    } else {
        //url = @"http://player.youku.com/embed/XOTM5OTcxNTgw";
    }
    if (info) {
        [self.webVideo loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
