//
//  XXDyJsBridgeView.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXDyJsBridgeView.h"
#import <View+MASAdditions.h>
#import "__XXDyInjectRouter.h"
#import "XXPacketProtocol.h"
#import "XXServerConnectManager.h"
#import "XXPacket.h"

@interface XXDyJsBridgeView ()

@property (nonatomic, unsafe_unretained)IBOutlet NSTextView * jsTextView;
@property (nonatomic, unsafe_unretained)IBOutlet NSTextView * resultTextView;
@property (nonatomic, weak)IBOutlet NSButton * exeBtn;

@end

@implementation XXDyJsBridgeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.exeBtn.target = self;
    self.exeBtn.action = @selector(_exeBtnAction);
    __weak XXDyJsBridgeView * ws = self;
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"jsbridge" completion:^id(id<XXPacketProtocol> packet) {
        
        [ws handlePacket:packet];
        return nil;
    }];
}

- (void)dealloc
{
    [[__XXDyInjectRouter shareDyInjectRouter]unresiterRouterWithKey:@"jsbridge"];
}

- (IBAction)_exeBtnAction
{
    NSString * js = self.jsTextView.string;
    if (js.length == 0) {
        NSAlert * alert = [[NSAlert alloc]init];
        alert.messageText = @"js 内容不能为空";
        [alert runModal];
        return;
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"js"] = js;
    XXPacket * p = [[XXPacket alloc]initWithAction:@"jsbridge" infoDic:dic packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:p];
}

- (void)handlePacket:(id<XXPacketProtocol>)packet
{
    NSDictionary * dic = [packet packetDictionary];
    NSString * info = [NSString stringWithFormat:@"%@",dic];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (info) {
            [self.resultTextView insertText:info replacementRange:NSMakeRange(0, 0)];
        }
        [self.resultTextView setFrameOrigin:CGPointMake(0, 0)];
    });
}

- (void)scrollToBottom
{

}

@end
