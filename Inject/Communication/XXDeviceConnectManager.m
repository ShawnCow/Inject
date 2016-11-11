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
#import "XXPacket.h"

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
    
    BOOL isSendingData;
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

- (void)resetCurrentPacket
{
    dispatch_async(sendPacketQueue, ^{
        if (currentHandlePacket) {
            [currentHandlePacket reset];
        }
    });
}

- (void)checkAndSchedulePacketSend
{
    dispatch_async(sendPacketQueue, ^{
        
        if (self.connectionTcpSocket && self.connectionTcpSocket.isConnected && isSendingData == NO) {
            
            if (!currentHandlePacket && packetQueue.count > 0) {
                currentHandlePacket = [packetQueue firstObject];
                [packetQueue removeObjectAtIndex:0];
            }
            
            if (currentHandlePacket) {
                @autoreleasepool {
                    
                    NSMutableData * allData = [NSMutableData data];
                    
                    NSData * data = nil;
                    NSDictionary * infoDic = nil;
                    BOOL didReadToEnd = [currentHandlePacket packetReadBuffer:&data bufferInfo:&infoDic];

                    XXPacket * packet = [[XXPacket alloc]initWithAction:[currentHandlePacket packetAction] infoDic:infoDic packetData:data];
                    NSData * encodeData = nil;
                    
                    @try {
                        encodeData = [NSKeyedArchiver archivedDataWithRootObject:packet];
                    } @catch (NSException *exception) {
                        // cover data failed
                        NSString * msg = exception.reason;
                        XXInfoPacket * exceptionInfoPacket = [[XXInfoPacket alloc]initWithInfo:[NSString stringWithFormat:@"conver json data failed . Packet:%@ , reason:%@",currentHandlePacket, msg] module:@"XXDeviceConnectManager"];
                        [self inQueueWithPacket:exceptionInfoPacket];
                        
                    } @finally {
                        
                    }
                    
                    long dataLenght = encodeData.length;
                    if (dataLenght > 0) {
                        [allData appendData: [NSData dataWithBytes:&dataLenght length:8]];
                        [allData appendData:encodeData];
                    }
                    if (didReadToEnd)
                    {
                        currentHandlePacket = nil;
                        NSLog(@"is read to end");
                    }else
                    {
                    }
                    
                    if (allData.length > 0) {
                        isSendingData = YES;
                        sendDataTag ++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.connectionTcpSocket writeData:allData withTimeout:-1 tag:sendDataTag];
                        });
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
        
        while ([self __parser]) {
            
        }
    });
}

- (BOOL)__parser
{
    if (receiverData.length > 8) {
        long dataLenght = 0;
        [receiverData getBytes:&dataLenght length:8];
        if (dataLenght > 0) {
            NSUInteger subDataLenght = 8 + dataLenght;
            if (receiverData.length >= subDataLenght) {
                NSData * parserData = [receiverData subdataWithRange:NSMakeRange(8, dataLenght)];
                [receiverData setData:[receiverData subdataWithRange:NSMakeRange(subDataLenght, receiverData.length - subDataLenght)]];
                if (parserData) {
                    XXPacket * packet = nil;
                    @try {
                        packet = [NSKeyedUnarchiver unarchiveObjectWithData:parserData];
                        
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                   
                    if (packet) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManager:didReceivePacket:)]) {
                                [self.delegate deviceConnectManager:self didReceivePacket:packet];
                            }
                        });
                    }
                    //                        }
                }
                
                return YES;
            }
        }
    }
    
    return NO;
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
    
    NSLog(@"function %s",__FUNCTION__);
    _connectedHost = nil;
    
    if (sock == self.connectionTcpSocket) {
        
        [self clearReceiveData];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManagerDidDisconnect:)]) {
            [self.delegate deviceConnectManagerDidDisconnect:self];
        }
    }
    [self resetCurrentPacket];
}

- (void)onSocket:(XXAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"function %s",__FUNCTION__);
    _connectedHost = [host copy];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConnectManager:didConnectToHost:)]) {
        [self.delegate deviceConnectManager:self didConnectToHost:_connectedHost];
    }
    [sock readDataWithTimeout:-1 tag:0];
    isSendingData = NO;
    [self checkAndSchedulePacketSend];
}

- (void)onSocket:(XXAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"function %s",__FUNCTION__);
    [sock readDataWithTimeout:-1 tag:0];
    if (sock == self.connectionTcpSocket) {
        [self inReceiveDataQueueWithData:data];
    }
}

- (void)onSocket:(XXAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"function %s",__FUNCTION__);
    [sock readDataWithTimeout:-1 tag:0];
    isSendingData = NO;
    [self checkAndSchedulePacketSend];
}

@end
