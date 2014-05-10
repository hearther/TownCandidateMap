//
//  ViewController.h
//  MapOLSample
//
//  Created by Spark on 2/10/12.
//  Copyright (c) 2012 http://Sugartin.info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchXML.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "PlaceMark.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) NSArray *arOfStates;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)addOverLays ;

@end
