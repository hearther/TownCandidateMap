//
//  DataBaseAccess.h
//  myMarketsVic
//
//  Created by Neon Spark on 05/05/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define DataBaseAccess [Database sharedDatabase]
#define kDataBaseName @"myGulfCar"
#define kDataBaseExt	@"sqlite"

@interface Database : NSObject 
{
	sqlite3 *database;
}
+(Database*)sharedDatabase;


-(void)checkBrandMasters:(NSArray*)dBrandMasterValues;
-(void)checkModelMaster:(NSArray*)dModelMasterValues;

-(NSMutableArray*)getBrandMasterValues;
-(NSMutableArray*)getModelMasterValues:(NSUInteger)brandID;
@end
