//
//  SIXTextView.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorView.h"
#import "SIXEditorToolBar.h"
#import "SIXEditorInputManager.h"

@interface SIXEditorView ()
{
    CGFloat fontSize;
//    NSTextAlignment six_textAlignment;
    UIColor *textColor;
    
    BOOL isBold;
    BOOL isItalic;
    BOOL isUnderline;
    
    SIXEditorAction action;
}

@property (nonatomic, strong) SIXEditorInputManager *inputManager;
@end

@implementation SIXEditorView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        fontSize = 16;
        textColor = [UIColor blackColor];
        isBold = NO;
        isItalic = NO;
        isUnderline = NO;
        action = SIXEditorActionNone;
        
        self.textColor = textColor;
        self.selectable = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.font = [UIFont systemFontOfSize:fontSize];
//        self.placeholder = @"点击屏幕，开始编辑。。。";
        
        [self resetTypingAttributes];
        
        //键盘控制器
        _inputManager = [[SIXEditorInputManager alloc] init];
        _inputManager.editorView = self;
        _inputManager.toolBar.inputView.selectedFontSize = fontSize;
        _inputManager.toolBar.inputView.selectedTextColor = textColor;
    }
    return self;
}

- (void)setEditable:(BOOL)editable {
    [super setEditable:editable];
    
    if (editable == NO) {
        self.inputAccessoryView = nil;
    } else {
        self.inputAccessoryView = self.inputManager.toolBar;
    }
}

- (void)resetTypingAttributes {
    if (self.selectedRange.length) return;
    self.typingAttributes = [self currentAttributes];
}

- (NSMutableDictionary *)currentAttributes {
    NSMutableDictionary *dict = self.typingAttributes.mutableCopy;
    
    switch (action) {
        case SIXEditorActionBold: {
            UIFont *font = dict[NSFontAttributeName];
            CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
            if (isBold) {
                dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:fontSize];
            } else {
                dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
            }
        }
            break;
        case SIXEditorActionItatic: {
            if (isItalic) {
                dict[NSObliquenessAttributeName] = @(Editor_Italic_Rate);
            } else {
                [dict removeObjectForKey:NSObliquenessAttributeName];
            }
        }
            break;
        case SIXEditorActionUnderline: {
            if (isUnderline) {
                UIColor *color = dict[NSForegroundColorAttributeName];
                dict[NSUnderlineColorAttributeName] = color;
                dict[NSUnderlineStyleAttributeName] = @1;
            } else {
                [dict removeObjectForKey:NSUnderlineColorAttributeName];
                [dict removeObjectForKey:NSUnderlineStyleAttributeName];
            }
        }
            break;
        case SIXEditorActionFontSize: {
            UIFont *font = dict[NSFontAttributeName];
            if ((font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0) {
                dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:fontSize];
            } else {
                dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
            }
        }
            break;
        case SIXEditorActionTextColor: {
            dict[NSForegroundColorAttributeName] = textColor;
        }
            break;
        case SIXEditorActionImage:
            break;
        default:
            break;
    }
    
    return dict.copy;
}


#pragma - mark ------- actions -------

- (void)handleAction:(SIXEditorAction)newAction andValue:(id)value {
    action = newAction;
    SEL rangeSelector = nil;
    
    switch (action) {
        case SIXEditorActionBold:
            isBold = [value boolValue];
            rangeSelector = @selector(setBoldInRange);
            break;
        case SIXEditorActionItatic:
            isItalic = [value boolValue];
            rangeSelector = @selector(setItalicInRange);
            break;
        case SIXEditorActionUnderline:
            isUnderline = [value boolValue];
            rangeSelector = @selector(setUnderlineInRange);
            break;
        case SIXEditorActionFontSize:
            fontSize = [value floatValue];
            rangeSelector = @selector(setFontSizeInRange);
            break;
        case SIXEditorActionTextColor:
            textColor = (UIColor *)value;
            rangeSelector = @selector(setTextColorInRange);
            break;
        case SIXEditorActionImage:
            [self setImage:(UIImage *)value];
            return;
        case SIXEditorActionKeyboard:
            [self resignFirstResponder];
            return;
        default:
            break;
    }
    
    if (self.selectedRange.length) {
        NSRange range = self.selectedRange;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:rangeSelector];
        #pragma clang diagnostic pop
        
        self.selectedRange = range;
        [self scrollRangeToVisible:range];
    } else {
        [self resetTypingAttributes];
    }
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        [self becomeFirstResponder];
        return;
    }
    
    CGFloat width = self.frame.size.width-self.textContainer.lineFragmentPadding*2;
    
    NSMutableAttributedString *mAttributedString = self.attributedText.mutableCopy;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, width, width * image.size.height / image.size.width);
    attachment.image = image;
    
    NSMutableAttributedString *attachmentString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attachmentString addAttributes:[self currentAttributes] range:NSMakeRange(0, attachmentString.length)];
    
    [mAttributedString insertAttributedString:attachmentString atIndex:NSMaxRange(self.selectedRange)];
    
    //更新attributedText
    NSInteger location = NSMaxRange(self.selectedRange) + 1;
    self.attributedText = mAttributedString.copy;
    
    //回复焦点
    self.selectedRange = NSMakeRange(location, 0);
    [self becomeFirstResponder];
}

