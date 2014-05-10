//
//  WebRqst.h
//  http://Sugartin.info
//
//  Created by Neon Spark on 15/10/10.
//  Copyright 2010 http://Sugartin.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface UIViewController(WebRqst)
-(void)webRequestReceivedData:(NSData*)data;
@end


@class AppDelegate;
@interface WebRqst : NSObject <MBProgressHUDDelegate>{
	MBProgressHUD *mbProcess;
	UIViewController *vCtrWhileParsing;
	AppDelegate *del;
	NSMutableData *myWebData;
	UIView *avView;
	UIAlertView *av;
	UIActivityIndicatorView *actV;
}

-(void)showProgressHUD;
-(void)hideProgressHUD;

-(void)startLoading:(NSMutableURLRequest*)urlRequest vCtr:(UIViewController*)vCtrRef;
//-(void)makeRequest_Account_XML:(UIViewController*)vCtrRef ;
//-(void)makeRequest_Companies_XML:(UIViewController*)vCtrRef;
@end
