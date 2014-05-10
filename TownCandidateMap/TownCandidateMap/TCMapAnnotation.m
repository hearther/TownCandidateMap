//
//  TCMapAnnotation.m
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import "TCMapAnnotation.h"

@implementation TCMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)inCoordinate title:(NSString *)inTitle subtitle:(NSString *)inSubtitle
{
	if (self = [super init]) {
		coordinate = inCoordinate;
		title = inTitle;
		subtitle = inSubtitle;
	}
	return self;
}

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@end
