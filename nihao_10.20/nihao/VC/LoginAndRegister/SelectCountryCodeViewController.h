//
//  SelectCountryCodeViewController.h
//  nihao
//
//  Created by HelloWorld on 7/8/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectCountryCodeViewController : BaseViewController

@property (nonatomic,copy) void(^countryCodeSelected)(NSString *countryName, NSString *code);

@end
