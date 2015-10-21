//
//  MyCustomSwitch.h
//  nihao
//
//  Created by 吴梦婷 on 15/9/23.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomSwitch : UIControl

@property (nonatomic, assign) BOOL on;


/*
 *	Sets the background color when the switch is off.
 *  Defaults to clear color.
 */
@property (nonatomic, strong) UIColor *inactiveColor;

/*
 *	Sets the background color that shows when the switch off and actively being touched.
 *  Defaults to light gray.
 */
@property (nonatomic, strong) UIColor *activeColor;

/*
 *	Sets the background color that shows when the switch is on.
 *  Defaults to green.
 */
@property (nonatomic, strong) UIColor *onColor;

/*
 *	Sets the border color that shows when the switch is off. Defaults to light gray.
 */
@property (nonatomic, strong) UIColor *borderColor;

/*
 *	Sets the knob color. Defaults to white.
 */
@property (nonatomic, strong) UIColor *knobColor;

/*
 *	Sets the shadow color of the knob. Defaults to gray.
 */
@property (nonatomic, strong) UIColor *shadowColor;


/*
 *	Sets whether or not the switch edges are rounded.
 *  Set to NO to get a stylish square switch.
 *  Defaults to YES.
 */
@property (nonatomic, assign) BOOL isRounded;


/*
 *	Sets the image that shows when the switch is on.
 *  The image is centered in the area not covered by the knob.
 *  Make sure to size your images appropriately.
 */
@property (nonatomic, strong) UIImage *onImage;

/*
 *	Sets the image that shows when the switch is off.
 *  The image is centered in the area not covered by the knob.
 *  Make sure to size your images appropriately.
 */
@property (nonatomic, strong) UIImage *offImage;


/*
 * Set whether the switch is on or off. Optionally animate the change
 */
- (void)setOn:(BOOL)on animated:(BOOL)animated;

/*
 *	Detects whether the switch is on or off
 *
 *	@return	BOOL YES if switch is on. NO if switch is off
 */
- (BOOL)isOn;

@end
