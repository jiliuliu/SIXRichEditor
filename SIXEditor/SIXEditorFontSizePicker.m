//
//  SIXEditorFontSizePicker.m
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "SIXEditorFontSizePicker.h"
#import "SIXEditorHeader.h"

@interface SIXEditorFontSizeCell: UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *colorView;
@end

@implementation SIXEditorFontSizeCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor blackColor];
        [self.contentView addSubview:_label];
    }
    return _label;
}

@end


@interface SIXEditorFontSizePicker()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>
{
    NSInteger itemCount;
    CGSize itemSize;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat selectedFontSize;
@property (nonatomic, strong) NSArray *fontSizes;

@property (nonatomic, copy) void (^selectFontSizeBlock) (CGFloat);

@end

@implementation SIXEditorFontSizePicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = frame.size.width;
        itemCount = self.fontSizes.count;
        itemSize = CGSizeMake(width-30, 35);
        
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
               fontSize:(CGFloat)fontSize
              completion:(void (^)(CGFloat))completion {
    if (textView.inputView == self) {
        textView.inputView = nil;
        [textView becomeFirstResponder];
        return;
    }
    _selectedFontSize = [self.fontSizes containsObject:@(fontSize)] ? fontSize : 0;
    _selectFontSizeBlock = completion;
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
    SIXEditorFontSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fontSize" forIndexPath:indexPath];
    CGFloat size = [self.fontSizes[indexPath.item] floatValue];
    cell.label.font = [UIFont systemFontOfSize:size];
    cell.label.text = [NSString stringWithFormat:@"%@px ABC", self.fontSizes[indexPath.item]];
    if (size == self.selectedFontSize) {
        cell.label.textColor = [UIColor blueColor];
    } else {
        cell.label.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat hex = [self.fontSizes[indexPath.item] floatValue];
    _selectFontSizeBlock(hex);
    _selectFontSizeBlock = nil;
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
        [_collectionView registerClass:SIXEditorFontSizeCell.class forCellWithReuseIdentifier:@"fontSize"];
    }
    return _collectionView;
}

- (NSArray *)fontSizes {
    if (!_fontSizes) {
        _fontSizes = @[@12, @14, @16, @18, @20, @24, @28];
    }
    return _fontSizes;
}

@end

