//
//  TopUser.m
//  nihao
//
//  Created by HelloWorld on 6/17/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "TopUser.h"

@implementation TopUser

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ca_ci_id = [aDecoder decodeIntForKey:@"ca_ci_id"];
        self.friend_type = [aDecoder decodeIntForKey:@"friend_type"];
        self.ci_nikename = [aDecoder decodeObjectForKey:@"ci_nikename"];
        self.ca_date = [aDecoder decodeObjectForKey:@"ca_date"];
        self.country_name_en = [aDecoder decodeObjectForKey:@"country_name_en"];
        self.ci_sex = [aDecoder decodeIntForKey:@"ci_sex"];
        self.ci_header_img = [aDecoder decodeObjectForKey:@"ci_header_img"];
        self.sum_cr_count = [aDecoder decodeIntForKey:@"sum_cr_count"];
        self.ca_score = [aDecoder decodeIntForKey:@"ca_score"];
    }
    
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.ca_ci_id forKey:@"ca_ci_id"];
    [aCoder encodeInt:self.friend_type forKey:@"friend_type"];
    [aCoder encodeObject:self.ci_nikename forKey:@"ci_nikename"];
    [aCoder encodeObject:self.ca_date forKey:@"ca_date"];
    [aCoder encodeInt:self.ci_sex forKey:@"ci_sex"];
    [aCoder encodeObject:self.country_name_en forKey:@"country_name_en"];
    [aCoder encodeObject:self.ci_header_img forKey:@"ci_header_img"];
    [aCoder encodeInt:self.sum_cr_count forKey:@"sum_cr_count"];
    [aCoder encodeInt:self.ca_score forKey:@"ca_score"];
}

- (NSString *)description {
    NSMutableString *userInfo = [[NSMutableString alloc] init];
    [userInfo appendFormat:@"user id = %d;", self.ca_ci_id];
    [userInfo appendFormat:@";user friend_type = %d;", self.friend_type];
    
    return userInfo;
}

@end
