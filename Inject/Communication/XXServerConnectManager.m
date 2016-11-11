//
//  XXServerConnectManager.m
//  Communication
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXServerConnectManager.h"
#import "XXFindDevice.h"
#import "XXAsyncSocket.h"

#define XXServerConnectManagerPort                    7779

@interface XXDeviceConnectManager (Private)

@property (nonatomic, strong) XXAsyncSocket * connectionTcpSocket;

@end

@interface XXServerConnectManager ()
{
    XXFindDevice * theFindDevice;
    XXAsyncSocket * bindSocket;
}
@end

@implementation XXServerConnectManager

@synthesize key = _key;

+ (instancetype)currentServerConnectManager
{
    static XXServerConnectManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XXServerConnectManager alloc]init];
    });
    return manager;
}

- (BOOL)startWithKey:(NSString *)key
{
    if (theFindDevice || self.connectionTcpSocket) {
        return NO;
    }
    if ([self __openAcceptSocket] == NO) {
        return NO;
    }
    _key = [key copy];
    
    [self __stopBind];
    [self __startBind];
    return YES;
}

- (void)disconnect
{
    [self __closeAcceptSocket];
    [self __stopBind];
    [super disconnect];
}

#pragma mark -

- (BOOL)__openAcceptSocket
{
    bindSocket = [[XXAsyncSocket alloc]initWithDelegate:self];
    if(![bindSocket acceptOnPort:XXServerConnectManagerPort error:nil])
    {
        [bindSocket disconnect];
        bindSocket = nil;
        return NO;
    }
    return YES;
}

- (void)__closeAcceptSocket
{
    bindSocket.delegate = nil;
    [bindSocket disconnect];
    bindSocket = nil;
}

- (BOOL)__startBind
{
    theFindDevice = [[XXFindDevice alloc]initWithKey:_key];
    return [theFindDevice startBind];
}

- (void)__stopBind
{
    [theFindDevice stop];
    theFindDevice = nil;
}

#pragma mark - 

- (void)onSocket:(XXAsyncSocket *)sock didAcceptNewSocket:(XXAsyncSocket *)newSocket
{
    // 可以Server端 可以不用关闭监听端口 可以监听多个 app 但是这边测试先暂时关闭
    [self __closeAcceptSocket];
    
    self.connectionTcpSocket = newSocket;
    newSocket.delegate = self;
    [self.connectionTcpSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocketDidDisconnect:(XXAsyncSocket *)sock
{
    [super onSocketDidDisconnect:sock];
    [self disconnect];
    [self startWithKey:_key];
}

@end
