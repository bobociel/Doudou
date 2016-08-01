//
//  WTSupplier.m
//  weddingTime
//
//  Created by wangxiaobo on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTSupplier.h"

@implementation WTSupplier
- (instancetype)init
{
    self = [super init];
    if(self){
        self.ID = @"";
        self.supplier_user_id = @"";
        self.user_id = @"";
        self.supplierUserId = @"";
        
        self.has_auth = NO;
        self.is_like = NO;
        self.company = @"";
        self.avatar = @"";
        self.logo_path = @"";
        self.price = 0;
        self.score = @"";

		self.service_type = @"";
		self.supplier_name = @"";
		self.supplier_avatar = @"";
		self.supplier_banner = @"";
		self.supplier_description = @"";
		self.city = @"";
		self.phone = @"";
		self.supplier_post = [NSMutableArray array];
        
        self.like_num = 0;
        self.post_num = 0;
		self.comment_num = 0;
		self.supplier_post_num = 0;
        self.like_count = 0;
        self.works_count = 0;
    }
    return self;
}

- (double )likeCount
{
	return _likeCount ? : ( _like_count  ? : _like_num );
}

- (double )workCount
{
    return _works_count > 0 ? _works_count : _post_num;
}

- (NSString *)supplierUserId
{
    return _supplier_user_id.length > 0 ? _supplier_user_id : _user_id ;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
	return @{@"supplier_post":[WTSupplierPost class]};
}

+ (NSArray *)modelPropertyBlacklist
{
    return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end

@implementation WTSupplierPost

- (NSString *)post_description
{
	return [LWUtil returnAttributedStringWithHtml:[LWUtil getString:_post_description andDefaultStr:@""]].string;
}

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
	return @{@"post_image":[WTPostImage class],@"supplier_info":[WTSupplier class]};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTPostImage
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.pic = @"";
		self.desc = @"";
		self.size = @"";
		self.height = 0;
		self.width = 0;
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end
