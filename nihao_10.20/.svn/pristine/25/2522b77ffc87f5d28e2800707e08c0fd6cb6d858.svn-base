//
//  ChargeFailViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ChargeFailViewController.h"
#import <DTCoreText.h>
#import <DTAttributedTextView.h>
#import <MessageUI/MessageUI.h>

@interface ChargeFailViewController ()<DTAttributedTextContentViewDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation ChargeFailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mobile Recharge";
    [self initViews];
    [self addCompleteButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *content = @"<p style=\"font-size:16px\"><font face=\"HelveticaNeue-Light\">Your transaction was unsuccessful. The mobile credit you have tried to make cannot be completed at this time.<br><br>We apologize for the inconvenience. If you bank account has been charged or need other help, please contact us by email<a href=\"support@appnihao.com\">support@appnihao.com.</a> <br><br>If contact by email, please include your issue, phone number that you tried to recharge, date and time of the transaction and your phone number that you use to signup to NiHao and your NiHao account name. Thank you!</font></p>";
    NSData* descriptionData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString* attributedDescription = [[NSAttributedString alloc] initWithHTMLData:descriptionData documentAttributes:NULL];
    DTAttributedTextView *label = [[DTAttributedTextView alloc] init];
    label.textDelegate = self;
    label.attributedString = attributedDescription;
    label.frame = CGRectMake(12,12,SCREEN_WIDTH - 12 * 2,SCREEN_HEIGHT - 64 - 12);
    [self.view addSubview:label];
}

- (void) addCompleteButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FontNeveLightWithSize(16.0);
    [button sizeToFit];
    [button addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chargeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = chargeButtonItem;
}

- (void) complete {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
   
}

- (void) linkPushed:(DTLinkButton *)button {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"NiHao Mobile Recharge Fail"];
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"support@appnihao.com"];
    [picker setToRecipients:toRecipients];
    [picker setMessageBody:@"" isHTML:NO];
    // Fill out the email body text
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
