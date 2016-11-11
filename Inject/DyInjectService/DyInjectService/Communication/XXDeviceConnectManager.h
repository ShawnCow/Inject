//
//  XXDeviceConnectManager.h
//  Communication
//
//  Created by Shawn on 2016/11/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXPacketProtocol.h"

@class XXDeviceConnectManager;

@protocol XXDeviceConnectManagerDelegate <NSObject>

@optional

- (void)deviceConnectManager:(XXDeviceConnectManager *)deviceConnectionManager didReceivePacket:(id<XXPacketProtocol>)packet;

- (void)deviceConnectManagerDidDisconnect:(XXDeviceConnectManager *)deviceConnectionManager;

- (void)deviceConnectManager:(XXDeviceConnectManager *)deviceConnectionManager didConnectToHost:(NSString *)host;

@end

@interface XXDeviceConnectManager : NSObject

@property (nonatomic, weak) id <XXDeviceConnectManagerDelegate> delegate;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (BOOL)startWithKey:(NSString *)key;

@property (nonatomic, readonly, copy) NSString * key;

@property (nonatomic, readonly, copy) NSString * connectedHost;

- (void)disconnect;

- (void)inQueueWithPacket:(id<XXPacketProtocol>)packet;

#pragma mark - 

- (void)registerPacketClass:(Class)packetClass action:(NSString *)action;

- (Class)packetClassForAction:(NSString *)action;

- (void)removePacketClassForAction:(NSString *)action;

@end
