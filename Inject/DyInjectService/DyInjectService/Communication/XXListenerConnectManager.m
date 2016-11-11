//
//  XXListenerConnectManager.m
//  Communication
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXListenerConnectManager.h"
#import "XXFindDevice.h"
#import "XXAsyncSocket.h"


#define XXListenerConnectManagerPort                    7779

@interface XXDeviceConnectManager (Private)

@property (nonatomic, strong) XXAsyncSocket * connectionTcpSocket;

@end

@interface XXListenerConnectManager ()<XXFindDeviceDelegate>
{
    XXFindDevice * theFindDevice;
}

@end

@implementation XXListenerConnectManager

@synthesize key = _key;

+ (instancetype)currentListenerConnectManager
{
    static XXListenerConnectManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XXListenerConnectManager alloc]init];
    });
    return manager;
}

- (BOOL)startWithKey:(NSString *)key
{
    if (theFindDevice || self.connectionTcpSocket) {
        return NO;
    }
    _key = [key copy];
    [self __stopBind];
    [self __startBind];
    return YES;
}

- (void)disconnect
{
    [self __stopBind];
    [super disconnect];
}

#pragma mark - 

- (BOOL)__startBind
{
    theFindDevice = [[XXFindDevice alloc]initWithKey:_key];
    theFindDevice.delegate = self;
    return [theFindDevice startFind];
}

- (void)__stopBind
{
    [theFindDevice stop];
    theFindDevice = nil;
}

- (void)__connectToHost:(NSString *)host
{
    [self disconnect];
    XXAsyncSocket * socket = [[XXAsyncSocket alloc]initWithDelegate:self];
    BOOL result = [socket connectToHost:host onPort:XXListenerConnectManagerPort error:nil];
    if (result) {
        self.connectionTcpSocket = socket;
    }else
    {
        [socket disconnect];
        socket = nil;
    }
}

#pragma mark -

- (void)onSocketDidDisconnect:(XXAsyncSocket *)sock
{
    [super onSocketDidDisconnect:sock];
    [self __startBind];
}

- (void)onSocket:(XXAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [super onSocket:sock didConnectToHost:host port:port];
    [self __stopBind];
}

#pragma mark - 

- (void)findDevice:(XXFindDevice *)findDevice didFindHost:(NSString *)host
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listenerConnectManager:didFindHost:)]) {
        [(id<XXListenerConnectManagerDelegate>)self.delegate listenerConnectManager:self didFindHost:host];
    }
    [self __connectToHost:host];
}

@end
