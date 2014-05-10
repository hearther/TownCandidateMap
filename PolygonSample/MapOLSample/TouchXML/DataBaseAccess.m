//
//  DataBaseAccess.m
//  myMarketsVic
//
//  Created by Neon Spark on 05/05/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "DataBaseAccess.h"
#import "AppDelegate.h"

Database	*sharedDatabase = nil;


//NSString	*dayNameString[] = {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};
//NSString	*dayNameHalfString[] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thr", @"Frd", @"Sat"};
//NSString	*monthName[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"Decemeber"};

#define GETCOLUMNSTRING(_TO_, _FROM_)	NSString *_TO_; {const unsigned char *c = sqlite3_column_text(compiledStmt, _FROM_); _TO_ = c ? [NSString stringWithUTF8String:(char*)c] : @""; }

#define PUTCOLUMNSTRING(_TO_, _FROM_)	{NSString *str = [dObj valueForKey:_FROM_]; if (!str) str=@""; sqlite3_bind_text(compiledStmt, _TO_, [str UTF8String], -1, SQLITE_TRANSIENT);}


@implementation Database

+(Database *)sharedDatabase {
    if (sharedDatabase == nil)
	{
		sharedDatabase = [[Database alloc] init];
	}
	return sharedDatabase;
}

- (id)init {
	if (self = [super init])
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		NSString *dbPath=[basePath stringByAppendingPathComponent:[kDataBaseName stringByAppendingFormat:@".%@",kDataBaseExt]];
		NSFileManager *fm=[NSFileManager defaultManager];
		
		if(![fm fileExistsAtPath:dbPath]){
			[fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:kDataBaseName ofType:kDataBaseExt] toPath:dbPath error:nil];
		}
		if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK)
			NSLog(@"Error opening database!");
		
		sqlite3_stmt *compiledStmt;
		NSUInteger err = sqlite3_prepare_v2(database, "PRAGMA count_changes=OFF; PRAGMA journal_mode = OFF; PRAGMA synchronous=OFF", -1, &compiledStmt, NULL);
		if (!err)
		{
			err = sqlite3_step(compiledStmt);
			if (!err)
				sqlite3_finalize(compiledStmt);
		}
	}
 	return self;
}

-(NSMutableArray*)getBrandMasterValues{
	NSMutableArray *getBrandMasterValues=[NSMutableArray array];
	{
		const char	*sqlStatement="select * from BrandMaster ORDER BY BrandName ASC";
		sqlite3_stmt *compiledStmt;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStmt)==SQLITE_ROW) {
				NSUInteger mNo=(NSUInteger)sqlite3_column_int(compiledStmt, 0);
				GETCOLUMNSTRING(mName, 1)
				[getBrandMasterValues addObject:
				 [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",mNo],@"BrandId",mName,@"BrandName",nil]
				 ];
			}
		}
		sqlite3_finalize(compiledStmt);
	}
	return getBrandMasterValues;
}

-(NSMutableArray*)getModelMasterValues:(NSUInteger)brandID{
	NSMutableArray *ModelMasterValues=[NSMutableArray array];
	{
		NSString *str=[NSString stringWithFormat:@"select * from ModelMaster where BrandId = %i ORDER BY ModelName ASC",brandID];
		const char	*sqlStatement=[str UTF8String];
		sqlite3_stmt *compiledStmt;
		
//		sqlite3_bind_int(compiledStmt, 1, brandID); 
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStmt)==SQLITE_ROW) {
				NSUInteger mNo=(NSUInteger)sqlite3_column_int(compiledStmt, 0);
				GETCOLUMNSTRING(mName, 1)
				[ModelMasterValues addObject:
				 [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",mNo],@"ModelId",mName,@"ModelName",nil]
				 ];
			}
		}
		sqlite3_finalize(compiledStmt);
	}
	return ModelMasterValues;
}

-(void)checkBrandMasters:(NSArray*)dBrandMasterValues{
	NSLog(@"START*************** BrandMaster  -%d items", dBrandMasterValues.count );
	sqlite3_stmt *compiledStmt;
	sqlite3_prepare_v2(database, "BEGIN TRANSACTION", -1, &compiledStmt, NULL);
	sqlite3_step(compiledStmt);
	sqlite3_finalize(compiledStmt);	
	const char	*sqlStatement="REPLACE INTO BrandMaster(BrandId,BrandName) VALUES  (?,?)";
	if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStmt, NULL)== SQLITE_OK) {
		for (NSDictionary *dObj in dBrandMasterValues) {
			NSUInteger	cid = [[dObj objectForKey:@"BrandId"] intValue];
			if (cid) {
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

				sqlite3_bind_int(compiledStmt, 1, cid); 
				PUTCOLUMNSTRING(2, @"BrandName")	
				NSUInteger err = sqlite3_step(compiledStmt);
				if (err != SQLITE_DONE)
					NSLog(@"replace error %d %s",err, sqlite3_errmsg(database));
				sqlite3_reset(compiledStmt);
				[pool release];
			}
		}
		sqlite3_finalize(compiledStmt);		
	}
	sqlite3_prepare_v2(database, "END TRANSACTION", -1, &compiledStmt, NULL);
	sqlite3_step(compiledStmt);
	sqlite3_finalize(compiledStmt);	
	NSLog(@"END*************** BrandMaster");
}

-(void)checkModelMaster:(NSArray*)dModelMasterValues{
	NSLog(@"START*************** ModelMaster  -%d items", dModelMasterValues.count );
	sqlite3_stmt *compiledStmt;
	sqlite3_prepare_v2(database, "BEGIN TRANSACTION", -1, &compiledStmt, NULL);
	sqlite3_step(compiledStmt);
	sqlite3_finalize(compiledStmt);	
	const char	*sqlStatement="REPLACE INTO ModelMaster(ModelId,ModelName,BrandId) VALUES  (?,?,?)";
	if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStmt, NULL)== SQLITE_OK) {
		for (NSDictionary *dObj in dModelMasterValues) {
			NSUInteger	cid = [[dObj objectForKey:@"ModelId"] intValue];
			NSUInteger	bid = [[dObj objectForKey:@"BrandId"] intValue];
			if (cid && bid) {
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
				
				sqlite3_bind_int(compiledStmt, 1, cid); 
				PUTCOLUMNSTRING(2, @"ModelName")	
				sqlite3_bind_int(compiledStmt, 3, bid); 
				NSUInteger err = sqlite3_step(compiledStmt);
				if (err != SQLITE_DONE)
					NSLog(@"replace error %d %s",err, sqlite3_errmsg(database));
				sqlite3_reset(compiledStmt);
				[pool release];
			}
		}
		sqlite3_finalize(compiledStmt);		
	}
	sqlite3_prepare_v2(database, "END TRANSACTION", -1, &compiledStmt, NULL);
	sqlite3_step(compiledStmt);
	sqlite3_finalize(compiledStmt);	
	NSLog(@"END*************** BrandMaster");
}


@end