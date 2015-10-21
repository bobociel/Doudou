//
//  ViewController.m
//  textView
//
//  Created by hangzhou on 15/9/30.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import "ViewController.h"
#import "TTTAttributedLabel.h"
@interface ViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *attributeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.textView.text = @"Alice 哈哈哈， 蜡笔小新....15037971291....12312312.";
    self.textView.delegate = self;
    self.textView.editable = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 300, 40)];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"123 89 998 😊🇨🇳🇩🇪🇫🇷你好嗷嗷啊 999900000"];
    NSMutableArray *rangeArray = [NSMutableArray array];
    for(NSInteger i=0; i < attributeString.length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *str = [attributeString.string substringWithRange:range];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]"];
        if([predicate evaluateWithObject:str])
        {
            [rangeArray addObject:[NSValue valueWithRange:range]];
        }
    }
    
    [rangeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [(NSValue *)obj rangeValue];
        [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0],NSForegroundColorAttributeName:[UIColor orangeColor]} range:range];
    }];
    
    
    label.attributedText = attributeString;
    
    [self.view addSubview:label];
    
    
    self.attributeLabel.text = @"123,123123123";
    //self.attributeLabel.enabledTextCheckingTypes = NSTextCheckingTypeRegularExpression ;
    
//    NSDictionary *attribute = @{
//                                NSTextEffectAttributeName:NSTextEffectLetterpressStyle,
//                                NSForegroundColorAttributeName:[UIColor redColor],
//                                NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
//                                };
//    
//    //动态字体
//    //self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    
//    //编辑
//    [self.textView.textStorage beginEditing];
//    [self.textView.textStorage endEditing];
//    
//    //排版
//    self.textView.textContainer.exclusionPaths = @[ [[UIBezierPath alloc] init] ];
//    
//    
//    NSMutableAttributedString *string = [self.textView.attributedText mutableCopy];
//    
//    NSURL * url = [NSURL URLWithString:@"--http://www.baidu.com"];
//    [string addAttribute:NSLinkAttributeName value:url range:NSMakeRange(0, 5)];
//    
//    NSURL * url2 = [NSURL URLWithString:@"http://www.baidu.com"];
////    [string addAttribute:NSLinkAttributeName value:url2 range:NSMakeRange(6, 3)];
////    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6, 3)];
////    [string addAttributes:@{NSLinkAttributeName:url2,NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(6, 3)];
//    [string setAttributes:@{
//                            NSLinkAttributeName:url2,
//                            NSForegroundColorAttributeName:[UIColor greenColor],
////                            NSBackgroundColorAttributeName:[UIColor blueColor],
//                            NSStrokeColorAttributeName:[UIColor whiteColor],
//                            NSUnderlineColorAttributeName:[UIColor blackColor],
//                            NSStrikethroughColorAttributeName:[UIColor blackColor]
//                            }
//                    range:NSMakeRange(6, 4)];
//    self.textView.attributedText = [string copy];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if(![URL.absoluteString hasPrefix:@"http://"])
    {
        NSLog(@"%@",URL.absoluteString);
        return NO;
    }
    
    return YES;
}

@end
