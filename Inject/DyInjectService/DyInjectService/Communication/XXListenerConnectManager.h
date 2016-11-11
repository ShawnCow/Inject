//
//  XXListenerConnectManager.h
//  Communication
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXDeviceConnectManager.h"

@class XXListenerConnectManager;

@protocol XXListenerConnectManagerDelegate <XXDeviceConnectManagerDelegate>

@optional

- (void)listenerConnectManager:(XXListenerConnectManager *)listenerConnectManager didFindHost:(NSString *)host;

@end

@interface XXListenerConnectManager : XXDeviceConnectManager

+ (instancetype)currentListenerConnectManager;

@end
