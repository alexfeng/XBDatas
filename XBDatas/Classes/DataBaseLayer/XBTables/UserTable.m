//
//  UserTable.m
//  Pods
//
//  Created by 冯向博 on 2016/11/24.
//
//

#import "UserTable.h"
#import <XBDatas/XBDBHelper.h>

#define kTableName      @"user_table"

@implementation UserTable

DEFINE_SINGLETON_FOR_CLASS(UserTable)

- (id)init {
    self = [super init];
    if (self) {
        self.tableName = kTableName;
    }
    return self;
}

// MARK: XBBaseTableProtocol Methods
- (BOOL)createTableIfNotExist {
   return [[XBDBHelper sharedXBDBHelper] excuteSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ( 'userId' INTEGER,'name' text,'age' INTEGER )",self.tableName]];
}

/**
 *  根据DB版本更新表
 */
- (void)updateTableAccordingToDbVersion {
    
}

@end
