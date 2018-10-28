//
//  SIXEditorToolBar.h
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"
#import "SIXEditorInputView.h"

@class SIXEditorInputView;
@interface SIXEditorToolBar : UIView <SIXEditorInputViewDelegate>
@property (nonatomic, strong) SIXEditorInputView *inputView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) void (^clickItem) (SIXEditorAction action, id value);

- (void)refreshUIOfItemButton:(SIXEditorAction)action andValue:(id)value;
- (void)setEditorInputViewFrameWithShowOrHide:(BOOL)isShow;
- (void)setDefaultItemColors;
@end

