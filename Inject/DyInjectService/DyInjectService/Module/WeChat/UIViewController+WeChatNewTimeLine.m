//
//  UIViewController+WeChatNewTimeLine.m
//  DyInjectService
//
//  Created by Shawn on 2016/11/17.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "UIViewController+WeChatNewTimeLine.h"
#import "NSObject+__DyInjectSwizzle.h"

@interface NSObject (WCNewCommitViewControllerView)

//MMGrowTextView
- (void)postTextChangeNotification;

//WCNewCommitViewController
- (id)initWithImages:(id)arg1 contacts:(id)arg2;

//SightMomentEditViewController
- (void)popSelf;
@property (nonatomic, strong) NSString * realMoviePath;
@property (nonatomic, strong) NSString * moviePath;
@property (nonatomic, strong) UIImage * thumbImage;
@property (nonatomic, strong) UIImage * realThumbImage;

@end

@implementation UIViewController (WeChatNewTimeLine)

static NSString * theNewTimeLineWillDisplayText = nil;

+ (void)load
{
    Class vcClass = NSClassFromString(@"WCNewCommitViewController");
    if (vcClass) {
        [vcClass ___exchangeMethod:@selector(viewDidAppear:) withMethod:@selector(dyViewDidAppear:)];
    }
    Class videoClass = NSClassFromString(@"SightMomentEditViewController");
    if (videoClass) {
        [videoClass ___exchangeMethod:@selector(viewDidAppear:) withMethod:@selector(dyViewDidAppear:)];
        [videoClass ___exchangeMethod:@selector(popSelf) withMethod:@selector(___dyBack)];
    }
}

+ (void)dyShowNewTimeLineWithImages:(NSArray *)images text:(NSString *)text fromVc:(UIViewController *)fromVc
{
    theNewTimeLineWillDisplayText = text;
    UIViewController * vc = [[NSClassFromString(@"WCNewCommitViewController") alloc]initWithImages:images contacts:nil];
    UINavigationController * nai = [[NSClassFromString(@"MMUINavigationController") alloc]initWithRootViewController:vc];
    [fromVc presentViewController:nai animated:YES completion:nil];
}

+ (void)dyShowNewVideoWithPath:(NSString *)path thumbImage:(UIImage *)thumbImage fromVc:(UIViewController *)fromVc
{
    UIViewController * vc = [[NSClassFromString(@"SightMomentEditViewController") alloc]init];
    vc.realMoviePath = path;
    vc.moviePath = path;
    vc.thumbImage = thumbImage;
    vc.realThumbImage = thumbImage;
    [fromVc presentViewController:vc animated:YES completion:nil];
}

+ (void)dyShowNewVideoWithPath:(NSString *)path thumbImage:(UIImage *)thumbImage text:(NSString *)text fromVc:(UIViewController *)fromVc
{
    theNewTimeLineWillDisplayText = text;
    [self dyShowNewVideoWithPath:path thumbImage:thumbImage fromVc:fromVc];
}

- (void)dyViewDidAppear:(BOOL)animated
{
    [self dyViewDidAppear:animated];
    [self __dyViewDidAppearCompletion];
}

- (void)__dyViewDidAppearCompletion
{
    NSLog(@"__dyViewDidAppearCompletion %@",theNewTimeLineWillDisplayText);
        
    if ([theNewTimeLineWillDisplayText isKindOfClass:[NSString class]]) {
        UIView * growView = [self valueForKey:@"_textView"];
        if ([growView isKindOfClass:NSClassFromString(@"MMGrowTextView")]) {
            UITextView * textView = [growView valueForKey:@"_textView"];
            if ([textView isKindOfClass:[UITextView class]]) {
                textView.text = theNewTimeLineWillDisplayText;
                theNewTimeLineWillDisplayText = nil;
                if ([growView respondsToSelector:@selector(postTextChangeNotification)]) {
                    [growView postTextChangeNotification];
                }
            }
        }
    }
}

- (void)___dyBack
{
    [self ___dyBack];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
