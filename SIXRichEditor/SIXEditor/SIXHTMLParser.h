//
//  XKHTMLParser.h
//  XKKEditor
//
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
    数据转换过程：(双向)
    NSAttributedString <-> HTML
 */
@interface SIXHTMLParser : NSObject

//NSAttributedString -> html
//异步
+ (void)htmlStringWithAttributedText:(NSAttributedString *)attributedText
                         orignalHtml:(NSString *)orignalHtml
                andCompletionHandler:(void (^)(NSString *html))handler;
//同步  有图片时  是异步
+ (void)sync_htmlStringWithAttributedText:(NSAttributedString *)attributedText
                              orignalHtml:(NSString *)orignalHtml
                     andCompletionHandler:(void (^)(NSString *html))handler;


//html -> NSAttributedString
//异步
+ (void)attributedTextWithHtmlString:(NSString *)htmlString
                          imageWidth:(CGFloat)width
                andCompletionHandler:(void (^)(NSAttributedString *attributedText))handler;
//同步
+ (NSAttributedString *)attributedTextWithHtmlString:(NSString *)htmlString
                                       andImageWidth:(CGFloat)width;


@end
