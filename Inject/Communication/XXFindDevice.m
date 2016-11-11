//
//  XXFindDevice.m
//  XXRequestMonitor
//
//  Created by Shawn on 15/4/20.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXFindDevice.h"
#include <arpa/inet.h>

@interface XXFindDevice ()<NSNetServiceDelegate,NSNetServiceBrowserDelegate>
{
    NSMutableArray * _services;
    NSNetService * _netService;
    NSNetServiceBrowser * _netServiceBrowser;
}
@end

@implementation XXFindDevice

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = [key copy];
    }
    return self;
}

- (BOOL)startBind
{
    if (self.status != XXFindDeviceStatusNone) {
        return NO;
    }
    
    _netService = [[NSNetService alloc]initWithDomain:@"local." type:@"_marco._tcp" name:@"" port:7777];
    NSString * tempKey = self.key;
    if (tempKey == nil) {
        tempKey = @"";
    }
    NSDictionary * dic = [NSDictionary dictionaryWithObject:[tempKey dataUsingEncoding:NSUTF8StringEncoding] forKey:@"key"];
    NSData * txtData = [NSNetService dataFromTXTRecordDictionary:dic];
    [_netService setTXTRecordData:txtData];
    [_netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_netService publish];
    _status = XXFindDeviceStatusBinding;
    return YES;
}

- (BOOL)startFind
{
    if (self.status != XXFindDeviceStatusNone) {
        return NO;
    }
    _services = [NSMutableArray array];
    _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _netServiceBrowser.delegate = self;
    [_netServiceBrowser searchForServicesOfType:@"_marco._tcp" inDomain:@"local."];
    
    if (_netServiceBrowser) {
         _status = XXFindDeviceStatusFinding;
        return YES;
    }else
    {
        NSLog(@"create brower failed");
        return NO;
    }
}

- (void)stop
{
    [_netService stop];
    _netService = nil;
    [_netServiceBrowser stop];
    _netServiceBrowser = nil;
    [_services removeAllObjects];
    _services = nil;
    _status = XXFindDeviceStatusNone;
}

- (void)dealloc
{
    [self stop];
}

#pragma mark - NetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    [_services removeObject:sender];
    NSData *address = [sender.addresses firstObject];
    if (address == nil) {
        return;
    }
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
    NSDictionary * dic = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
    NSData * data = dic[@"key"];
    NSString * tempString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if ([self.key isEqualToString:tempString]) {
        NSString * host = [NSString stringWithFormat:@"%s",inet_ntoa(socketAddress->sin_addr)];
        if (self.delegate && [self.delegate respondsToSelector:@selector(findDevice:didFindHost:)]) {
            [self.delegate findDevice:self didFindHost:host];
        }
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    [_services removeObject:sender];
}

#pragma mark - NetServiceBrower

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
    [_services addObject:netService];
    netService.delegate  = self;
    [netService resolveWithTimeout:5];
}

@end
