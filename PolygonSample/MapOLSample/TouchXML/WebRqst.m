//
//  WebRqst.m
//  http://Sugartin.info
//
//  Created by Neon Spark on 15/10/10.
//  Copyright 2010 http://Sugartin.info. All rights reserved.
//

#import "WebRqst.h"
#import "Global.h"
#import "AppDelegate.h"

@implementation WebRqst


-(id)init{
	if(self=[super init]){
		del=(AppDelegate*)[[UIApplication sharedApplication] delegate];
		actV=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[actV startAnimating];
	} 
	return self;
}

// ?op=GetSearchResults

-(void)showProgressHUD{
	if(av!=nil && [av retainCount]>0) { [av release]; av=nil; }
	av=[[UIAlertView alloc] initWithTitle:@"Loading Data" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[av show];
	[actV setFrame:CGRectMake(125, 60, 37, 37)];
	[av addSubview:actV];
//	if(mbProcess!=nil && [mbProcess retainCount]>0){ [mbProcess release]; mbProcess=nil;}
//	mbProcess=[[MBProgressHUD alloc] initWithView:[Global view]];
//	mbProcess.labelText=NSLocalizedString(@"Loading Data",@"");
//	mbProcess.detailsLabelText=NSLocalizedString(@"Please wait",@"");
//	[[Global view] addSubview:mbProcess];
//	[mbProcess setDelegate:self];
//	[mbProcess show:NO];
}

-(void)hideProgressHUD{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[av dismissWithClickedButtonIndex:0 animated:YES];
//	[mbProcess hide:NO];
//	if(mbProcess!=nil && [mbProcess retainCount]>0){ [mbProcess release]; mbProcess=nil;}
}

-(void)startLoading:(NSMutableURLRequest*)urlRequest vCtr:(UIViewController*)vCtrRef{
	vCtrWhileParsing=vCtrRef;
    [self showProgressHUD];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLConnection *con=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if(con){
		myWebData=[[NSMutableData data] retain];
	} else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[myWebData setLength: 0];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[myWebData appendData:data];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	[self hideProgressHUD];
	[vCtrWhileParsing webRequestReceivedData:nil];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[vCtrWhileParsing webRequestReceivedData:myWebData];
	[self hideProgressHUD];
	[connection release]; 
}

//-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//	if ([challenge previousFailureCount] == 0) {
//		NSURLCredential *cred = [[[NSURLCredential alloc] initWithUser:del.strUserName password:del.strPassword
//														   persistence:NSURLCredentialPersistenceForSession] autorelease];
//		[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
//	} else {
//		[[challenge sender] cancelAuthenticationChallenge:challenge]; 
//	}
//}


- (void)hudWasHidden{
}

@end
