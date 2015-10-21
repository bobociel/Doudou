//
//  MerchantsScore.h
//  nihao
//
//  Created by HelloWorld on 8/24/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MerchantsScore : NSObject

//"mhs_cmi_id" = 1734;
//"mhs_consume" = 10;
//"mhs_score" = 0;

@property (nonatomic, assign) NSInteger mhs_cmi_id;
@property (nonatomic, assign) NSInteger mhs_consume;
//@property (nonatomic, assign) NSInteger mhs_delete;
//@property (nonatomic, assign) NSInteger mhs_id;
//@property (nonatomic, assign) NSInteger mhs_mhi_id;
@property (nonatomic, assign) NSInteger mhs_score;
//@property (nonatomic, copy) NSString *mhs_date;

@end
