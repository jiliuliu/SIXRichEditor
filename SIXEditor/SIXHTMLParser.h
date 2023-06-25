//
//  XKHTMLParser.h
//  XKKEditor
//
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"

/**
    数据转换过程：(双向)
    NSAttributedString <-> HTML
 */
@interface SIXHTMLParser : NSObject

@property (nonatomic, strong) id <SIXEditorImageUploader> imageUploader;

- (void)htmlWithAttributed:(NSAttributedString *)attributed
                        orignalHtml:(NSString *)orignalHtml
                   completion:(void (^)(NSString *html))completion;

- (void)attributedWithHtml:(NSString *)html
                    imageWidth:(CGFloat)imageWidth
                completion:(void (^)(NSAttributedString *attributedText))completion;

@end
