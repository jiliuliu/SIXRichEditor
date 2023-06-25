//
//  SIXTextView.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorView.h"
#import "SIXEditorToolBar.h"
#import "SIXEditorToolController.h"
#import "UIFont+Category.h"
#import "SIXHTMLParser.h"

@interface SIXEditorView () <SIXEditorProtocol>
{
    CGFloat fontSize;
    UIColor *textColor;
    
    BOOL isBold;
    BOOL isItalic;
    BOOL isUnderline;
    
    SIXEditorAction action;
}

@property (nonatomic, strong) SIXEditorToolController *toolController;
@property (nonatomic, strong) SIXHTMLParser *parser;

@property (nonatomic, strong) NSString *html;

@end

@implementation SIXEditorView
@synthesize textStyleUpdated;

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
        self.allowsEditingTextAttributes = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.font = [UIFont systemFontOfSize:fontSize];
        
        _parser = [[SIXHTMLParser alloc] init];
        _toolController = [[SIXEditorToolController alloc] initWithEditor:self];
        [self resetTypingAttributes];
        [self sendTextStyleUpdate];
    }
    return self;
}

- (void)setImageUploader:(id<SIXEditorImageUploader>)uploader {
    self.parser.imageUploader = uploader;
}

- (void)setEditable:(BOOL)editable {
    [super setEditable:editable];
    if (editable) {
        self.toolController = [[SIXEditorToolController alloc] initWithEditor:self];
    } else {
        self.inputAccessoryView = nil;
        self.toolController = nil;
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
            dict[NSFontAttributeName] = [font copyWithBold:isBold];
        }
            break;
        case SIXEditorActionItatic: {
            UIFont *font = dict[NSFontAttributeName];
            dict[NSFontAttributeName] = [font copyWithItatic:isItalic];
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
            dict[NSFontAttributeName] = [font copyWithFontSize:fontSize];
        }
            break;
        case SIXEditorActionTextColor: {
            dict[NSForegroundColorAttributeName] = textColor;
        }
            break;
        default:
            break;
    }
    
    return dict.copy;
}


#pragma - mark ------ SIXEditorProtocol -------

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
            rangeSelector = @selector(setItaticInRange);
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
            [self insertImageInRange:(UIImage *)value];
            return;
        default:
            break;
    }
    
    if (self.selectedRange.length > 0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:rangeSelector];
        #pragma clang diagnostic pop
    } else {
        [self resetTypingAttributes];
    }
}

- (void)modifyAttributedText:(void (^)(NSMutableAttributedString *attributedString))block {
    NSRange range = self.selectedRange;
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    block(attributedString);
    self.attributedText = attributedString;
    self.selectedRange = range;
    [self scrollRangeToVisible:range];
}

- (void)setBoldInRange {
    [self modifyAttributedText:^(NSMutableAttributedString *attributedString) {
        [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[UIFont class]]) {
                UIFont *font = value;
                [attributedString addAttribute:NSFontAttributeName value:[font copyWithBold:self->isBold] range:range0];
            }
        }];
    }];
}

- (void)setItaticInRange {
    [self modifyAttributedText:^(NSMutableAttributedString *attributedString) {
        [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[UIFont class]]) {
                UIFont *font = value;
                [attributedString addAttribute:NSFontAttributeName value:[font copyWithItatic:self->isItalic] range:range0];
            }
        }];
    }];
}

- (void)setUnderlineInRange {
    [self modifyAttributedText:^(NSMutableAttributedString *attributedString) {
        if (self->isUnderline == NO) {
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
    }];
}

- (void)setFontSizeInRange {
    [self modifyAttributedText:^(NSMutableAttributedString *attributedString) {
        [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[UIFont class]]) {
                UIFont *font = value;
                [attributedString addAttribute:NSFontAttributeName value:[font copyWithFontSize:self->fontSize] range:range0];
            }
        }];
    }];
}

- (void)setTextColorInRange {
    [self modifyAttributedText:^(NSMutableAttributedString *attributedString) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self->textColor range:self.selectedRange];
    }];
}

- (void)insertImageInRange:(UIImage *)image {
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
    
    //恢复焦点
    self.selectedRange = NSMakeRange(location, 0);
    [self becomeFirstResponder];
}

#pragma - mark ------ update toolbar item color -------

/*
    当焦点发生变化时，tool bar 的状态需要同步更新
 */
- (void)sendTextStyleUpdate  {
    if ([self isFirstResponder] == NO) return;
    NSDictionary *attrs = self.typingAttributes;
    UIFont *font = attrs[NSFontAttributeName];
    isItalic = font.isItatic;
    isBold = font.isBold;
    isUnderline = [attrs.allKeys containsObject:NSUnderlineStyleAttributeName];
    textColor = attrs[NSForegroundColorAttributeName];
    fontSize = font.fontSize;
    self.textStyleUpdated(fontSize, textColor, isItalic, isUnderline, isBold);
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
            [self sendTextStyleUpdate];
        });
    }
    return [super hitTest:point withEvent:event];
}

#pragma - mark ------ html parse -------

- (void)setHtml:(NSString *)html completion:(void (^)(void))completion {
    _html = html;
    if (html.length == 0) {
        self.attributedText = nil;
        return;
    }
    CGFloat imageWidth = self.frame.size.width - self.textContainer.lineFragmentPadding * 2;
    [self.parser attributedWithHtml:html imageWidth:imageWidth completion:^(NSAttributedString *attributedText) {
        self.attributedText = attributedText;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

- (void)getHtml:(void (^)(NSString *))completion {
    [self.parser htmlWithAttributed:self.attributedText orignalHtml:self.html completion: completion];
}

@end
