//
//  SIXEditorController.h
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIXEditorController : UIViewController

@property (nonatomic, assign) BOOL editable;

@property (nonatomic, strong) NSString *htmlString;

@property (nonatomic, copy) void (^resultCallBack)(NSString *html);

@end
