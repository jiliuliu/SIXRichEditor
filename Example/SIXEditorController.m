//
//  SIXEditorController.m
//  SIXRichEditor
//
//  Created by  on 2018/7/31.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorController.h"
#import "SIXEditorView.h"
#import "SIXHTMLParser.h"

@interface SIXEditorController () <UITextViewDelegate>

@property (nonatomic, strong) SIXEditorView *editorView;

@end


@implementation SIXEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"富文本编辑器";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat top = self.navigationController.navigationBar.frame.size.height;
    top += [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, UIEdgeInsetsMake(top, 0, 0, 0));
    self.editorView = [[SIXEditorView alloc] initWithFrame:frame];
    [self.view addSubview:self.editorView];
    
    if (@available(iOS 11.0, *)) {
        self.editorView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"html" style:(UIBarButtonItemStylePlain) target:self action:@selector(showHtmlString)];
    
    __weak typeof(self) weakSelf = self;
    [self.editorView setHtml:[self exampleHTML] completion:^{
        __weak typeof(self) strongSelf = weakSelf;
        [strongSelf.editorView becomeFirstResponder];
    }];
}

- (void)showHtmlString {
    static NSAttributedString *attributedText = nil;
    [self.editorView resignFirstResponder];
    self.editorView.editable = !self.editorView.editable;
    if (self.editorView.editable) {
        self.editorView.attributedText = attributedText;
        return;
    }
    attributedText = self.editorView.attributedText;
    [self.editorView getHtml:^(NSString *html) {
        if(html == nil) return;
        NSMutableString *mHtml = html.mutableCopy;
        [mHtml replaceOccurrencesOfString:@"/>" withString:@"/>\n" options:0 range:NSMakeRange(0, mHtml.length)];
        [mHtml replaceOccurrencesOfString:@"/span>" withString:@"/span>\n" options:0 range:NSMakeRange(0, mHtml.length)];
        self.editorView.attributedText = [[NSAttributedString alloc] initWithString:mHtml.copy attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor blackColor]}];
    }];
}

- (NSString *)exampleHTML {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"txt"];
    NSError *error = nil;
    NSString *txt = [NSString stringWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:&error];
    return txt;
}

@end
