//
//  XXDeviceConnectManager.m
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXDeviceConnectManager.h"
#import "XXFindDevice.h"
#import "XXAsyncSocket.h"
#import "XXInfoPacket.h"

@interface XXDeviceConnectManager ()<XXFindDeviceDelegate>
{
    dispatch_queue_t sendPacketQueue;
    NSMutableArray * packetQueue;
    
    dispatch_queue_t receivePacketQueue;
    NSMutableData * receiverData;
    
    id<XXPacketProtocol> currentHandlePacket;
    
    long long sendDataTag;
    
    NSString * generalPacketClass;
    NSMutableDictionary * packetClassDictionary;
}

@property (nonatomic, strong) XXAsyncSocket * connectionTcpSocket;

@end

@implementation XXDeviceConnectManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString * queueName = [NSString stringWithFormat:@"com.shawn.communication.sendpacket.%p",self];
        sendPacketQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        packetQueue = [NSMutableArray array];
        
        queueName = [NSString stringWithFormat:@"com.shawn.communication.receivepacket.%p",self];
        receivePacketQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        receiverData = [NSMutableData data];
        
        generalPacketClass = @"XXPacket";
        packetClassDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)startWithKey:(NSString *)key
{
    return NO;
}

- (void)disconnect
{
    self.connectionTcpSocket.delegate = nil;
    [self.connectionTcpSocket disconnect];
    self.connectionTcpSocket = nil;
}

#pragma mark - 

- (void)registerPacketClass:(Class)packetClass action:(NSString *)action
{
    if (action) {
        @synchronized (packetClassDictionary) {
            if (packetClass) {
                packetClassDictionary[action] = NSStringFromClass(packetClass);
            }else
                [packetClassDictionary removeObjectForKey:action];
        }
    }else
    {
        if (packetClass) {
            generalPacketClass = NSStringFromClass(packetClass);
        }else
            generalPacketClass = @"XXPacket";
    }
}

- (void)removePacketClassForAction:(NSString *)action
{
    if (action) {
        @synchronized (packetClassDictionary) {
            [packetClassDictionary removeObjectForKey:action];
        }
    }else
        generalPacketClass = @"XXPacket";
}

- (Class)packetClassForAction:(NSString *)action
{
    NSString * packetClass = nil;
    if (action) {
        @synchronized (packetClassDictionary) {
            packetClass = packetClassDictionary[@"action"];
        }
    }else
        packetClass = generalPacketClass;
    
    if (packetClass) {
        return NSClassFromString(packetClass);
    }else
        return nil;
}

#pragma mark - data handle

- (void)inQueueWithPacket:(id<XXPacketProtocol>)packet
{
    if (!packet) {
        return;
    }
    dispatch_async(sendPacketQueue, ^{
        [packetQueue addObject:packet];
        if (packetQueue.count > 100) {//超过100 个 丢弃掉旧的
            [packetQueue removeObjectAtIndex:0];
        }
    });
    
    [self checkAndSchedulePacketSend];
}

- (void)checkAndSchedulePacketSend
{
    dispatch_async(sendPacketQueue, ^{
        
        if (self.connectionTcpSocket && self.connectionTcpSocket.isConnected) {
            
            if (!currentHandlePacket && packetQueue.count > 0) {
                currentHandlePacket = [packetQueue firstObject];
                [packetQueue removeObjectAtIndex:0];
            }
            
            if (currentHandlePacket) {
                @autoreleasepool {
                    NSData * data = nil;
                    NSDictionary * infoDic = nil;
                    if ([currentHandlePacket packetReadBuffer:&data bufferInfo:&infoDic]) {
                        currentHandlePacket = nil;
                    }
                    NSMutableDictionary * sendDic = [NSMutableDictionary dictionary];
                    sendDic[@"action"] = [currentHandlePacket packetAction];
                    if (infoDic) {
                        sendDic[@"info"] = [infoDic copy];
                    }
                    if (data) {
                        sendDic[@"data"] = data;
                    }
                    NSMutableData * allData = [NSMutableData data];
                    NSData * jsonData = nil;
                    
                    @try {
                        jsonData = [NSJSONSerialization dataWithJSONObject:sendDic options:NSJSONWritingPrettyPrinted error:nil];
                    } @catch (NSException *exception) {
                        // cover data failed
                        NSString * msg = exception.reason;
                        XXInfoPacket * exceptionInfoPacket = [[XXInfoPacket alloc]initWithInfo:[NSString stringWithFormat:@"conver json data failed . Packet:%@ , reason:%@",currentHandlePacket, msg]];
                        [self inQueueWithPacket:exceptionInfoPacket];
                        
                    } @finally {
                        
                    }
                    
                    NSUInteger dataLenght = jsonData.length;
                    if (dataLenght > 0) {
                        [allData appendData: [NSData dataWithBytes:&dataLenght length:10]];
                        [allData appendData:jsonData];
                    }
                    if (allData.length > 0) {
                        sendDataTag ++;
                        [self.connectionTcpSocket writeData:allData withTimeout:-1 tag:sendDataTag];
                    }
                }
            }
        }
    });
}

- (void)inReceiveDataQueueWithData:(NSData *)data
{
    dispatch_async(receivePacketQueue, ^{
        [receiverData appendData:data];
        
        if (receiverData.length > 10) {
            NSUInteger dataLenght = 0;
            [receiverData getBytes:&dataLenght length:sizeof(NSUInteger)];
            if (dataLenght > 0) {
                NSUInteger subDataLenght = 10 + dataLenght;
                if (receiverData.length >= subDataLenght) {
                    NSData * parserData = [receiverData subdataWithRange:NSMakeRange(10, dataLenght)];
                    [receiverData setData:[receiverData subdataWithRange:NSMakeRange(subDataLenght, receiverData.length - subDataLenght)]];
                    if (parserData) {
                        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:parserData options:NSJSONReadingMutableContainers error:nil];
                        NSString * action = dic[@"action"];
                        NSString * packetClassString = nil;
                        if (action) {
                            packetClassString = packetClassDictionary[action];
                        }
                        if (!packetClassString) {
                            packetClassString = generalPacketClass;
                        }
                        if (packetClassString) {
                            id packet = [[NSClassFromString(packetClassString) alloc]initWithAction:action infoDic:dic[@"info"] packetData:dic[@"data"]];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManager:didReceivePacket:)]) {
                                    [self.delegate deviceConnectManager:self didReceivePacket:packet];
                                }
                            });
                        }
                    }
                }
            }
        }
    });
}

- (void)clearReceiveData
{
    dispatch_async(receivePacketQueue, ^{
        [receiverData setLength:0];
    });
}

#pragma mark -

- (void)onSocketDidDisconnect:(XXAsyncSocket *)sock
{
    _connectedHost = nil;
    
    if (sock == self.connectionTcpSocket) {
        
        [self clearReceiveData];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManagerDidDisconnect:)]) {
            [self.delegate deviceConnectManagerDidDisconnect:self];
        }
    }
}

- (void)onSocket:(XXAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    _connectedHost = [host copy];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManager:didConnectToHost:)]) {
        [self.delegate deviceConnectManager:self didConnectToHost:_connectedHost];
    }
}

- (void)onSocket:(XXAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
    if (sock == self.connectionTcpSocket) {
        [self inReceiveDataQueueWithData:data];
    }
}

- (void)onSocket:(XXAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
}

@end
