//
//  Global.h
//  http://Sugartin.info
//
//  Created by Neon Spark on 15/10/10.
//  Copyright 2010 http://Sugartin.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Global : NSObject {

}

+(UIView*)view;
+(void)setView:(UIView*)setV;
+(void)startLoading:(NSMutableURLRequest*)urlRequest vCtr:(UIViewController*)vCtrRef;

+(NSMutableURLRequest*)urlRequestAction:(NSString*)sa_Name message:(NSString*)sm_msg;
+(NSString*)SA_synchronise;
+(NSString*)SM_synchronise;

+(NSString*)SA_SearchAction;
+(NSString*)SM_Search_BrandID:(NSString*)brandID modelID:(NSString*)modelID From:(NSString*)from to:(NSString*)to countryID:(NSString*)countryID;

+(NSString*)SA_ModelImages;
+(NSString*)SM_ModelImages:(NSString*)modelID;
+(NSMutableArray*)arrayOfImages;

+(NSString*)SA_FavouriteRefresh;
+(NSString*)SM_FavouriteRefreshModelIDs:(NSString*)modelIDs;
@end
