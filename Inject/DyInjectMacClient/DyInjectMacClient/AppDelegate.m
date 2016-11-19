//
//  AppDelegate.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/5.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "AppDelegate.h"
#import "XXServerConnectManager.h"
#import "XXPacket.h"
#import "XXReceiveFileService.h"
#import "__XXDyInjectRouter.h"
#import <mach-o/dyld.h>
@interface AppDelegate ()<XXDeviceConnectManagerDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *keyTextField;
@property (weak) IBOutlet NSButton *connectBtn;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [XXServerConnectManager currentServerConnectManager].delegate = self;
    int count = _dyld_image_count();
    for (int i = 0; i < count; i ++) {
        const char * name = _dyld_get_image_name(i);
        NSString * dyName = [NSString stringWithUTF8String:name];
        NSLog(@"name %@",dyName);
    }
    NSString * bundleId = [[NSUserDefaults standardUserDefaults]objectForKey:@"bundleid"];
    if (!bundleId) {
        bundleId = @"";
    }
    self.keyTextField.stringValue = bundleId;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - 

- (void)deviceConnectManagerDidDisconnect:(XXDeviceConnectManager *)deviceConnectionManager
{
    self.connectBtn.title = @"配对";
    self.keyTextField.enabled = YES;
}

- (void)deviceConnectManager:(XXDeviceConnectManager *)deviceConnectionManager didConnectToHost:(NSString *)host
{
    self.connectBtn.title = @"断开";
    self.keyTextField.enabled = NO;
    self.keyTextField.stringValue = host;
}

- (void)deviceConnectManager:(XXDeviceConnectManager *)deviceConnectionManager didReceivePacket:(id<XXPacketProtocol>)packet
{
    NSLog(@"%@  lenght  %@",[packet packetAction],[(XXPacket *)packet packetDictionary]);
    if ([[packet packetAction]isEqualToString:@"XXPacketSendFileAction"]) {
        [[XXReceiveFileService defaultDyInjectFileService]addFilePacket:packet];
        NSLog(@"%@",[XXReceiveFileService pathWithSubPath:nil type:DyInjectFileServicePathTypeDocument]);
    }
    
    [[__XXDyInjectRouter shareDyInjectRouter]routerWithKey:[packet packetAction] parameter:packet];
}

- (IBAction)testAction:(id)sender {
//    [self s];
//    return;
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"rootviewcontroller";
    dic[@"path"] = @"";
    dic[@"subpath"] = @"test.pdf";
    XXPacket * p = [[XXPacket alloc]initWithAction:@"viewmanager" infoDic:dic packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:p];
}
- (void)s
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"query";
    dic[@"path"] = @"/Users/Shawn/Library/Developer/CoreSimulator/Devices/806B32B1-904D-4C43-8EDF-45D7666D6CFE/data/Containers/Data/Application/9485FB5D-2358-4553-950F-AD62319D8B21/Documents/test2";
    dic[@"sql"] = @"select * from sqlite_master";
    XXPacket * p = [[XXPacket alloc]initWithAction:@"database" infoDic:dic packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:p];
}
#pragma mark - 

- (IBAction)connectBtnAction:(id)sender {
    
    if ([self.connectBtn.title isEqualToString:@"配对"]) {
        if (self.keyTextField.stringValue.length == 0) {
            NSAlert * alert = [[NSAlert alloc]init];
            alert.messageText = @"配对字符串不能为空!";
            [alert runModal];
            return;
        }
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:self.keyTextField.stringValue forKey:@"bundleid"];
        [userDefault synchronize];
         [[XXServerConnectManager currentServerConnectManager]startWithKey:self.keyTextField.stringValue];
        self.connectBtn.title = @"断开";
        self.keyTextField.enabled = NO;
    }else if ([self.connectBtn.title isEqualToString:@"断开"])
    {
        [[XXServerConnectManager currentServerConnectManager]disconnect];
        self.connectBtn.title = @"配对";
        self.keyTextField.enabled = YES;
        self.keyTextField.stringValue = @"";
    }
}

@end
