//
//  SIXEditorTextColorPicker.m
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "SIXEditorTextColorPicker.h"
#import "SIXEditorHeader.h"

@interface SIXEditorTextColorCell: UICollectionViewCell
@property (nonatomic, strong) UIView *colorView;
@end

@implementation SIXEditorTextColorCell

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] initWithFrame:self.bounds];
        _colorView.layer.masksToBounds = YES;
        [self.contentView addSubview:_colorView];
    }
    return _colorView;
}

@end


@interface SIXEditorTextColorPicker()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>
{
    NSInteger itemCount;
    CGSize itemSize;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) NSArray *textColors;

@property (nonatomic, copy) void (^selectTextColorBlock) (UIColor *);

@end

@implementation SIXEditorTextColorPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = frame.size.width;
        itemCount = self.textColors.count;
        itemSize = CGSizeMake((width - 30) / 6 - 11, (width - 30) / 6 - 11);
        
        CALayer *line = [CALayer layer];
        line.backgroundColor = [UIColor lightGrayColor].CGColor;
        line.frame = CGRectMake(0, 0, width, 0.5);
        
        [self addSubview:self.collectionView];
        [self.layer addSublayer:line];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

#pragma - mark SIXEditorTextColorPickerProtocol

- (void)showWithTextView:(UITextView *)textView
               textColor:(UIColor *)textColor
              completion:(void (^)(UIColor *))completion {
    _selectedTextColor = nil;
    for (NSNumber *colorHex in self.textColors) {
        UIColor *color = six_colorWithHex(colorHex.integerValue);
        if (CGColorEqualToColor(color.CGColor, textColor.CGColor)) {
            _selectedTextColor = color;
            break;
        }
    }
    _selectTextColorBlock = completion;
    [_collectionView reloadData];
    textView.inputView = self;
    [textView resignFirstResponder];
    [textView becomeFirstResponder];
}


#pragma - mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return itemCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return itemSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SIXEditorTextColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"textColor" forIndexPath:indexPath];
    NSInteger hex = [self.textColors[indexPath.item] integerValue];
    cell.colorView.backgroundColor = six_colorWithHex(hex);
    
    if (CGColorEqualToColor(cell.colorView.backgroundColor.CGColor, self.selectedTextColor.CGColor)) {
        cell.colorView.layer.cornerRadius = itemSize.width * 0.5;
    } else {
        cell.colorView.layer.cornerRadius = 0;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger hex = [self.textColors[indexPath.item] integerValue];
    _selectedTextColor = six_colorWithHex(hex);
    _selectTextColorBlock(_selectedTextColor);
    _selectTextColorBlock = nil;
    [collectionView reloadData];
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
        [_collectionView registerClass:SIXEditorTextColorCell.class forCellWithReuseIdentifier:@"textColor"];
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

@end

