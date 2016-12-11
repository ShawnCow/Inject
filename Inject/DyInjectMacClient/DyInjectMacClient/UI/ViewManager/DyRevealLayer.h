//
//  DyRevealLayer.h
//  DyViewManager
//
//  Created by Shawn on 2016/12/6.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface DyRevealLayer : CALayer

- (instancetype)initWithViewInfoArray:(NSArray *)infoArray;

@property (nonatomic, copy) NSArray * viewInfoArray;

@property (nonatomic) float revealScale;

@property (nonatomic) CGPoint displayLocation;

@end

@interface DyDisplayLayer : CALayer

@property (retain) CATextLayer * textLayer;

@property (nonatomic)float deep;

@property (nonatomic) CGRect viewFrame;

@end
