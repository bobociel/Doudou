//
//  SquareButton.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "KYCuteView.h"
@interface SquareButton : UIButton
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIButton    *iconButton;
@property (nonatomic, strong) KYCuteView  *badgeView;
@property (nonatomic, strong) UIImageView *headLine;
@property (nonatomic, strong) UIImageView *leftLine;
@property (nonatomic, strong) UIImageView *rightLine;
@end
