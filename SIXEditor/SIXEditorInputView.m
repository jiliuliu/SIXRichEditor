//
//  SIXEditorInputView.m
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorInputView.h"


NS_INLINE UIColor *six_colorWithHex(NSInteger hex) {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}
 

@interface SIXEditorInputViewCell: UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *colorView;
@end

@implementation SIXEditorInputViewCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor blackColor];
        [self.contentView addSubview:_label];
    }
    return _label;
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] initWithFrame:self.bounds];
        _colorView.layer.masksToBounds = YES;
        [self.contentView addSubview:_colorView];
    }
    return _colorView;
}

@end


@interface SIXEditorInputView ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>
{
    NSInteger itemCount;
    CGSize itemSize;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *textColors;
@property (nonatomic, strong) NSArray *fontSizes;

@end

@implementation SIXEditorInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CALayer *line = [CALayer layer];
        line.backgroundColor = [UIColor lightGrayColor].CGColor;
        line.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
        
        [self addSubview:self.collectionView];
        [self.layer addSublayer:line];
    }
    return self;
}

- (void)setEditorAction:(SIXEditorAction)editorAction {
    _editorAction = editorAction;
    
    CGFloat width = self.bounds.size.width;
    switch (editorAction) {
        case SIXEditorActionFontSize:
            itemCount = self.fontSizes.count;
            itemSize = CGSizeMake(width-30, 35);
            [self.collectionView reloadData];
            break;
        case SIXEditorActionTextColor:
            itemCount = self.textColors.count;
            itemSize = CGSizeMake((width - 30) / 6 - 11, (width - 30) / 6 - 11);
            [self.collectionView reloadData];
            break;
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

- (void)reloadData {
    [self.collectionView reloadData];
}


#pragma - mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return itemCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return itemSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ID = self.editorAction == SIXEditorActionFontSize ? @"fontSize" : @"textColor";
    SIXEditorInputViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    switch (self.editorAction) {
        case SIXEditorActionFontSize:
        {
            CGFloat size = [self.fontSizes[indexPath.item] floatValue];
            cell.label.font = [UIFont systemFontOfSize:size];
            cell.label.text = [NSString stringWithFormat:@"%@px ABC", self.fontSizes[indexPath.item]];
            if (size == self.selectedFontSize) {
                cell.label.textColor = [UIColor blueColor];
            } else {
                cell.label.textColor = [UIColor blackColor];
            }
        }
            break;
        case SIXEditorActionTextColor:
        {
            NSInteger hex = [self.textColors[indexPath.item] integerValue];
            cell.colorView.backgroundColor = six_colorWithHex(hex);
            
            if (CGColorEqualToColor(cell.colorView.backgroundColor.CGColor, self.selectedTextColor.CGColor)) {
                cell.colorView.layer.cornerRadius = itemSize.width * 0.5;
            } else {
                cell.colorView.layer.cornerRadius = 0;
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.editorAction) {
        case SIXEditorActionFontSize:
            self.selectedFontSize = [self.fontSizes[indexPath.item] floatValue];
            [self.delegate inputView:self clickItemForFontSize:self.selectedFontSize];
            break;
        case SIXEditorActionTextColor: {
            NSInteger hex = [self.textColors[indexPath.item] integerValue];
            self.selectedTextColor = six_colorWithHex(hex);
            [self.delegate inputView:self clickItemForTextColor:self.selectedTextColor];
        }
            break;
        default:
            break;
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(20, 15, 20, 15);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:SIXEditorInputViewCell.class forCellWithReuseIdentifier:@"fontSize"];
        [_collectionView registerClass:SIXEditorInputViewCell.class forCellWithReuseIdentifier:@"textColor"];
    }
    return _collectionView;
}

- (NSArray *)textColors {
    if (!_textColors) {
        _textColors = @[@0xEF6931, @0x0079FE, @0x6DE0FF, @0xFFD200,
                        @0x4CD900, @0xFF2D3C, @0x995200, @0x8659F7,
                        @0x009E4A, @0x009FB8, @0x0064CF, @0xE6B800,
                        @0xFF9500, @0xD42111, @0x000000, @0x666666,
                        @0x999999, @0xC0C0C0];
    }
    return _textColors;
}

- (NSArray *)fontSizes {
    if (!_fontSizes) {
        _fontSizes = @[@12, @14, @16, @18, @20, @24, @28];
    }
    return _fontSizes;
}

@end
