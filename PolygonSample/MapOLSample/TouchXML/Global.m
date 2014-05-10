//
//  Global.m
//  http://Sugartin.info
//
//  Created by Neon Spark on 15/10/10.
//  Copyright 2010 http://Sugartin.info. All rights reserved.
//

#import "Global.h"
#import "WebRqst.h"


static WebRqst *rqstObj;
static UIView *gView;
static NSString *domainURL;
static NSMutableArray *arForImages;

#define kImageArray [Global arrayOfImages]

@implementation Global

+(void)initialize{
	rqstObj=[[WebRqst alloc] init];
	arForImages=[[NSMutableArray alloc] init];
}

+(NSString*)domainURL{
	return domainURL;
}

+(NSMutableArray*)arrayOfImages{
	return arForImages;
}

+(void)setView:(UIView*)setV{
	gView=[setV retain];
}

+(UIView*)view{
	return gView;
}

+(void)startLoading:(NSMutableURLRequest*)urlRequest vCtr:(UIViewController*)vCtrRef{
	[rqstObj startLoading:urlRequest vCtr:vCtrRef];
}

+(NSMutableURLRequest*)urlRequestAction:(NSString*)sa_Name message:(NSString*)sm_msg{
	NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:domainURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	[urlReq addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[urlReq addValue:sa_Name forHTTPHeaderField:@"SOAPAction"];
	[urlReq setHTTPMethod:@"POST"];
	[urlReq setHTTPBody: [sm_msg dataUsingEncoding:NSUTF8StringEncoding]];
	return urlReq;	
}


+(NSString*)SA_synchronise{
	return @"http://tempuri.org/SyncronizeData";
}

+(NSString*)SM_synchronise{
	return @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><SyncronizeData xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>";
}


+(NSString*)SA_SearchAction{
	return @"http://tempuri.org/GetSearchResults";
}

+(NSString*)SM_Search_BrandID:(NSString*)brandID modelID:(NSString*)modelID From:(NSString*)from to:(NSString*)to countryID:(NSString*)countryID{
	return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetSearchResults xmlns=\"http://tempuri.org/\"><pBrandId>%@</pBrandId><pModelId>%@</pModelId><pFrom>%@</pFrom><pTo>%@</pTo><pCountryID>%@</pCountryID></GetSearchResults></soap:Body></soap:Envelope>",brandID,modelID,from,to,countryID];
}

+(NSString*)SA_ModelImages{
	return @"http://tempuri.org/GetImages";
}

+(NSString*)SM_ModelImages:(NSString*)modelID{
	return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetImages xmlns=\"http://tempuri.org/\"><Pid>%@</Pid></GetImages></soap:Body></soap:Envelope>",modelID];
	
}

+(NSString*)SA_FavouriteRefresh{
	return @"http://tempuri.org/GetFavoriteDetails";
}

+(NSString*)SM_FavouriteRefreshModelIDs:(NSString*)modelIDs{
	return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetFavoriteDetails xmlns=\"http://tempuri.org/\"><pProductIds>%@</pProductIds></GetFavoriteDetails></soap:Body></soap:Envelope>",modelIDs];
}

@end


