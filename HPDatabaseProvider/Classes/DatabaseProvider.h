//
//  DataBaseProvider.h

//
//  Created by DimasSup on 20.05.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <Foundation/Foundation.h>
@import FMDB;

typedef void (^DatabaseProviderExecuteBlock)(FMDatabase* db);

@interface DatabaseProvider : NSObject
{
	__block NSString* _dbPath;
	dispatch_queue_t _operationQueue;
	__block	FMDatabaseQueue* _queue;
	
}
@property(nonatomic,readonly)dispatch_queue_t operationQueue;
@property(nonatomic,readonly)FMDatabaseQueue* dbQueue;
@property(nonatomic,readonly)NSString* dbPath;

-(void)createDBByPath:(NSString *)path fromFile:(NSString*)file;
-(void)performBlockInDB:(DatabaseProviderExecuteBlock)block;
-(void)performAsyncBlockInDB:(DatabaseProviderExecuteBlock)block;

@end
