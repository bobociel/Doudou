//
//  CurrencyCode.m
//  nihao
//
//  Created by HelloWorld on 7/22/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "CurrencyCode.h"

@implementation CurrencyCode

- (NSString *)description {
	return [NSString stringWithFormat:@"country_currency_code = %@, country_currency_symbol = %@, country_name_zh = %@", self.country_currency_code, self.country_currency_symbol, self.country_name_zh];
}

@end
