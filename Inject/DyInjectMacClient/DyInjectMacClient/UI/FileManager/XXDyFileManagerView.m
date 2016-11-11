//
//  XXDyFileManagerView.m
//  DyInjectMacClient
//
//  Created by Shawn on 2016/11/7.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "XXDyFileManagerView.h"
#import "XXDyFileStack.h"
#import "XXPacket.h"
#import "__XXDyInjectRouter.h"
#import "XXServerConnectManager.h"

@interface XXDyFileManagerView ()<NSTableViewDelegate,NSTableViewDataSource>
{
    XXDyFileStack * stack;
}
@property (nonatomic, weak) IBOutlet NSTableView * tableView;
@property (nonatomic, weak) IBOutlet NSPathControl * pathControl;
@property (nonatomic, strong) NSArray * visibleArray;
@property (nonatomic) NSInteger rootDirType;

@end

@implementation XXDyFileManagerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSPathControlItem * item = [[NSPathControlItem alloc]init];
    item.title = @"/";
    self.pathControl.pathItems = @[item];
    stack = [XXDyFileStack new];
    self.visibleArray = stack.visiblePaths;
//
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(doubleClickCell)];
    __weak XXDyFileManagerView * ws = self;
    [[__XXDyInjectRouter shareDyInjectRouter]registerRouterWithKey:@"filemanager" completion:^id(id<XXPacketProtocol> packet) {
        [ws handlePacket:packet];
        return nil;
    }];
    [self.tableView reloadData];
}

- (void)doubleClickCell
{
    if (stack.stackCount == 1) {
        self.rootDirType = self.tableView.selectedRow;
    }
    
    self.pathControl.enabled = NO;
    self.tableView.enabled = NO;
    NSMutableArray * subDir = [NSMutableArray array];
    for (int i = 1; i < self.pathControl.pathItems.count; i ++) {
        NSPathControlItem * item = self.pathControl.pathItems[i];
        [subDir addObject:item.title];
    }
    NSString * subPath = nil;
    if (subDir.count > 0) {
        subPath = [subDir componentsJoinedByString:@"/"];
    }
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    tempDic[@"type"] = @"show";
    if (subPath) {
        tempDic[@"subpath"] = subPath;
    }
    tempDic[@"pathtype"] = [NSNumber numberWithInteger:self.rootDirType];
    XXPacket * p = [[XXPacket alloc]initWithAction:@"filemanager" infoDic:tempDic packetData:nil];
    [[XXServerConnectManager currentServerConnectManager]inQueueWithPacket:p];
    
    NSString * currentTitle = [self.visibleArray objectAtIndex:self.tableView.selectedRow];
    NSPathControlItem * item = [[NSPathControlItem alloc]init];
    item.title = currentTitle;
    NSMutableArray * tempPathItems = [self.pathControl.pathItems mutableCopy];
    [tempPathItems addObject:item];
    self.pathControl.pathItems = tempPathItems;
}

- (void)handlePacket:(id<XXPacketProtocol>)packet
{
    self.pathControl.enabled = YES;
    self.tableView.enabled = YES;
    NSArray * result = [[packet packetDictionary]objectForKey:@"result"];
    if ([result isKindOfClass:[NSArray class]]) {
        [stack pushPaths:result];
        self.visibleArray = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }else
    {
        NSMutableArray * tempArray = [self.pathControl.pathItems mutableCopy];
        if (stack.stackCount != tempArray.count) {
            [tempArray removeLastObject];
            self.pathControl.pathItems = tempArray;
        }
    }
}

#pragma mark -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.visibleArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    cellView.textField.stringValue = self.visibleArray[row];
    return cellView;
}

@end
