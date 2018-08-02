//
//  SIXEditorInputManager.m
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorInputManager.h"
#import "SIXEditorToolBar.h"
#import "SIXEditorView.h"
#import "SIXEditorInputView.h"

@interface SIXEditorInputManager () 
{
    CGFloat editorInsetsBottom;
}

@end

@implementation SIXEditorInputManager

- (void)setEditorView:(SIXEditorView *)editorView {
    _editorView = editorView;
    editorView.inputAccessoryView = self.toolBar;
    [self addKeyboardNotifications];
    
    self.toolBar.clickItem = ^(SIXEditorAction action, id value) {
        [editorView handleAction:action andValue:value];
    };
}

- (SIXEditorToolBar *)toolBar {
    if (_toolBar) return _toolBar;
    _toolBar = [[SIXEditorToolBar alloc] init];
    return _toolBar;
}

#pragma - mark keyboard Notifications

- (void)addKeyboardNotifications {
    //Add observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications {
    //Remove observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Toolbar Sizes
    CGFloat sizeOfToolbar = 0;
    
    // Keyboard Size
    //Checks if IOS8, gets correct keyboard height
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    const int extraHeight = 20;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            UIEdgeInsets insets = self.editorView.contentInset;
            insets.bottom = keyboardHeight + sizeOfToolbar + extraHeight + self->editorInsetsBottom;
            self.editorView.contentInset = insets;
            
        } completion:nil];
        
    } else {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            [self.toolBar setEditorInputViewFrameWithShowOrHide:NO];
            [self.toolBar setDefaultItemColors];
            
            UIEdgeInsets insets = self.editorView.contentInset;
            insets.bottom = self->editorInsetsBottom;
            self.editorView.contentInset = insets;
            
        } completion:^(BOOL finished) {
            if (self.toolBar.inputView.superview) {
                [self.toolBar.inputView removeFromSuperview];
            }
        }];
    }
}

- (void)dealloc {
    [self removeKeyboardNotifications];
}

@end
