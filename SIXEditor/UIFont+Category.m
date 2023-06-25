//
//  UIFont+Category.m
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/21.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "UIFont+Category.h"

@implementation UIFont (Category)

- (BOOL)isBold {
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (BOOL)isItatic {
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (CGFloat)fontSize {
    return [self.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
}

- (UIFont *)copyWithItatic:(BOOL)isItatic {
    return [self copyWithSymbolicTrait:UIFontDescriptorTraitItalic add:isItatic];
}

- (UIFont *)copyWithBold:(BOOL)isBold {
    return [self copyWithSymbolicTrait:UIFontDescriptorTraitBold add:isBold];
}

- (UIFont *)copyWithFontSize:(CGFloat)fontSize {
    return [UIFont fontWithDescriptor:self.fontDescriptor size:fontSize];
}

- (UIFont *)copyWithSymbolicTrait:(UIFontDescriptorSymbolicTraits)symbolicTrait add:(BOOL)isAdd {
    UIFontDescriptorSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits;
    BOOL currentSymbolicTrait = (symbolicTraits & symbolicTrait) > 0;
    if (!currentSymbolicTrait && isAdd) {
        symbolicTraits |= symbolicTrait;
    }
    if (currentSymbolicTrait && !isAdd) {
        symbolicTraits &= (~symbolicTrait);
    }
    UIFontDescriptor * fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits];
    if ((symbolicTraits & UIFontDescriptorTraitItalic) > 0) {
        CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(20 * (CGFloat)M_PI / 180), 1, 0, 0);
        fontDescriptor = [fontDescriptor fontDescriptorWithMatrix:matrix];
    }
    return [UIFont fontWithDescriptor:fontDescriptor size:0];
}

@end
