//
//  XKHTMLParser.m
//  XKKEditor
//
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXHTMLParser.h"
#import "SIXEditorHeader.h"
#import "UIFont+Category.h"

NSString * const ImagePlaceholderTag = @"\U0000fffc";

@implementation SIXHTMLParser

#pragma - mark  NSAttributedString -> html

- (void)htmlWithAttributed:(NSAttributedString *)attributed
                        orignalHtml:(NSString *)orignalHtml
                completion:(void (^)(NSString *html))completion {
    void (^mainThreadCompletion) (NSString *html) = ^(NSString *html) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(html);
        });
    };
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self inner_htmlWithAttributed:attributed orignalHtml:orignalHtml completion:mainThreadCompletion];
    });
}

- (void)inner_htmlWithAttributed:(NSAttributedString *)attributed
                        orignalHtml:(NSString *)orignalHtml
                completion:(void (^)(NSString *html))completion  {
    if (attributed.length == 0) {
        completion(nil);
        return;
    }
    
    NSMutableString *html = [NSMutableString string];
    NSString *string = attributed.string;
    
    //保存UIImage数组
    NSMutableArray *images = [NSMutableArray array];
    //获取html中的图片地址数组
    NSArray *imageUrls = [self imageUrls:orignalHtml];
    
    [attributed enumerateAttributesInRange:NSMakeRange(0, attributed.length) options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSString *selectString = [string substringWithRange:range];
        
        if ([selectString isEqualToString:ImagePlaceholderTag]) {
            NSTextAttachment *attachment = attrs[NSAttachmentAttributeName];
            if (attachment.image) {
                [html appendFormat:@"<img src='[image%ld]' />", images.count];
                [images addObject:attachment.image];
            } else {
                NSString *imageName = [[attachment.fileWrapper.preferredFilename stringByDeletingPathExtension] stringByDeletingPathExtension];
                for (NSString *imageUrl in imageUrls) {
                    if ([imageUrl containsString:imageName]) {
                        [html appendFormat:@"<img src='%@' />", imageUrl];
                    }
                }
            }
        }
        else if ([selectString isEqualToString:@"\n"]) {
            [html appendString:selectString];
        }
        else {
            UIFont *font = attrs[NSFontAttributeName];
            //字色 16进制
            NSString *textColor = [self hexStringFromColor:attrs[NSForegroundColorAttributeName]];
            //字号
            CGFloat fontSize = font.fontSize;
            CGFloat location = html.length;
            [html appendFormat:@"<span style=\"color:%@; font-size:%.0fpx;\">%@</span>", textColor, fontSize, selectString];
            
            //斜体
            if (font.isItatic) {
                [html insertString:@"<i>" atIndex:location];
                [html appendString:@"</i>"];
            }
            //下划线
            if ([attrs.allKeys containsObject:NSUnderlineColorAttributeName]) {
                [html insertString:@"<u>" atIndex:location];
                [html appendString:@"</u>"];
            }
            //粗体
            if (font.isBold) {
                [html insertString:@"<b>" atIndex:location];
                [html appendString:@"</b>"];
            }
        }
    }];
    
    [html replaceOccurrencesOfString:@"\n" withString:@"<br/>" options:0 range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"null" withString:@"" options:0 range:NSMakeRange(0, html.length)];
    
    if (images.count) { //上传图片
        [self.imageUploader upload:images completion:^(NSDictionary<NSString *,NSString *> * _Nonnull map) {
            for (int i=0; i<images.count; i++) {
                if (map[images[i]]) {
                    [html replaceOccurrencesOfString:[NSString stringWithFormat:@"[image%d]", i] withString:images[i] options:(NSLiteralSearch) range:NSMakeRange(0, html.length)];
                }
            }
            completion(html);
        }];
    } else {
        completion(html);
    }
}


#pragma - mark  html -> NSAttributedString

