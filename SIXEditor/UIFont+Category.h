//
//  UIFont+Category.h
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/21.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Category)

@property (nonatomic, readonly) BOOL isBold;
@property (nonatomic, readonly) BOOL isItatic;
@property (nonatomic, readonly) CGFloat fontSize;

- (UIFont *)copyWithItatic:(BOOL)isItatic;
- (UIFont *)copyWithBold:(BOOL)isBold;
- (UIFont *)copyWithFontSize:(CGFloat)fontSize;
@end

NS_ASSUME_NONNULL_END
