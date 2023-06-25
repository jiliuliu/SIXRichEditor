//
//  SIXEditorTextColorPicker.h
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SIXEditorTextColorPickerProtocol

- (void)showWithTextView:(UITextView *)textView
                textColor:(UIColor *)textColor
              completion:(void (^) (UIColor *))completion;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SIXEditorTextColorPicker : UIView <SIXEditorTextColorPickerProtocol>

@end

NS_ASSUME_NONNULL_END
