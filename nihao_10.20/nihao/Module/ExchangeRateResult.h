//
//  ExchangeRateResult.h
//  nihao
//
//  Created by HelloWorld on 7/22/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExchangeRateResult : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *fromCurrency;
@property (nonatomic, assign) CGFloat amount;
@property (nonatomic, copy) NSString *toCurrency;
@property (nonatomic, assign) NSString *currency;
@property (nonatomic, assign) CGFloat convertedamount;

@end
