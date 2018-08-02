//
//  SIXTextView.h
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"


@interface SIXEditorView : UITextView


#pragma - mark actions

- (void)handleAction:(SIXEditorAction)newAction andValue:(id)value;

@end
