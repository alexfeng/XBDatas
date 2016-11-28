//
//  GroupTable.m
//  Pods
//
//  Created by 冯向博 on 2016/11/25.
//
//

#import "GroupTable.h"
#import <XBDatas/XBDBHelper.h>

#define kTableName      @"group_table"

@implementation GroupTable

DEFINE_SINGLETON_FOR_CLASS(GroupTable)

- (id)init {
    self = [super init];
    if (self) {
        self.tableName = kTableName;
    }
    return self;
}

// MARK: XBBaseTableProtocol Methods

- (void)createTableIfNotExist {
    [[XBDBHelper sharedXBDBHelper] excuteSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ( 'groupId' INTEGER,'groupName' text)" , self.tableName]];
}

/**
 *  根据DB版本更新表
 */
- (void)updateTableAccordingToDbVersion {
    
}
@end
