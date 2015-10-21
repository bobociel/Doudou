//
//  NoResultView.m
//  nihao
//
//  Created by Apple on 15/10/15.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import "NoResultView.h"
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"
@implementation NoResultView
{
    UIView *_noResult;
}
-(instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.frame = frame;
        [self initNoReslutView];
        [self addSubview:_noResult];
    }
    
    return self;
}
-(void)initNoReslutView{
    [self setBackgroundColor:[UIColor whiteColor]];
    _noResult = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIImageView *noResultsImage=[[UIImageView alloc]initWithImage:ImageNamed(@"no_results")];
    [self addSubview:noResultsImage];
    [noResultsImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(50);
        make.centerX.equalTo(self.centerX);
        make.size.equalTo(CGSizeMake(123, 68));
    }];
    UILabel *noResultsLabel=[[UILabel alloc]init];
    noResultsLabel.text=@"No results found";
    noResultsLabel.font = FontNeveLightWithSize(14);
    noResultsLabel.textColor=RGB(158, 158, 158);
    [self addSubview:noResultsLabel];
    [noResultsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(noResultsImage.bottom).offset(24);
        make.centerX.equalTo(self.centerX);
    }];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
