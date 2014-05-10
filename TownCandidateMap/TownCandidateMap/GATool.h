//
//  GATool.h
//  whatthejoesay
//
//  Created by Hokila on 2014/5/10.
//  Copyright (c) 2014年 Hokila. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GATool : NSObject
+(CLLocationCoordinate2D) TWD97TM2toWGS84:(double )x :(double)y;
@end
