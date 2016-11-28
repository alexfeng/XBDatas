//
//  XBBaseTable.m
//  Pods
//
//  Created by 冯向博 on 2016/11/23.
//
//

#import "XBBaseTable.h"
#import <XBDatas/XBDBHelper.h>

@implementation XBBaseTable

// MARK: 子类实现
- (BOOL)cleanTable {
    [[XBDBHelper sharedXBDBHelper] deleteDataFromTable:self.tableName];
}


// MARK: 子类实现
- (void)createAndUpgradeTable {
    if ([self respondsToSelector:@selector(createTableIfNotExist)])
    {
        [self performSelector:@selector(createTableIfNotExist)];
    }
    
    if ([self respondsToSelector:@selector(updateTableAccordingToDbVersion)])
    {
        [self performSelector:@selector(updateTableAccordingToDbVersion)];
    }
}

@end
