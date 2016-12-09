//
//  XBDBHelper.m
//  Pods
//
//  Created by 冯向博 on 2016/11/23.
//
//

#import "XBDBHelper.h"

#import <XBDatas/XBBaseTable.h>

#import <FMDB/FMDatabase.h>
#import <FMDB/FMdatabaseQueue.h>

#import <SQLCipher/sqlite3.h>


#define XBDBDATE_FORMAT @"yyyy-MM-dd HH:mm:ss.SSS"

@interface XBDBHelper ()

@property (nonatomic,   copy) NSString *dbName;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation XBDBHelper

// MARK: Class Methods

+ (void)createAllTables:(NSArray *)tableNames {
    for (NSString *tableName in tableNames) {
        Class class = NSClassFromString(tableName);
        NSString *singletonSelStr = [NSString stringWithFormat:@"shared%@", tableName];
        SEL singletonSel = NSSelectorFromString(singletonSelStr);
        
        if (class && [class respondsToSelector:singletonSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            XBBaseTable *classObj = [class performSelector:singletonSel];
            if (classObj) {
                [classObj createAndUpgradeTable];
            }
#pragma clang diagnostic pop
        }
        else {
            NSLog(@"error: no table named \"%@\"", tableName);
        }
    }
}

// MARK: Life circle

- (void)dealloc {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db close];
    }];
}

DEFINE_SINGLETON_FOR_CLASS(XBDBHelper)

// MARK: Public Methods

/**
 *  创建数据库
 *
 *  @param DBPath 数据库文件路径
 */
- (void)createDatabaseWithDBName:(NSString *)dbName {
    
    [self createDatabaseWithDBName:dbName withDBKey:nil];
}

/**
 *  创建数据库
 *
 *  @param DBPath 数据库文件路径
 *  @param dbKey  数据库加密key
 */
- (void)createDatabaseWithDBName:(NSString *)dbName withDBKey:(NSString *)dbKey {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    _dbName = dbName;
    NSString *dbFileName = _dbName;
    NSString *fullDBPath = [ourDocumentPath stringByAppendingFormat:@"/%@.db",dbFileName];
    
    NSString *dbEncryptKey = nil;
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = XBDBDATE_FORMAT;
    
    if (dbKey)
    {
        dbEncryptKey = [dbKey copy];
        // 未加密数据库数据加密迁移
        [self encryptDBFromOldDbPath:fullDBPath withEncryptKey:dbEncryptKey];
    }
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:fullDBPath];
    NSLog(@"db path:%@\n", fullDBPath);
    NSLog(@"db key:%@\n",dbEncryptKey);
    
    __block BOOL rs = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db setDateFormat:formater];
        
        if (dbEncryptKey)
        {
            rs = [db open] && [db setKey:dbEncryptKey] && [db goodConnection];
        }
        else
        {
            rs = [db open] && [db goodConnection];
        }
    }];
    
    if (!rs) {
        //这里只是预防万一，一般不会到这里。
        //如果还是打不开，那原因就不可控了，就尝试重新建数据库了
        
        [[NSFileManager defaultManager] removeItemAtPath:fullDBPath error:nil];
        //再来一次，这次是新建的,一般不会失败，估计也只有空间不足会失败吧。这也无能为力了。
        [_dbQueue inDatabase:^(FMDatabase *db) {
            [db setDateFormat:formater];
            
            if (dbEncryptKey) {
                [db open] && [db setKey:dbEncryptKey];
            }
            else
            {
                [db open];
            }
        }];
    }
}

/**
 *  清除数据库
 */
- (void)clearDB {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSString *fullPath = [ourDocumentPath stringByAppendingFormat:@"/%@.db",_dbName];
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}


/**
 *  删除表中所有数据
 */
- (BOOL)deleteDataFromTable:(NSString *)tableName {
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    NSLog(@"delete sql str:%@", sqlStr);
    __block BOOL rs = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        rs = [db executeUpdate:sqlStr];
    }];
    
    return rs;
}

/**
 *  执行sql语句
 */
- (BOOL)excuteSql:(NSString *)excuteSql {
    __block BOOL rs = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        rs = [db executeUpdate:excuteSql];
    }];
    
    return rs;
}

// MARK: private Methods

- (void)encryptDBFromOldDbPath:(NSString *)oldDbPath withEncryptKey:(NSString *)encryptKey {
    
    if (!encryptKey) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:oldDbPath]) {
        return;
    }
    
    NSString *tmppath = [self changeDatabasePath:oldDbPath];
    
    sqlite3 *unencrypted_DB;
    if (sqlite3_open([tmppath UTF8String], &unencrypted_DB) == SQLITE_OK) {
        NSLog(@"Database Opened");
        // Attach empty encrypted database to unencrypted database
        sqlite3_exec(unencrypted_DB, [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@'", oldDbPath, encryptKey] UTF8String], NULL, NULL, NULL);
        
        // export database
        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        
        // Detach encrypted database
        sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
        
        sqlite3_close(unencrypted_DB);
        //删除以前未加密的数据库
        [fileManager removeItemAtPath:tmppath error:nil];
    }
    else {
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
    }
}

- (NSString *)changeDatabasePath:(NSString *)path{
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSString *tmppath = [NSString stringWithFormat:@"%@.tmp",path];
    BOOL result = [fm moveItemAtPath:path toPath:tmppath error:&err];
    if(!result){
        NSLog(@"Error: %@", err);
        return nil;
    }else{
        return tmppath;
    }
}
@end
