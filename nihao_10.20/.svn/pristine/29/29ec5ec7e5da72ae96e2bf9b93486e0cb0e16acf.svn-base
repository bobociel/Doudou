//
//  SelectCurrencyCodeViewController.h
//  nihao
//
//  Created by HelloWorld on 7/21/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, SelectCurrencyCodeType) {
	SelectCurrencyCodeTypeLeft = 0,
	SelectCurrencyCodeTypeRight,
};

@interface SelectCurrencyCodeViewController : BaseViewController

/**
 *  选择币种的类型，这里分为左边和右边
 */
@property (nonatomic, assign) SelectCurrencyCodeType selectCurrencyCodeType;

/**
 *  选择完成之后的 Block
 */
@property (nonatomic, copy) void(^selectedCurrencyCode)(SelectCurrencyCodeType type, NSString *currencyCode);

@end
