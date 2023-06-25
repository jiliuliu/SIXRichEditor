//
//  SIXEditorToolBar.h
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"


@interface SIXEditorToolBar : UIView

// actions: NSArray<SIXEditorAction>
- (instancetype)initWithActions:(NSArray *)actions toolButtonTapped:(void (^)(SIXEditorAction, BOOL))tapped;

- (void)updateWithItatic:(BOOL)isItatic isUnderline:(BOOL)isUnderline isBold:(BOOL)isBold;

- (void)resetButton:(SIXEditorAction)action;

@end

