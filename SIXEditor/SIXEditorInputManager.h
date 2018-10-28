//
//  SIXEditorInputManager.h
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIXEditorView, SIXEditorToolBar;
@interface SIXEditorInputManager : NSObject

@property (nonatomic, strong) SIXEditorToolBar *toolBar;
@property (nonatomic, weak) SIXEditorView *editorView;
@property (nonatomic, assign) BOOL editable;

@end
