//
//  SIXEditorFontSizePicker.h
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SIXEditorFontSizePickerProtocol

- (void)showWithTextView:(UITextView *)textView
                fontSize:(CGFloat)fontSize
              completion:(void (^) (CGFloat))completion;

@end

@interface SIXEditorFontSizePicker : UIView <SIXEditorFontSizePickerProtocol>

@end

NS_ASSUME_NONNULL_END
