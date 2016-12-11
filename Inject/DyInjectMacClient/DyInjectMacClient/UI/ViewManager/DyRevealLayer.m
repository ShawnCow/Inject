//
//  DyRevealLayer.m
//  DyViewManager
//
//  Created by Shawn on 2016/12/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyRevealLayer.h"
#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#ifndef DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(d) ((d) * M_PI / 180)
#endif

@interface DyRevealLayer ()<CAAnimationDelegate>
{
    NSMutableArray * __subLayers;
    NSMutableArray * __rootLayers;
    float rotateX;
    float rotateY;
    float dist;
    float oldDist;
    BOOL isAnimatimg;
}

@property (nonatomic, readonly) BOOL coordinateFromLeftTop;//ios YES mac os NO

@property (nonatomic) CGColorRef layerBgColor;

@end

@implementation DyRevealLayer

- (instancetype)initWithViewInfoArray:(NSArray *)infoArray
{
    self = [super init];
    if (self) {
        
        NSLog(@"info %@",infoArray);
        
        __subLayers = [NSMutableArray array];
        __rootLayers = [NSMutableArray array];
        
#if TARGET_OS_IPHONE
        _coordinateFromLeftTop = YES;
        _layerBgColor =CGColorRetain([UIColor colorWithRed:1. green:1. blue:1. alpha:0.5].CGColor);
#else
        _coordinateFromLeftTop = NO;
        _layerBgColor = CGColorCreateGenericRGB(1., 1., 1., 0.5);
        
#endif
        
        self.viewInfoArray = infoArray;
    }
    return self;
}

- (void)dealloc
{
    if (_layerBgColor) {
        CGColorRelease(_layerBgColor);
        _layerBgColor = nil;
    }
}

- (instancetype)init
{
    return [self initWithViewInfoArray:nil];
}


- (void)setViewInfoArray:(NSArray *)viewInfoArray
{
    if ([_viewInfoArray isEqualToArray:viewInfoArray]) {
        return;
    }
    _viewInfoArray = [viewInfoArray copy];
    
    for (CALayer * removeLayer in __subLayers) {
        [removeLayer removeFromSuperlayer];
    }
    [__subLayers removeAllObjects];
    [__rootLayers removeAllObjects];
    
    for (int i = 0; i < _viewInfoArray.count; i ++) {
        CALayer * rootLayer = [self _addLayerWithViewInfoDic:_viewInfoArray[i] deep:i * 5 contentLayer:self];
        [__rootLayers addObject:rootLayer];
    }
    [self _reloadAllLayerSublayers];
}

- (CGRect)__frameFromFrame:(CGRect)frame
{
    if (_coordinateFromLeftTop) {
        return frame;
    }else
        return CGRectMake(frame.origin.x, self.bounds.size.height - frame.origin.y - frame.size.height, frame.size.width, frame.size.height);
}

- (CALayer *)_addLayerWithViewInfoDic:(NSDictionary *)infoDic deep:(float)deep contentLayer:(CALayer *)contentLayer
{
    DyDisplayLayer * layer = [DyDisplayLayer layer];
    
    NSString * frameString = infoDic[@"toWindowFrame"];
    CGRect frame = CGRectZero;
    
    NSArray * subTexts = [[[frameString substringWithRange:NSMakeRange(1, frameString.length - 2)] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    
    NSString * tempString = [subTexts firstObject];
    tempString = [tempString substringFromIndex:1];
    frame.origin.x = [tempString floatValue];
    
    tempString = [subTexts objectAtIndex:1];
    tempString = [tempString substringToIndex:tempString.length - 1];
    frame.origin.y = [tempString floatValue];
    
    tempString = [subTexts objectAtIndex:2];
    tempString = [tempString substringFromIndex:1];
    frame.size.width = [tempString floatValue];
    
    tempString = [subTexts objectAtIndex:3];
    tempString = [tempString substringToIndex:tempString.length - 1];
    frame.size.height= [tempString floatValue];
    
    layer.frame = [self __frameFromFrame:frame];
    layer.backgroundColor = self.layerBgColor;
    layer.deep = deep;

    NSMutableArray * displayInfos = [NSMutableArray array];
    [displayInfos addObject:infoDic[@"ClassName"]];
    [displayInfos addObject:infoDic[@"frame"]];
    NSString * viewController = infoDic[@"ViewController"];
    if (viewController) {
        [displayInfos addObject:[NSString stringWithFormat:@"%@",viewController]];
    }
    layer.name = [displayInfos componentsJoinedByString:@"\n"];
    
#if TARGET_OS_IPHONE
    
#else
    layer.autoresizingMask = kCALayerNotSizable;
#endif
    [self addSublayer:layer];
    [__subLayers addObject:layer];
    
    NSArray * subViews = infoDic[@"subview"];
    for (int i = 0; i < subViews.count; i ++) {
        NSDictionary * tempSubviewInfoDic = subViews[i];
        [self _addLayerWithViewInfoDic:tempSubviewInfoDic deep:(deep + 1 + (float)i/(float)10) contentLayer:layer];
    }
    
    return layer;
}

- (void)anime:(float)time {
    
    CATransform3D trans = CATransform3DIdentity;
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -0.001;
    trans = CATransform3DMakeTranslation(0, 0, dist * 1000);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(rotateX), 1, 0, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(rotateY), 0, 1, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(0), 0, 0, 1), trans);
    trans = CATransform3DConcat(trans, t);
    
    isAnimatimg = YES;
    
    CATransition * transition = [CATransition animation];
    transition.delegate = self;
    
    for (CALayer * tempLayer in __subLayers) {
        tempLayer.transform = trans;
        [tempLayer addAnimation:transition forKey:@"transition"];
    }
}

- (void)setRevealScale:(float)revealScale
{
    _revealScale = revealScale;
    dist = _revealScale;
    dist = dist < -5 ? -5 : dist > 0.5 ? 0.5 : dist;
    [self anime:0.1];
}

- (void)setDisplayLocation:(CGPoint)displayLocation
{
    _displayLocation = displayLocation;
    rotateY = _displayLocation.x;
    rotateX = _displayLocation.y;
    [self anime:0.1];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    isAnimatimg = NO;
}


#pragma mark - 

- (void)_reloadAllLayerSublayers
{
    for (DyDisplayLayer * tempLayer in __subLayers) {
        CGRect scr = tempLayer.superlayer.bounds;
        tempLayer.anchorPoint = CGPointMake((scr.size.width / 2 - tempLayer.frame.origin.x) / tempLayer.frame.size.width,
                                             (scr.size.height / 2 - tempLayer.frame.origin.y) / tempLayer.frame.size.height);
        tempLayer.anchorPointZ = (-tempLayer.deep + 3) * 50;
    }
    [self anime:0.1];
}

@end

@implementation DyDisplayLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opacity = 0.9;
        self.textLayer = [CATextLayer layer];
        [self addSublayer:self.textLayer];
#if TARGET_OS_IPHONE
        self.textLayer.foregroundColor = [UIColor blackColor].CGColor;
#else
        self.textLayer.foregroundColor = CGColorGetConstantColor(kCGColorBlack);
#endif
        self.textLayer.wrapped = YES;
        self.textLayer.fontSize = 14;
        self.textLayer.frame = self.bounds;
    }
    return self;
}

- (void)setName:(NSString *)name
{
    self.textLayer.string = name;
}
- (void)layoutSublayers
{
    [super layoutSublayers];
    self.textLayer.frame = self.bounds;
}
@end
