//
//  FollowUser.m
//  nihao
//
//  Created by HelloWorld on 6/12/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "FollowUser.h"

@implementation FollowUser

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ci_city_id = [aDecoder decodeIntForKey:@"ci_city_id"];
        self.ci_country_id = [aDecoder decodeIntForKey:@"ci_country_id"];
        self.ci_date = [aDecoder decodeObjectForKey:@"ci_date"];
        self.ci_delete = [aDecoder decodeIntForKey:@"ci_delete"];
        self.ci_id = [aDecoder decodeIntForKey:@"ci_id"];
        self.ci_is_complete = [aDecoder decodeIntForKey:@"ci_is_complete"];
        self.ci_phone = [aDecoder decodeObjectForKey:@"ci_phone"];
        self.ci_sex = [aDecoder decodeIntForKey:@"ci_sex"];
        self.country_name_en = [aDecoder decodeObjectForKey:@"country_name_en"];
        self.friend_type = [aDecoder decodeIntForKey:@"friend_type"];
        self.ci_nikename = [aDecoder decodeObjectForKey:@"ci_nikename"];
        self.ci_header_img = [aDecoder decodeObjectForKey:@"ci_header_img"];
    }
    
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.ci_city_id forKey:@"ci_city_id"];
    [aCoder encodeInt:self.ci_country_id forKey:@"ci_country_id"];
    [aCoder encodeObject:self.ci_date forKey:@"ci_date"];
    [aCoder encodeInt:self.ci_delete forKey:@"ci_delete"];
    [aCoder encodeInt:self.ci_id forKey:@"ci_id"];
    [aCoder encodeInt:self.ci_is_complete forKey:@"ci_is_complete"];
    [aCoder encodeObject:self.ci_phone forKey:@"ci_phone"];
    [aCoder encodeInt:self.ci_sex forKey:@"ci_sex"];
    [aCoder encodeObject:self.country_name_en forKey:@"country_name_en"];
    [aCoder encodeInt:self.friend_type forKey:@"friend_type"];
    [aCoder encodeObject:self.ci_nikename forKey:@"ci_nikename"];
    [aCoder encodeObject:self.ci_header_img forKey:@"ci_header_img"];
}

@end
