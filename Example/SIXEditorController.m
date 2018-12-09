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
{
    NSAttributedString *attributedString;
}
@property (nonatomic, strong) SIXEditorView *editorView;
@end


@implementation SIXEditorController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _editable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"一个有点丑的编辑器";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0));
    self.editorView = [[SIXEditorView alloc] initWithFrame:frame];
    self.editorView.editable = self.editable;
    [self.view addSubview:self.editorView];
    
    if (@available(iOS 11.0, *)) {
        self.editorView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self loadData];
    
    if (self.htmlString.length == 0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"example" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickExample)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"code" style:(UIBarButtonItemStylePlain) target:self action:@selector(showSource)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:(UIBarButtonItemStylePlain) target:self action:@selector(saveAction)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.htmlString.length == 0) {
        [self.editorView becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.editorView resignFirstResponder];
}

- (void)loadData {
    if (self.htmlString.length == 0) return;
    
    [SIXHTMLParser attributedTextWithHtmlString:self.htmlString
                                     imageWidth:self.editorView.frame.size.width-self.editorView.textContainer.lineFragmentPadding*2
                           andCompletionHandler:^(NSAttributedString *attributedText) {
        self.editorView.attributedText = attributedText;
    }];
}


//数据提取
- (void)saveAction {
    [_editorView resignFirstResponder];
    
    [SIXHTMLParser htmlStringWithAttributedText:self.editorView.attributedText
                                    orignalHtml:self.htmlString
                           andCompletionHandler:^(NSString *html) {

        self.resultCallBack(html);
    }];
}

- (void)clickExample {
    [self.editorView resignFirstResponder];
    
    SIXEditorController *vc = [SIXEditorController new];
    vc.htmlString = [self exampleHTML];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSource {
    [self.editorView resignFirstResponder];
    
    self.editorView.editable = !self.editorView.editable;
    if (self.editorView.editable) {
        self.editorView.attributedText = attributedString;
        attributedString = nil;
    } else {
        attributedString = self.editorView.attributedText;
        [SIXHTMLParser sync_htmlStringWithAttributedText:self.editorView.attributedText
                                             orignalHtml:self.htmlString
                                    andCompletionHandler:^(NSString *html) {
                                        if(html == nil) return ;
                                        NSMutableString *mHtml = html.mutableCopy;
                                        [mHtml replaceOccurrencesOfString:@"/>" withString:@"/>\n" options:0 range:NSMakeRange(0, mHtml.length)];
                                        [mHtml replaceOccurrencesOfString:@"/span>" withString:@"/span>\n" options:0 range:NSMakeRange(0, mHtml.length)];
                                        self.editorView.attributedText = [[NSAttributedString alloc] initWithString:mHtml.copy attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor blackColor]}];
                                    }];
    }
    
}
 

- (NSString *)exampleHTML {
    return @"<p><b><span style=\"font-size:16px;\"><span style=\"font-size:20px;\"><span style=\"color:#0079FE;\">心安，幸福<\/span><\/span><\/span><\/b><\/p>\n<br>\n<p><b><span style=\"font-size:20px;\"><span style=\"color:#0079FE;\"><span style=\"font-size:16px;\"><img src=\"https:\/\/file.dev.91xiangke.com\/user\/upload\/1e6b74c6d2a44b7582bb95f3b64e8ff2\/ee53130d-6429-426b-92f3-49959c3936951532313418546-880x568.jpg\" \/><\/span><\/span><\/span><\/b><\/p>\n<p style=\"text-align:start;\"><b><span style=\"font-size:20px;\"><span style=\"color:#0079FE;\"><span style=\"font-size:16px;\">​<\/span><\/span><\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">秋雨丝丝洒枝头<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">烟缕织成愁<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">遥望落花满地残红<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">曾也枝头盈盈娉婷<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">装饰他人梦<\/span><\/b><\/p>\n<br>\n<p><b><span style=\"color:#009FB8;\"><span style=\"font-size:18px;\"><u>如今花落簌簌<\/u><\/span><\/span><\/b><\/p>\n<p><b><span style=\"color:#009FB8;\"><span style=\"font-size:18px;\"><u>曾绚烂完美刹那芳华<\/u><\/span><\/span><\/b><\/p>\n<br>\n<p><b><span style=\"font-size:16px;\">看那花瓣上的珍珠<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">不甚清风的摆动<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">悄然滑落<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">那不舍的是离愁<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\"><i>尘缘已过<\/i><\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\"><i>聚散匆匆<\/i><\/span><\/b><\/p>\n<br>\n<p><b><img src=\"https:\/\/file.dev.91xiangke.com\/user\/upload\/1e6b74c6d2a44b7582bb95f3b64e8ff2\/3348048b-c276-40f7-a98f-89cce95168c51532313469210-880x578.jpg\" \/><span style=\"font-size:18px;\"><span style=\"color:#009FB8;\"><\/span><\/span><\/b><\/p>\n<p style=\"text-align:start;\"><b><span style=\"font-size:18px;\"><span style=\"color:#009FB8;\">​<\/span><\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">不需忧伤<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">花儿<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">不会因为离枝而失去芬芳<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">草儿<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">不会因为寒冬而放下生的期望<\/span><\/b><\/p>\n<br>\n<p><b><span style=\"font-size:16px;\">今年花胜去年红<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">明年花更好<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">花开最美<\/span><\/b><\/p>\n<p><b><span style=\"font-size:16px;\">不负这红尘人间<\/span><\/b><\/p>\n<br>\n<p><b><img src=\"https:\/\/file.dev.91xiangke.com\/user\/upload\/1e6b74c6d2a44b7582bb95f3b64e8ff2\/80429d91-902a-403d-897c-500fb0028ab01532313480214-880x616.jpg\" \/><span style=\"font-size:18px;\"><span style=\"color:#009FB8;\"><\/span><\/span><\/b><\/p>\n<p style=\"text-align:start;\"><b><span style=\"font-size:18px;\"><span style=\"color:#009FB8;\">​<\/span><\/span><\/b><\/p>\n<br>\n<p><b><span style=\"font-size:16px;\">　　细数走过的岁月，欢乐伴着忧伤。在时光的深处中，最美的永远艳丽多彩不褪色，那些伤痛，时间久了也就模糊不清，留下的记忆也是残缺碎片。遇到不满意时，总会拿过去的好作比较，留恋过去，厌恶此刻，始不知过去也是此刻，此刻也会过去。行走红尘人间，做个随遇而安的草木女子，让清风拂袖，心香暖怀。生命的旅途，总会有千回百转满意时，总会拿过去的好作比较，留恋过去，厌恶此刻，始不知过去也是此刻，此刻也会过去。行走红尘人间，做个随遇而安的草木女子，让清风拂袖，心香暖怀。生命的旅途，总会有千回百转\357\274，悲喜寒凉，季节的辗转，绮丽的风景。若是懂得，这都是生活赋予的完美。有些人，有些事，也许进了你的眼，滑过你的心，又悄然的溜走了，也许只为相遇，留一道风景。把路途的美景丰盈心灵，化一道属于自己的风情。<\/span><\/b><\/p>\n";
}


@end
