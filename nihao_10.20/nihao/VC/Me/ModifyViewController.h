//
//  ModifyViewController.h
//  nihao
//
//  Created by HelloWorld on 7/31/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, ModifyType) {
	ModifyTypeNickname = 0,
	ModifyTypeAge,
	ModifyTypeGender,
	ModifyTypeOccupation,
	ModifyTypeHobbies,
	ModifyTypeBirthday
};

@protocol ModifyViewControllerDelegate <NSObject>

- (void)modifyFinishedWithType:(ModifyType)modifyType modifiedValue:(NSString *)value;

@end

@interface ModifyViewController : BaseViewController

@property (nonatomic, assign) ModifyType modifyType;

@property (nonatomic, assign) id <ModifyViewControllerDelegate> delegate;

// 默认选择的生日
@property (nonatomic, copy) NSString *selectedBirthday;

@end
