//
//  XBDBHelper.h
//  Pods
//
//  Created by 冯向博 on 2016/11/23.
//
//

#import <Foundation/Foundation.h>
#import <XBDatas/XBDatasMacroDefine.h>
#import <SQLCipher/FMResultSet.h>

// 所有表名，用来统一生成表名类名，新表加入

@interface XBDBHelper : NSObject

DECLARE_SINGLETON_FOR_CLASS(XBDBHelper)

/**
 *  创建所有表
 */
+ (void)createAllTables:(NSArray *)tableNames;

/**
 *  创建数据库
 *
 *  @param DBPath 数据库文件路径
 */
- (void)createDatabaseWithDBName:(NSString *)dbName;

/**
 *  创建数据库
 *
 *  @param DBPath 数据库文件路径
 */
- (void)createDatabaseWithDBName:(NSString *)dbName withDBKey:(NSString *)dbKey;

/**
 *  清除数据库
 */
- (void)clearDB;

/**
 *  删除表中所有数据
 */
- (BOOL)deleteDataFromTable:(NSString *)tableName;

/**
 *  执行sql语句
 */
- (BOOL)excuteSql:(NSString *)excuteSql;


/**
 *  查询sql语句
 */
- (NSArray *)fetchDataWithSql:(NSString *)sql converter:(NSArray *(^)(FMResultSet *fmResultSet))converter;

@end
