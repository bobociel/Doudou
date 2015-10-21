//
//  NihaoContact.m
//  nihao
//
//  Created by 刘志 on 15/6/29.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "NihaoContact.h"

@implementation NihaoContact

- (BOOL) isEqual:(id)object {
    if([object isKindOfClass:[NihaoContact class]]) {
        NihaoContact *contact = (NihaoContact *) object;
        if(self.ci_id == contact.ci_id && self.ci_sex == contact.ci_sex && [self.ci_nikename isEqualToString:contact.ci_nikename] && [self.ci_username isEqualToString:contact.ci_username] && [self.ci_header_img isEqualToString:contact.ci_header_img] &&
           [self.city_name_en isEqualToString:contact.city_name_en] && [self.country_name_en isEqualToString:contact.country_name_en]) {
            return YES;
        } else
            return NO;
    } else {
        return NO;
    }
}

- (NSUInteger) hash {
    return self.ci_id + self.ci_sex + self.ci_nikename.hash + self.ci_username.hash + self.ci_header_img.hash + self.country_name_en.hash + self.city_name_en.hash;
}

@end