- (void)attributedWithHtml:(NSString *)html
                    imageWidth:(CGFloat)imageWidth
                completion:(void (^)(NSAttributedString *attributedText))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSAttributedString *attributed = [self attributedWithHtml:html imageWidth:imageWidth];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(attributed);
        });
    });
}

- (NSAttributedString *)attributedWithHtml:(NSString *)htmlString imageWidth:(CGFloat)imageWidth {
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                          NSCharacterEncodingDocumentOption: @(NSUTF8StringEncoding)};
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData:data options:dic
                                            documentAttributes:nil error:nil];
    //斜体适配
    NSMutableAttributedString *mAttributedString = attributedString.mutableCopy;
    [mAttributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, mAttributedString.length) options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[UIFont class]]) {
            UIFont *font = value;
            if (font.isItatic) {
                [mAttributedString addAttribute:NSFontAttributeName value:[font copyWithItatic:true] range:range];
            }
        }
    }];
    
    //为了调整图片尺寸 需要在图片名后面拼接有图片宽高 例如：img-880x568.jpg
    [mAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, mAttributedString.length) options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            NSTextAttachment *attachment = value;
            NSString *imageName = [[attachment.fileWrapper.preferredFilename stringByDeletingPathExtension] stringByDeletingPathExtension];
            NSArray *sizeArr = [[imageName componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"x"];
            if (sizeArr.count == 2) {
                CGFloat width0 = [sizeArr[0] floatValue];
                CGFloat height0 = [sizeArr[1] floatValue];
                attachment.bounds = CGRectMake(0, 0, imageWidth, imageWidth * height0 / width0);
            } else {
                attachment.bounds = CGRectMake(0, 0, imageWidth, imageWidth * 0.5);
            }
        }
    }];
    return mAttributedString.copy;
}


#pragma - mark tool

// UIColor转#ffffff格式的字符串
- (NSString *)hexStringFromColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    return [NSString stringWithFormat:@"#%06x", rgb];
}

//获取html中的图片地址数组
- (NSArray *)imageUrls:(NSString *)html {
    if (html.length == 0) return @[];
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    [regex enumerateMatchesInString:html
                            options:0
                              range:NSMakeRange(0, [html length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *url = [html substringWithRange:[result rangeAtIndex:2]];
                             NSLog(@"img src %@",url);
                             [array addObject:url];
                         }];
    return array.copy;
}

/*
 NSMutableArray *exclude = [NSMutableArray array];
 // 如果要使用XHTML文档，可以注释掉下面这行，否则会使用HTML 4.01。
 [exclude addObject:@"XML"];
 // 如果要使用HTML Transitional，注释掉下面这行。否则就用HTML Strict。
 // 不过HTML Transitional支持font标签，而这显然不是我们想要的。
 [exclude addObjectsFromArray:[NSArray arrayWithObjects:@"APPLET", @"BASEFONT", @"CENTER", @"DIR", @"FONT", @"ISINDEX", @"MENU", @"S", @"STRIKE", @"U", nil]];
 // 如果要将CSS放入HTML的head标签中，可以注释掉下面这样：
 [exclude addObject:@"STYLE"];
 // 如果要完全不用CSS，同时注释掉上面这样和下面这行。
 //        [exclude addObject:@"SPAN"];
 // 如果要保留空格字符，注释掉下面几行——因为HTML会把任意长的空格合成一个空格的。
 [exclude addObject:@"Apple-converted-space"];
 [exclude addObject:@"Apple-converted-tab"];
 [exclude addObject:@"Apple-interchange-newline"];
 // 如果不要完整的HTML结构，则取消注释下面一行。
 [exclude addObjectsFromArray:[NSArray arrayWithObjects:@"doctype", @"html", @"head", @"body", nil]];
 
 NSDictionary *htmlAtt = [NSDictionary dictionaryWithObjectsAndKeys:
 NSHTMLTextDocumentType, NSDocumentTypeDocumentAttribute,
 exclude, @"ExcludedElements", nil];
 NSError *error;
 NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:htmlAtt error:&error ];
 NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
 */

@end
