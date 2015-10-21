//
//  DetailsTableViewCell.m
//  nihao
//
//  Created by 罗中华 on 15/10/20.
//  Copyright © 2015年 boru. All rights reserved.
//

#import "DetailsTableViewCell.h"
@interface DetailsTableViewCell()


@end
@implementation DetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
        static NSString *identifier = @"cell";
        DetailsTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil==cell) {
            cell = [[DetailsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    return cell;
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self addimageView];
        [self addlogLabel];
    }
    return self;
}
- (void)addimageView{
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(15, 18, 15, 15)];
    self.iconImageView = imageView;
    [self addSubview:self.iconImageView];
    
}
- (void)addlogLabel{
    UILabel *logLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 5, self.frame.size.width, self.frame.size.height)];
    self.logLabel = logLabel;
    self.logLabel.textColor = RGB(120, 120, 120);
    self.logLabel.font =[UIFont systemFontOfSize:14];
    [self  addSubview:self.logLabel];
}



@end
