//
//  DyRevealView.m
//  DyViewManager
//
//  Created by Shawn on 2016/12/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyRevealView.h"
#import "DyRevealLayer.h"

@interface DyRevealView ()
{
    CGPoint oldPan;
    float oldDist;
    BOOL isMouseDown;
}
@end

@implementation DyRevealView

#if TARGET_OS_IPHONE

+ (Class)layerClass
{
    return [DyRevealLayer class];
}

#endif

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self __setDefaultRevealView];
    }
    return self;
}
#if TARGET_OS_IPHONE
- (instancetype)initWithFrame:(CGRect)frameRect
#else
- (instancetype)initWithFrame:(NSRect)frameRect
#endif
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self __setDefaultRevealView];
    }
    return self;
}

- (void)__setDefaultRevealView
{
#if TARGET_OS_IPHONE
    UIPanGestureRecognizer * panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGes];
    
    UIPinchGestureRecognizer * pinGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinGes];
#else
    self.layer = [[DyRevealLayer alloc]init];
    
    NSPanGestureRecognizer * panGes = [[NSPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGes];
    
    NSMagnificationGestureRecognizer * pinGes = [[NSMagnificationGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinGes];
#endif
}

#if TARGET_OS_IPHONE
- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
#else
- (void)pan:(NSPanGestureRecognizer *)gestureRecognizer {
#endif
    DyRevealLayer * layer = (DyRevealLayer *)self.layer;
    
#if TARGET_OS_IPHONE
    
    CGPoint change;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
#else
        NSPoint change ;
    if (gestureRecognizer.state == NSGestureRecognizerStateBegan) {
#endif
        oldPan = layer.displayLocation;
    }
    change = [gestureRecognizer translationInView:self];
    CGPoint nPoint = CGPointZero;
    nPoint.x =  oldPan.x + change.x;
    nPoint.y = -oldPan.y - change.y;
    layer.displayLocation = nPoint;
}
#if TARGET_OS_IPHONE
- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer {
#else
- (void)pinch:(NSMagnificationGestureRecognizer *)gestureRecognizer {
#endif
    DyRevealLayer * layer = (DyRevealLayer *)self.layer;
    float offset = 0;
#if TARGET_OS_IPHONE
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        offset = gestureRecognizer.scale - 1;
#else
    if (gestureRecognizer.state == NSGestureRecognizerStateBegan) {
        offset = gestureRecognizer.magnification;
#endif
        oldDist = layer.revealScale;
    }
    float dist = oldDist + offset;
    dist = dist < -5 ? -5 : dist > 0.5 ? 0.5 : dist;
    layer.revealScale = dist;
}


- (void)setViewInfoDictionarys:(NSArray *)viewInfoDictionarys
{
    [(DyRevealLayer *)self.layer setViewInfoArray:viewInfoDictionarys];
}

- (NSArray *)viewInfoDictionarys
{
    return [(DyRevealLayer *)self.layer viewInfoArray];
}
@end
