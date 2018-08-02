//
//  SIXEditorInputView.h
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"

@class SIXEditorInputView;
@protocol SIXEditorInputViewDelegate <NSObject>

- (void)inputView:(SIXEditorInputView *)inputView clickItemForFontSize:(CGFloat)size;
- (void)inputView:(SIXEditorInputView *)inputView clickItemForTextColor:(UIColor *)color;

@end

@interface SIXEditorInputView : UIView

@property (nonatomic, assign) NSInteger selectedFontSize;
@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, assign) SIXEditorAction editorAction;
@property (nonatomic, weak) id <SIXEditorInputViewDelegate> delegate;

- (void)reloadData;
@end
