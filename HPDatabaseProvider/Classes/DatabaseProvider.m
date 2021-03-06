//
//  DataBaseProvider.m
//  Predanie
//
//  Created by DimasSup on 20.05.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "DatabaseProvider.h"

@implementation DatabaseProvider
@synthesize operationQueue = _operationQueue;
@synthesize dbQueue = _queue;
@synthesize dbPath = _dbPath;
- (instancetype)initWithQOS:(dispatch_qos_class_t)qosClass
{
	self = [super init];
	if (self) {
		_operationQueue = dispatch_queue_create( [NSString stringWithFormat:@"%@.dboperationqueue",[NSBundle mainBundle].bundleIdentifier].UTF8String, NULL );
		dispatch_set_target_queue(_operationQueue, dispatch_get_global_queue(qosClass, 0));
	}
	return self;
}
- (instancetype)init
{
    self = [self initWithQOS:QOS_CLASS_DEFAULT];
    return self;
}


-(void)migration
{
	
}


- (void)createDBByPath:(NSString *)path fromFile:(NSString*)file
{
	dispatch_sync(_operationQueue, ^{
		
		if(_dbPath!=path)
		{
			_dbPath = path;
			if (path)
			{
				NSFileManager* fm = [NSFileManager defaultManager];
				
				BOOL isExist = [fm fileExistsAtPath:path];
				_queue = [FMDatabaseQueue databaseQueueWithPath:path];
				
				if(!isExist)
				{
					[_queue inDatabase:^(FMDatabase *db) {
						NSArray *commands = [NSArray arrayWithContentsOfFile:file];
						for (NSInteger i = 0; i < [commands count]; i++) {
							[db executeUpdate:commands[i]];
						}
					}];
				}
				
				NSString* pathWithoutExt = [file stringByDeletingPathExtension];
				pathWithoutExt = [[pathWithoutExt stringByAppendingString:@"_migration"] stringByAppendingPathExtension:[file pathExtension]];
				if([fm fileExistsAtPath:pathWithoutExt])
				{
					[self migrateWithPlist:pathWithoutExt];
				}
			}
		}
	});
}
-(void)migrateWithPlist:(NSString*)plistPath
{
	NSArray* values = [NSArray arrayWithContentsOfFile:plistPath];
	if(values)
	{
		__block int version = 0;
		
		[_queue inDatabase:^(FMDatabase *db) {
			
			BOOL isSystemInfoExist =[db tableExists:@"TSystemInfo"];
			if (isSystemInfoExist)
			{
				FMResultSet* result = [db executeQuery:@"SELECT value FROM TSystemInfo WHERE key = ?" withArgumentsInArray:@[@"version"]];
				if(result.next)
				{
					version = [result intForColumn:@"value"];
				}
				[result close];
			}
			
			
			
			
		}];
		int endVersion = version;
		for (NSArray* migration in values)
		{
			int migrationVersion = [[migration firstObject] intValue];
			if(migrationVersion> version)
			{
				endVersion = migrationVersion;
				[_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
					for (int  i = 1; i<migration.count; i++)
					{
						NSArray* stepDic = [migration objectAtIndex:i];
						
						NSString* firstObject = [stepDic firstObject];
						NSString* query = [stepDic lastObject];
						if([firstObject isEqualToString:@"update"])
						{
							[db executeUpdate:query];
						}
						else if([firstObject isEqualToString:@"query"])
						{
							[db executeQuery:query];
						}
					}
					[db executeUpdate:@"UPDATE TSystemInfo SET value = ? where key = 'version'" withArgumentsInArray:@[@(migrationVersion)]];
				}];
			}
		}
		if(self.migrationComplete){
			self.migrationComplete(version, endVersion);
		}

	}
	
}

-(void)performBlockInDB:(DatabaseProviderExecuteBlock)block
{
	__block DatabaseProviderExecuteBlock callBlock = [block copy];
	
	dispatch_sync(_operationQueue, ^{
		@autoreleasepool
		{
			[self->_queue inDatabase:callBlock];
		}
	});
}
-(void)performAsyncBlockInDB:(DatabaseProviderExecuteBlock)block
{
	__block DatabaseProviderExecuteBlock callBlock = [block copy];
	dispatch_async(_operationQueue, ^{
		@autoreleasepool
		{
			[self->_queue inDatabase:callBlock];
		}
	});
	
}
-(void)dealloc
{
	typeof (self) weakSelf = self;
	dispatch_sync(weakSelf.operationQueue, ^{
		[weakSelf.dbQueue close];
	});
	_queue = nil;
}

@end
