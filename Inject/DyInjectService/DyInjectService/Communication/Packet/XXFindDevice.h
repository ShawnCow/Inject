//
//  XXFindDevice.h
//  XXRequestMonitor
//
//  Created by Shawn on 15/4/20.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XXFindDeviceStatus) {
    XXFindDeviceStatusNone,
    XXFindDeviceStatusBinding,
    XXFindDeviceStatusFinding,
};

@class XXFindDevice;

@protocol XXFindDeviceDelegate <NSObject>

@optional

/**
 查找到机器回掉

 @param findDevice 回掉对象
 @param host 查找到机器的回掉
 */

- (void)findDevice:(XXFindDevice *)findDevice didFindHost:(NSString *)host;

@end

@interface XXFindDevice : NSObject


/**
 配对过程中需要通过key来匹配是否是自己正确想要查找的机器

 @param key 配对的key
 @return 对象
 */

- (instancetype)initWithKey:(NSString *)key;

@property (nonatomic, readonly, copy) NSString * key;

@property (nonatomic, weak) id <XXFindDeviceDelegate> delegate;

@property (nonatomic, readonly) XXFindDeviceStatus status;

/**
 *  开始监听服务
 */
- (BOOL)startBind;

/**
 *  开启查找服务
 *
 *  @return NO 开启失败 YES 开启成功
 */
- (BOOL)startFind;

/**
 暂停当前服务
 */
- (void)stop;

@end
