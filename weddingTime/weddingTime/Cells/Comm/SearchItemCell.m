//
//  SearchItemCell.m
//  lovewith
//
//  Created by imqiuhang on 15/4/30.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "SearchItemCell.h"
#import "LWAssistUtil.h"
#define topGap 10.f
#define btnHeigh 30.f
#define LineViewOfTextField   [LWUtil colorWithHexString:@"#DDDDDD"]
#define viewlayerBorderColor  [LWUtil colorWithHexString:@"#CCCCCC"]


@implementation UITableView(SearchItemCell)


- (SearchItemCell *)SearchItemCell {
    static NSString *CellIdentifier = @"SearchItemCell";
    SearchItemCell *cell = (SearchItemCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[SearchItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}
@end

@implementation SearchItemCell
{
    NSMutableArray *indexArr;
    UILabel *titleLable;
    NSMutableArray *btnArr;
    UIImageView *imageView;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    imageView.frame = CGRectMake(20, self.size.height - 0.3, screenWidth - 15, 0.3);
}

- (void)startWithStyle:(SearchItemCellStyle)aStyle {
    
    self.searchStyle=aStyle;
    
    [self.contentView removeAllSubviews];
    
    indexArr =[[NSMutableArray alloc] initWithCapacity:20];
    btnArr = [[NSMutableArray alloc] initWithCapacity:20];;
    
    titleLable           = [[UILabel alloc] initWithFrame:CGRectMake(0, 20* Height_ato, screenWidth, 20)];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.font      = DefaultFont16;
    titleLable.textColor = BLACK;
    [self.contentView addSubview:titleLable];
    
    float leftGap = 10.f;
    int numOfBtnInLine = 4;
    
    titleLable.text =self.searchStyle ==SearchItemCellStyleType? @"类型":@"特点";
    NSArray *data = self.searchStyle ==SearchItemCellStyleType? [LWUtil defaultSearchType]:[LWUtil defaultSearchItem];
    
    for(int i =0;i<data.count;i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (screenWidth-(numOfBtnInLine+1)*leftGap)/numOfBtnInLine, btnHeigh)];
        btn.layer.borderWidth=1.f;
        btn.layer.borderColor=viewlayerBorderColor.CGColor;
        btn.layer.cornerRadius=5;
        
        btn.left = (i%numOfBtnInLine+1)*leftGap+(i%numOfBtnInLine)*btn.width;
        btn.top  = 40+20+(int)(i/4)*(btnHeigh+topGap);
        btn.tag=i;
        btn.titleLabel.font=[UIFont systemFontOfSize:14];
        [btn setTitle:[LWUtil getString:self.searchStyle ==SearchItemCellStyleType?data[i][@"name"]:data[i] andDefaultStr:@"无"] forState:UIControlStateNormal];
        [btn setTitleColor:rgba(102, 102, 102, 1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(itemSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        
        [btnArr addObject:btn];
        
    }

    imageView = [[UIImageView alloc] init];
    [LWAssistUtil imageViewSetAsLineView:imageView color:[UIColor lightGrayColor]];
    [self.contentView addSubview:imageView];
   
}

- (void)itemSelect:(UIButton *)sender {
    
    for(NSNumber *tag in indexArr) {
        if ([tag intValue]==sender.tag) {
            sender.layer.borderColor = viewlayerBorderColor.CGColor;
            [sender setTitleColor:titleLableColor forState:UIControlStateNormal];
            [indexArr removeObject:tag];
            [self updateItems];
            return;
        }
    }
    
    if (self.searchStyle==SearchItemCellStyleType) {
        [self reset];
    }
    [indexArr addObject:@(sender.tag)];
    sender.layer.borderColor = [WeddingTimeAppInfoManager instance].baseColor.CGColor;
    [sender setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    [self updateItems];
    
}

- (void)updateItems {
    if (indexArr.count==0) {
        return;
    }
    NSMutableArray *curPostArr = [[NSMutableArray alloc] initWithCapacity:20];
    NSArray *data ;

    if (self.searchStyle==SearchItemCellStyleType) {
        data = [LWUtil defaultSearchType];
        [curPostArr addObject:data[[indexArr[0]intValue]][@"value"]?data[[indexArr[0]intValue]][@"value"]:@(-1)];
        if ([self.itemDelegate respondsToSelector:@selector(SearchItemCellDidChangedIndexs:andFromStyle:)]) {
            [self.itemDelegate SearchItemCellDidChangedIndexs:[curPostArr copy] andFromStyle:self.searchStyle];
        }
    }else {
        data = [LWUtil defaultSearchItem];
        for(NSNumber *key in indexArr) {
            [curPostArr addObject:data[[key intValue]]];
        }
        if ([self.itemDelegate respondsToSelector:@selector(SearchItemCellDidChangedIndexs:andFromStyle:)]) {
            [self.itemDelegate SearchItemCellDidChangedIndexs:@[[curPostArr componentsJoinedByString:@" "]] andFromStyle:self.searchStyle];
        }
    }
}

- (void)reset {
    [indexArr removeAllObjects];
    [self updateItems];
    for (UIButton *btn in btnArr) {
        btn.layer.borderColor = viewlayerBorderColor.CGColor;
        [btn setTitleColor:titleLableColor forState:UIControlStateNormal];
    }
}

+ (CGFloat)getHeightWithStyle:(SearchItemCellStyle)style {
    NSArray *data =style == SearchItemCellStyleType ? [LWUtil defaultSearchType]:[LWUtil defaultSearchItem];
    CGFloat heigh = (20 +((int)data.count/4 + 1)*btnHeigh + ((int)data.count/4)*topGap);
    return style == SearchItemCellStyleType? heigh + 20 : heigh + 20;
}

@end
