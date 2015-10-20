//
//  CheckBox.h
//  ljhoo
//
//  Created by HelloWorld on 4/21/15.
//  Copyright (c) 2015 乐江湖. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckBox;

@protocol CheckBoxDelegate <NSObject>

@optional
- (void)checkBox:(CheckBox *)checkBox didChangedSelectedStatus:(BOOL)status;
//- (void)selectedLimited;

@end

@interface CheckBox : UIButton

// Outlet collection of links to other buttons in the group.
//@property (nonatomic, strong) IBOutletCollection(CheckBox) NSArray* groupButtons;

// Currently selected radio button in the group.
// If there are multiple buttons selected then it returns the first one.
//@property (nonatomic, readonly) CheckBox* selectedButton;

// If selected==YES, then it selects the button and deselects other buttons in the group.
// If selected==NO, then it deselects the button and if there are only two buttons in the group, then it selects second.
-(void) setSelected:(BOOL)selected;

- (void) setSelectedWithoutDelegate:(BOOL)selected;

// Find first radio with given tag and makes it selected.
// All of other buttons in the group become deselected.
-(void) setSelectedWithTag:(NSInteger)tag;

-(void) deselectAllButtons;

@property id<CheckBoxDelegate> delegate;

//@property (nonatomic, copy) void (^didDeselectedStatus)(BOOL status);

@end
