//
// Copyright (c) 2010-2011 René Sprotte, Provideal GmbH
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "MMGridView.h"


@interface MMGridView()
@end

@implementation MMGridView

- (instancetype) init {
    self = [super init];
    if(self) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    _cellMargin = 3;
    _numberOfRows = 3;
    _numberOfColumns = 2;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}


- (void)drawRect:(CGRect)rect {
    if (self.dataSource && self.numberOfRows > 0 && self.numberOfColumns > 0) {
        NSInteger noOfCols = self.numberOfColumns;
        
        for (UIView *v in self.subviews) {
            [v removeFromSuperview];
        }
        
        for (NSInteger i = 0; i < [self.dataSource numberOfCellsInGridView:self]; i++) {
            UIView *cell = [self.dataSource gridView:self cellAtIndex:i];
            cell.tag = i;
            NSInteger row  = (int)floor((float)i / (float)noOfCols);
            CGPoint origin = CGPointMake(((i % noOfCols) * cell.bounds.size.width),(row * cell.bounds.size.height));
            CGRect f = CGRectMake(origin.x, origin.y, cell.bounds.size.width, cell.bounds.size.height);
            cell.frame = CGRectInset(f, _cellMargin, _cellMargin);
            [self addSubview:cell];
            
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
            recognizer.numberOfTapsRequired = 1;
            cell.userInteractionEnabled = YES;
            [cell addGestureRecognizer:recognizer];
        }
    }
}

- (void) cellTapped : (UITapGestureRecognizer *) recognizer {
    if(_delegate) {
        [_delegate gridView:self didSelectCell:recognizer.view atIndex:recognizer.view.tag];
    }
}

- (void)setDataSource:(id<MMGridViewDataSource>)aDataSource {
    _dataSource = aDataSource;
    [self reloadData];
}

- (void)setNumberOfColumns:(NSUInteger)value {
    _numberOfColumns = value;
    [self reloadData];
}

- (void)setNumberOfRows:(NSUInteger)value {
    _numberOfRows = value;
    [self reloadData];
}

- (void)setCellMargin:(NSUInteger)value
{
    _cellMargin = value;
    [self reloadData];
}

- (void)reloadData {
    [self setNeedsDisplay];
}

@end
