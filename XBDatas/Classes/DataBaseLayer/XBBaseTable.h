//
//  XBBaseTable.h
//  Pods
//
//  Created by 冯向博 on 2016/11/23.
//
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>


#define PRIME_KEY_FLAG(ATTR_TYPE) [ATTR_TYPE stringByAppendingString:@" PRIMARY KEY"]
#define AUTO_PRIME_KEY_FLAG(ATTR_TYPE) [ATTR_TYPE stringByAppendingString:@" PRIMARY KEY AUTOINCREMENT"]

#define kByteType @"BYTE"
#define kVarCharType(LENGTH) [NSString stringWithFormat:@"VARCHAR(%d)",LENGTH]
#define kNVarCharType(LENGTH) [NSString stringWithFormat:@"NVARCHAR(%d)",LENGTH]
#define kIntType @"INTEGER"
#define kUrlType kVarCharType(256)
#define kIsReadedType [kIntType stringByAppendingString:@" DEFAULT(0)"]
#define kDateType kVarCharType(25)
#define kTextType @"TEXT"

/**
 *  基表协议
 */
@protocol XBBaseTableProtocol

/**
 *  创建表
 *
 *  @return 创建是否成功
 */
- (BOOL)createTableIfNotExist;

/**
 *  根据DB版本更新表
 */
- (void)updateTableAccordingToDbVersion;

@end


@interface XBBaseTable : NSObject

/**
 *  表名
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  清除表数据
 *
 *  @return 是否清除成功
 */
- (BOOL)cleanTable;

/**
 *  创建表并更新表
 */
- (void)createAndUpgradeTable;

@end
