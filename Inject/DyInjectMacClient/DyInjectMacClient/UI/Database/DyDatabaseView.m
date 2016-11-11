//
//  DyDatabaseView.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "DyDatabaseView.h"
#import "XXServerConnectManager.h"
#import "__XXDyInjectRouter.h"
#import "XXPacket.h"

@interface DyDatabaseView ()<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView * tableView;
@property (nonatomic, weak) IBOutlet NSTextView * sqlTextView;
@property (nonatomic, weak) IBOutlet NSTextView * resultTextView;
@property (nonatomic, weak) IBOutlet NSButton * exeButton;
@property (nonatomic, strong) NSArray * allPaths;
@end

@implementation DyDatabaseView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    [self setFunctionEnable:NO];
    
    __weak DyDatabaseView * ws = self;
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"database" completion:^id(id<XXPacketProtocol> packet) {
        
        [ws handlePacket:packet];
        return nil;
    }];
}

- (void)dealloc
{
    [[__XXDyInjectRouter shareDyInjectRouter]unresiterRouterWithKey:@"database"];
}

- (void)setFunctionEnable:(BOOL)enable
{
    self.tableView.enabled = enable;
    self.sqlTextView.editable = enable;
    if (!enable) {
        self.sqlTextView.string = @"";
        self.resultTextView.string = @"";
        self.allPaths = nil;
        [self.tableView reloadData];
    }
    self.exeButton.enabled = enable;
}

- (IBAction)exeButtonAction:(id)sender
{
    if ([[XXServerConnectManager currentServerConnectManager] connectedHost] == NO) {
        NSAlert * alert = [[NSAlert alloc]init];
        alert.messageText = @"还未连接";
        [alert runModal];
        return;
    }
    NSString * sql = self.sqlTextView.string;
    if (sql.length == 0) {
        NSAlert * alert = [[NSAlert alloc]init];
        alert.messageText = @"SQL不能为空";
        [alert runModal];
        return;
    }
    NSInteger selectRow = self.tableView.selectedRow;
    if (selectRow >= 0) {
        
        NSString * path = self.allPaths[selectRow];
        NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
        tempDic[@"type"] = @"query";
        tempDic[@"path"] = path;
        tempDic[@"sql"] = sql;
        XXPacket * packet = [[XXPacket alloc]initWithAction:@"database" infoDic:tempDic packetData:nil];
        [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:packet];
    }else
    {
        NSAlert * alert = [[NSAlert alloc]init];
        alert.messageText = @"请选一个需要执行SQL的文件路径";
        [alert runModal];
        return;
    }
}

- (void)handlePacket:(id<XXPacketProtocol>)packet
{
    NSDictionary * dic = [packet packetDictionary];
    NSString * info = [NSString stringWithFormat:@"%@",dic];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (info) {
            [self.resultTextView insertText:info replacementRange:NSMakeRange(self.resultTextView.string.length, 0)];
        }
        [self.resultTextView setFrameOrigin:CGPointMake(0, 0)];
    });
    if ([dic[@"type"] isEqualToString:@"callresult"]) {
        NSArray * result  = dic[@"result"];
        if ([result isKindOfClass:[NSArray class]]) {
            self.allPaths = result;
            [self.tableView reloadData];
        }
    }
    NSTask 
}


#pragma mark -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.allPaths.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    cellView.textField.stringValue = [self.allPaths[row] lastPathComponent];
    return cellView;
}
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    XXPacket * packet = [[XXPacket alloc]initWithAction:@"database" infoDic:@{@"type":@"listpath"} packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:packet];
}
@end
