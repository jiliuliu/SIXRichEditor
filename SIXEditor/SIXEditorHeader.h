//
//  SIXEditorConst.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SIXEditorAction) {
    SIXEditorActionNone,
    SIXEditorActionBold,
    SIXEditorActionItatic,
    SIXEditorActionUnderline,
    SIXEditorActionTextColor,
    SIXEditorActionFontSize,
    SIXEditorActionImage,
    SIXEditorActionKeyboard,
};

static CGFloat const Editor_ToolBar_Height = 40;

NS_INLINE UIColor * _Nonnull six_colorWithHex(NSInteger hex) {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}

typedef void (^ _Nonnull SIXEditorTextStyleBlock) (CGFloat fontSize, UIColor * _Nullable textColor, BOOL isItatic, BOOL isUnderline, BOOL isBold);

@protocol SIXEditorProtocol

@property (nonatomic, copy) SIXEditorTextStyleBlock textStyleUpdated;

- (void)handleAction:(SIXEditorAction)action andValue:(id _Nullable )value;

@end

@protocol SIXEditorImageUploader

- (void)upload:(NSArray<NSString *> *_Nonnull)images
        completion:(void (^_Nonnull)(NSDictionary<NSString *, NSString *> * _Nonnull map))completion;

@end
