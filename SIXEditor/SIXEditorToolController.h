//
//  SIXEditorToolController.h
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface SIXEditorToolController : NSObject

- (instancetype)initWithEditor:(UITextView <SIXEditorProtocol> *)editor;

@end

NS_ASSUME_NONNULL_END
