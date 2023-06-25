//
//  SIXEditorToolController.m
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "SIXEditorToolController.h"
#import "SIXEditorHeader.h"
#import "SIXEditorToolBar.h"
#import "SIXEditorTextColorPicker.h"
#import "SIXEditorImagePicker.h"
#import "SIXEditorFontSizePicker.h"

@interface SIXEditorToolController() 
{
    CGFloat editorInsetsBottom;
    CGFloat keyboardHeight;
}

@property (nonatomic, weak) UITextView <SIXEditorProtocol> *editor;
@property (nonatomic, strong) SIXEditorToolBar *toolBar;
@property (nonatomic, strong) id <SIXEditorImagePickerProtocol> imagePicker;
@property (nonatomic, strong) UIView <SIXEditorTextColorPickerProtocol> * textColorPicker;
@property (nonatomic, strong) UIView <SIXEditorFontSizePickerProtocol> *fontSizePicker;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) UIColor *textColor;

@end


@implementation SIXEditorToolController

- (instancetype)initWithEditor:(UITextView<SIXEditorProtocol> *)editor {
    self = [super init];
    if (self) {
        self.editor = editor;
        [self addKeyboardNotifications];
    }
    return self;
}

- (void)dealloc {
    [self removeKeyboardNotifications];
}

#pragma - mark get set

- (void)setEditor:(UITextView<SIXEditorProtocol> *)editor {
    _editor = editor;
    _editor.inputAccessoryView = self.toolBar;
    __weak typeof(self) weakSelf = self;
    _editor.textStyleUpdated = ^(CGFloat fontSize, UIColor * _Nullable textColor, BOOL isItatic, BOOL isUnderline, BOOL isBold) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.fontSize = fontSize;
        strongSelf.textColor = textColor;
        [strongSelf.toolBar updateWithItatic:isItatic isUnderline:isUnderline isBold:isBold];
    };
}

- (SIXEditorToolBar *)toolBar {
    if (_toolBar) return _toolBar;
    NSArray *actions = @[@(SIXEditorActionBold),
                         @(SIXEditorActionUnderline),
                         @(SIXEditorActionItatic),
                         @(SIXEditorActionFontSize),
                         @(SIXEditorActionTextColor),
                         @(SIXEditorActionImage)];
    __weak typeof(self) weakSelf = self;
    _toolBar = [[SIXEditorToolBar alloc] initWithActions:actions toolButtonTapped:^(SIXEditorAction action, BOOL isSelected) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf toolButtonTapped:action isSelected:isSelected];
    }];
    return _toolBar;
}

- (id<SIXEditorImagePickerProtocol>)imagePicker {
    if (_imagePicker) return _imagePicker;
    _imagePicker = [[SIXEditorImagePicker alloc] init];
    return _imagePicker;
}

- (UIView<SIXEditorTextColorPickerProtocol> *)textColorPicker {
    if (_textColorPicker) return _textColorPicker;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, size.width, keyboardHeight - Editor_ToolBar_Height);
    _textColorPicker = [[SIXEditorTextColorPicker alloc] initWithFrame:frame];
    return _textColorPicker;
}

- (UIView<SIXEditorFontSizePickerProtocol> *)fontSizePicker {
    if (_fontSizePicker) return _fontSizePicker;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, size.width, keyboardHeight - Editor_ToolBar_Height);
    _fontSizePicker = [[SIXEditorFontSizePicker alloc] initWithFrame:frame];
    return _fontSizePicker;
}

#pragma - mark SIXEditorToolDelegate

- (void)toolButtonTapped:(SIXEditorAction)action isSelected:(BOOL)isSelected {
    if ((action == SIXEditorActionFontSize || action == SIXEditorActionTextColor) && !isSelected) {
        self.editor.inputView = nil;
        [self.editor resignFirstResponder];
        [self.editor becomeFirstResponder];
        return;
    }
    switch (action) {
        case SIXEditorActionNone:
            break;
        case SIXEditorActionBold:
        case SIXEditorActionItatic:
        case SIXEditorActionUnderline:
            [self resetKeyboardIfNeed];
            [self.editor handleAction:action andValue:@(isSelected)];
            break;
        case SIXEditorActionKeyboard:
            self.editor.inputView = nil;
            [self.editor resignFirstResponder];
            break;
        case SIXEditorActionFontSize: {
            [self.fontSizePicker showWithTextView:self.editor fontSize:_fontSize completion:^(CGFloat val) {
                self.fontSize = val;
                [self.editor handleAction:action andValue:@(val)];
                [self resetKeyboardIfNeed];
                [self.toolBar resetButton:SIXEditorActionFontSize];
            }];
        }
            break;
        case SIXEditorActionTextColor: {
            [self.textColorPicker showWithTextView:self.editor textColor:_textColor completion:^(UIColor *val) {
                self.textColor = val;
                [self.editor handleAction:action andValue:val];
                [self resetKeyboardIfNeed];
                [self.toolBar resetButton:SIXEditorActionTextColor];
            }];
        }
            break;
        case SIXEditorActionImage:
            [self.imagePicker showWithCompletion:^(UIImage *image) {
                [self.editor handleAction:action andValue:image];
            }];
            break;
    }
}

- (void)resetKeyboardIfNeed {
    if (self.editor.inputView == nil) return;
    self.editor.inputView = nil;
    [self.editor resignFirstResponder];
    [self.editor becomeFirstResponder];
}

#pragma - mark keyboard Notifications

- (void)addKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications {
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
    if (keyboardHeight == 0) {
        keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    }
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    const int extraHeight = 20;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            UIEdgeInsets insets = self.editor.contentInset;
            insets.bottom = self->keyboardHeight + sizeOfToolbar + extraHeight + self->editorInsetsBottom;
            self.editor.contentInset = insets;
        } completion:nil];
    } else {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            UIEdgeInsets insets = self.editor.contentInset;
            insets.bottom = self->editorInsetsBottom;
            self.editor.contentInset = insets;
        } completion:^(BOOL finished) { }];
    }
}

@end