- (void)setBoldInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIFont class]]) {
            UIFont *font = value;
            //字号
            CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
            UIFont *newFont = self->isBold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
            [attributedString addAttribute:NSFontAttributeName value:newFont range:range0];
        }
    }];
    
    self.attributedText = attributedString.copy;
}

- (void)setItalicInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    if (isItalic) {
        [attributedString addAttribute:NSObliquenessAttributeName value:@(Editor_Italic_Rate) range:self.selectedRange];
    } else {
        [attributedString removeAttribute:NSObliquenessAttributeName range:self.selectedRange];
    }
    
    self.attributedText = attributedString.copy;
}

- (void)setUnderlineInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    if (isUnderline == NO) {
        [attributedString removeAttribute:NSUnderlineStyleAttributeName range:self.selectedRange];
        [attributedString removeAttribute:NSUnderlineColorAttributeName range:self.selectedRange];
        self.attributedText = attributedString.copy;
        return;
    }
    
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIColor class]]) {
            UIColor *color = value;
            [attributedString addAttribute:NSUnderlineColorAttributeName value:color range:range0];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:range0];
        }
    }];
    self.attributedText = attributedString.copy;
}

- (void)setFontSizeInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIFont class]]) {
            UIFont *font = value;
            UIFont *newFont = nil;
            //粗体
            if ((font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0) {
                newFont = [UIFont boldSystemFontOfSize:self->fontSize];
            } else {
                newFont = [UIFont systemFontOfSize:self->fontSize];
            }
            [attributedString addAttribute:NSFontAttributeName value:newFont range:range0];
        }
    }];
    
    self.attributedText = attributedString.copy;
}

- (void)setTextColorInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:self.selectedRange];
    self.attributedText = attributedString.copy;
}


#pragma - mark ------ update toolbar item color -------

- (void)changeColorOfToolBarItem  {
    if ([self isFirstResponder] == NO) return;
    
    NSDictionary *attrs = self.typingAttributes;
    
    //斜体
    isItalic = [attrs.allKeys containsObject:NSObliquenessAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionItatic andValue:@(italic)];
    //下划线
    isUnderline = [attrs.allKeys containsObject:NSUnderlineColorAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionUnderline andValue:@(isUnderline)];
    //粗体
    UIFont *font = attrs[NSFontAttributeName];
    isBold = (font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionBold andValue:@(isBold)];
    //字色
    UIColor *color = attrs[NSForegroundColorAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionTextColor andValue:color];
    //字体大小
    CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionFontSize andValue:@(fontSize)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    static UIEvent *e = nil;
    
    if (e != nil && e == event) {
        e = nil;
        return [super hitTest:point withEvent:event];
    }
    
    e = event;
    
    if (event.type == UIEventTypeTouches) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeColorOfToolBarItem];
        });
    }
    return [super hitTest:point withEvent:event];
}


@end


//- (void)setTextAlignmentInRange {
//    NSRange range = self.selectedRange;
//    NSDictionary *dict = [self.attributedText attributesAtIndex:self.selectedRange.location effectiveRange:&range];
//    NSParagraphStyle *style = dict[NSParagraphStyleAttributeName];
//
//    NSMutableParagraphStyle *mStyle = style.mutableCopy;
//    mStyle.alignment = self->six_textAlignment;
//    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:mStyle range:self.selectedRange];
//    self.attributedText = attributedString.copy;
//}
