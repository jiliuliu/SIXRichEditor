//
//  SIXTextView.h
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorHeader.h"

@interface SIXEditorView : UITextView

// 本地图片上传代理
- (void)setImageUploader:(id <SIXEditorImageUploader>)uploader;

// html：设置html
// completion：设置完成回调
- (void)setHtml:(NSString *)html completion:(void (^)(void))completion;

// completion：获取html
- (void)getHtml:(void (^)(NSString *html))completion;

@end
