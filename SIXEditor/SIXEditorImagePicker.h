//
//  SIXEditorImagePicker.h
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SIXEditorImagePickerProtocol 

- (void)showWithCompletion:(void (^) (UIImage *))completion;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SIXEditorImagePicker : NSObject <SIXEditorImagePickerProtocol>

@end

NS_ASSUME_NONNULL_END
