@import Foundation;
@import CoreLocation;

@interface GATool : NSObject

/*
 convert TW97 to WGS84
 reference from http://napmas.blogspot.tw/2011/05/umt-twd97tm2-wgs84.html
 */
+(NSDictionary*) TWD97TM2toWGS84:(double )x :(double)y;

@end
