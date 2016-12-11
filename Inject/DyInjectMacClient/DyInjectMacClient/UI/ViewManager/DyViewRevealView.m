//
//  DyViewRevealView.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/12/12.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyViewRevealView.h"
#import "__XXDyInjectRouter.h"
#import <AppKit/AppKit.h>
#import "XXServerConnectManager.h"
#import "XXPacket.h"

@implementation DyViewRevealView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.layer.backgroundColor = [NSColor colorWithRed:1. green:1. blue:0. alpha:0.3].CGColor;
    
    __weak DyViewRevealView * ws = self;
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"viewmanager" completion:^id(id<XXPacketProtocol> packet) {
        
        NSDictionary * dic = [packet packetDictionary];
        if ([dic[@"type"] isEqualToString:@"callresult"]) {
            NSString * result  = dic[@"result"];
            NSData * jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            id ob = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            if ([ob isKindOfClass:[NSArray class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.contentView setViewInfoDictionarys:ob];
                });
            }
        }
        return nil;
    }];
}

-(IBAction)btnAction:(id)sender
{
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    tempDic[@"type"] = @"view";
    XXPacket * packet = [[XXPacket alloc]initWithAction:@"viewmanager" infoDic:tempDic packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:packet];
}

@end
