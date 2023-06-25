//
//  SIXEditorToolBar.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorToolBar.h"

@interface SIXEditorToolBar ()
{
    CGFloat _itemWidth;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIButton *> *actionCache;
@property (nonatomic, strong) void (^toolButtonTapped) (SIXEditorAction, BOOL);

@end

@implementation SIXEditorToolBar

- (instancetype)initWithActions:(NSArray *)actions toolButtonTapped:(void (^)(SIXEditorAction, BOOL))tapped {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, screenW, Editor_ToolBar_Height)];
    if (self) {
        _itemWidth = screenW / 7.0;
        _actionCache = [NSMutableDictionary dictionary];
        _actions = actions;
        _toolButtonTapped = tapped;
        [self setupUI];
        [self createActions];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-_itemWidth, self.frame.size.height)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [scrollView addSubview:stackView];
    _stackView = stackView;
    
    UIButton *keyboardButton = [self itemButton:SIXEditorActionKeyboard];
    keyboardButton.frame = CGRectMake(CGRectGetMaxX(scrollView.frame), 0, _itemWidth, self.frame.size.height);
    [self addSubview:keyboardButton];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = [UIColor lightGrayColor].CGColor;
    line.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
    [self.layer addSublayer:line];
}

- (void)createActions {
    for (UIView *view in self.actionCache.allValues) {
        [_stackView removeArrangedSubview:view];
    }
    [self.actionCache removeAllObjects];
    
    for (int i = 0; i < _actions.count; i++) {
        UIButton *itemButton = [self itemButton:[_actions[i] integerValue]];
        [self.actionCache setObject:itemButton forKey:_actions[i]];
        [_stackView addArrangedSubview:itemButton];
    }

    _scrollView.contentSize = CGSizeMake(_itemWidth * _actions.count , self.frame.size.height);
    _stackView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
}

- (UIButton *)itemButton:(SIXEditorAction)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(onToolButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SIXEditor" ofType:@"bundle"]];
    
    NSString *imageName = [self itemImageName:action];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    [button setImage:image forState:(UIControlStateNormal)];
    
    imageName = [imageName stringByAppendingString:@"_select"];
    image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    [button setImage:image forState:(UIControlStateSelected)];
    button.tag = action;
    return button;
}

- (void)onToolButtonTapped:(UIButton *)button {
    button.selected = !button.isSelected;
    SIXEditorAction action = button.tag;
    UIButton *colorButton = self.actionCache[@(SIXEditorActionTextColor)];
    UIButton *fontButton = self.actionCache[@(SIXEditorActionFontSize)];
    switch (action) {
        case SIXEditorActionFontSize:
            colorButton.selected = NO;
            break;
        case SIXEditorActionTextColor:
            fontButton.selected = NO;
            break;
        case SIXEditorActionImage:
        case SIXEditorActionKeyboard:
            button.selected = NO;
        default: {
            colorButton.selected = NO;
            fontButton.selected = NO;
        }
            break;
    }
    self.toolButtonTapped(action, button.isSelected);
}

- (NSString *)itemImageName:(SIXEditorAction)action {
    switch (action) {
        case SIXEditorActionBold:
            return @"Editor_bold";
        case SIXEditorActionItatic:
            return @"Editor_itatic";
        case SIXEditorActionUnderline:
            return @"Editor_underline";
        case SIXEditorActionFontSize:
            return @"Editor_fontSize";
        case SIXEditorActionTextColor:
            return @"Editor_textColor";
        case SIXEditorActionImage:
            return @"Editor_image";
        case SIXEditorActionKeyboard:
            return @"Editor_keyboard";
            
        default:
            return nil;
    }
}

- (void)updateWithItatic:(BOOL)isItatic isUnderline:(BOOL)isUnderline isBold:(BOOL)isBold {
    _actionCache[@(SIXEditorActionBold)].selected = isBold;
    _actionCache[@(SIXEditorActionItatic)].selected = isItatic;
    _actionCache[@(SIXEditorActionUnderline)].selected = isUnderline;
}

- (void)resetButton:(SIXEditorAction)action {
    _actionCache[@(action)].selected = NO;
}

@end
