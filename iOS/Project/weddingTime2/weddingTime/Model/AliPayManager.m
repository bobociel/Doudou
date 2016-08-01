//
//  AliPayManager.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/13.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "AliPayManager.h"
#import "Order.h"
#import "PostDataService.h"
@implementation AliPayManager

+ (Order *)getOrder
{
    
    Order *order = [[Order alloc] init];
    order.partner = @"2088711324192903";
    order.seller = @"lemicaiwu@lovewith.me";
//    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
//    order.productName = product.subject; //商品标题
//    order.productDescription = product.body; //商品描述
//    order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
    order.notifyURL =  @"http://www.lovewith.me/api/pay/async_notify/"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"120m";
    order.showUrl = @"m.alipay.com";

    return order;
}

+ (NSString *)getUTF8String:(NSString *)str
{
    NSString *temp = [LWUtil getString:str andDefaultStr:@""];
    NSString *string;
    string = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return string;
}

+ (void)payOrderWithTrade_no:(NSString *)trade_no Blcok:(void (^)(NSDictionary *))block
{
    [PostDataService postAlipayParamsWithChild_trade_no:trade_no withBlock:^(NSDictionary *result, NSError *error) {
        Order *order = [[Order alloc] init];
//        order.tradeNO = [AliPayManager getUTF8String:result[@"out_trade_no"]];
//        order.amount = [AliPayManager getUTF8String:result[@"total_fee"]];
//        order.partner = [AliPayManager getUTF8String:result[@"partner"]];
//        order.seller = [AliPayManager getUTF8String:result[@"seller_id"]];
//        order.notifyURL = [AliPayManager getUTF8String:result[@"notify_url"]];
//        order.service = [AliPayManager getUTF8String:result[@"service"]];
//        order.paymentType = [AliPayManager getUTF8String:result[@"payment_type"]];
//        order.inputCharset = [AliPayManager getUTF8String:result[@"_input_charset"]];
//        order.productDescription = [AliPayManager getUTF8String:result[@"body"]];
//        order.productName = [AliPayManager getUTF8String:result[@"subject"]];
        order.tradeNO = [LWUtil getString:result[@"out_trade_no"] andDefaultStr:@""] ;
        order.amount = [LWUtil getString:result[@"total_fee"] andDefaultStr:@""] ;
        order.partner = [LWUtil getString:result[@"partner"] andDefaultStr:@""] ;
        order.seller = [LWUtil getString:result[@"seller_id"] andDefaultStr:@""];
        order.notifyURL = [LWUtil getString:result[@"notify_url"] andDefaultStr:@""] ;
        order.service = [LWUtil getString:result[@"service"] andDefaultStr:@""] ;
        order.paymentType = [LWUtil getString:result[@"payment_type"] andDefaultStr:@""];
        order.inputCharset = [LWUtil getString:result[@"_input_charset"] andDefaultStr:@""] ;
        order.productName = [LWUtil getString:result[@"subject"] andDefaultStr:@""] ;
        order.productDescription = [LWUtil getString:result[@"body"] andDefaultStr:@""];
//        order.showUrl = @"m.alipay.com";
//        order.itBPay = @"120m";
        
        
        NSString *orderSpec = [order description];
        NSString *appScheme = @"lovewithAlipay20151087652";//复杂点免得重复
        NSString *signedString;
        signedString = result[@"sign"];
//        signedString = [signedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = nil;
        
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, result[@"sign_type"]];
            
            
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:block];
        }

    }];
}

//+ (void)payOrderWithTrade_no:(NSString *)trade_no total_fee:(NSString *)total_fee Blcok:(void (^)(NSDictionary *))block
//{
//    
//    Order *order = [self getOrder];
//    order.tradeNO = trade_no;
//    order.amount = total_fee;
//    
//    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
//
//    NSString *appScheme = @"lovewithme";
////    id<DataSigner> signer = CreateRSADataSigner(privateKey);
////    NSString *signedString = [signer signString:orderSpec];
//    
//    NSString *signedString;
//    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = nil;
//    if (signedString != nil) {
//        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//                       orderSpec, signedString, @"RSA"];
//        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:block];
//    }
//}
@end
