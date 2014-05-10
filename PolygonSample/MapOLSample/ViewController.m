//
//  ViewController.m
//  MapOLSample
//
//  Created by Spark on 2/10/12.
//  Copyright (c) 2012 http://Sugartin.info. All rights reserved.
//

#import "ViewController.h"
#import "WebRqst.h"
#import "Global.h"

@implementation ViewController
@synthesize arOfStates = _arOfStates;
@synthesize mapView = _mapView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // get state location details from this URL
    [Global startLoading:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://econym.org.uk/gmap/states.xml"]] vCtr:self]; 
}

// parse the states response & store it into an array
-(void)webRequestReceivedData:(NSData *)data {
    
    // create a document based on the response of URl
    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:data options:0 error:nil];
    
    // grab all the nodes within states tag
    NSArray *arStates = [doc nodesForXPath:@"//states/*" error:nil];
    
    // this array will add parsed data of states
    NSMutableArray *arOfStates=[NSMutableArray array];
    NSUInteger index = 0;
    
    // foreach loop to go through all state node 
    for (CXMLNode *nodeState in arStates) {
        
        // ensure that your accessing the state node only
        if([nodeState name] && [[nodeState name] isEqualToString:@"state"]) {
            
            // grab all the sub-tags / children nodes
            NSArray *arPoints = [nodeState children];
            
            // an array which will hold all points of state
            NSMutableArray *arOfPoints = [NSMutableArray array];
            
            // foreach loop to go through all point nodes of specific state
            for (CXMLNode *nodePoint in arPoints) {
                
                // ensure that your accessing point node only
                if([nodePoint name] && [[nodePoint name] isEqualToString:@"point"]) {
                    // get the attributes of point node 
                    NSArray *atrArray = [(CXMLElement*)nodePoint attributes];
                    
                    // attribute0 = lat & attribute1=lng 
                    // create a dictionary based on these two values & add it into points array of a specific state
                    [arOfPoints addObject:[NSDictionary dictionaryWithObjectsAndKeys:[(CXMLNode*)[atrArray objectAtIndex:0] stringValue],@"lat",[(CXMLNode*)[atrArray objectAtIndex:1] stringValue],@"lng", nil]];
                }
            }
            // add a specific state dictionary into array of states
            [arOfStates addObject:[NSDictionary dictionaryWithObjectsAndKeys:arOfPoints,@"points",[(CXMLNode*)[[(CXMLElement*)nodeState attributes] objectAtIndex:0] stringValue],@"name",[NSNumber numberWithInt:index++],@"id",nil]];
        }
    }
    self.arOfStates=arOfStates;
    // once we done with parsing logic
    // we will add overlays
    [self addOverLays];
}

- (void)addOverLays {
    // for each loop to access each state
    for (NSDictionary *dState in self.arOfStates) {
        
        // get the points of a specific state
        NSArray *arOfPoints = [dState valueForKey:@"points"];
        
        // alloc all co-ordinates at once. mandatory
        CLLocationCoordinate2D *pointsCoOrds = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D) * [arOfPoints count]);
        NSUInteger index = 0;
        
        // for each loop to access all points of specific state
        for (NSDictionary *dPoint in [dState valueForKey:@"points"]) {
            CGFloat lat = [[dPoint valueForKey:@"lat"] floatValue];
            CGFloat lng = [[dPoint valueForKey:@"lng"] floatValue];
            // set the location details to appropriate index of array of Co-ordinates
            pointsCoOrds[index++] = CLLocationCoordinate2DMake(lat,lng);
        }
        
        // create a polygon based on the array of co-ordinates
        MKPolygon *polygon =[MKPolygon polygonWithCoordinates:pointsCoOrds count:[arOfPoints count]];
        
        // assigning the index of array to polygon object - which can be helpful for next methods
        [polygon setTitle:[[dState valueForKey:@"id"] stringValue]];
        [self.mapView addOverlay:polygon];
    }
    // add annotations on map after some delay
    [self performSelector:@selector(addAnnotationsOnMap) withObject:nil afterDelay:3];
}

// add polygonView based on polygonOverlay object
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
    // create a polygonView using polygon_overlay object
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    
    // applying line-width
    polygonView.lineWidth = 1.5;
    
    // a code to create generate random number, which will be helpful to generate random color
    int color = arc4random()%3;
    UIColor *colorValue = (color==0)?[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1] : (
    (color==1)? [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1] : [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1] );
    
    // apply stroke & fill color
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    polygonView.fillColor = colorValue;

    return polygonView;
}

// once we done with adding polygonOverlays, we will add appropriate pins over google map
- (void)addAnnotationsOnMap {  
    // foreach loop, which will access all polygons_overlay added over the mapView
    for (MKPolygon *polyGon in self.mapView.overlays) {
        // access the index - go to line number 102 to understand the index
        NSUInteger index = [[polyGon title] intValue];
        
        // create a Place object
        Place* home = [[Place alloc] init];
        // assign title
        home.name = [[self.arOfStates objectAtIndex:index] valueForKey:@"name"];
        
        // access the location details of polygon
        CLLocationCoordinate2D coOrd = [polyGon coordinate];
        
        // add description if any
        //        home.description=[d valueForKey:@"address"];
        
        // set the location details to HOME object
        home.latitude = coOrd.latitude;
        home.longitude = coOrd.longitude;
        
        // based on homeObject create, placeMark object (annotation)
        PlaceMark* from = [[PlaceMark alloc] initWithPlace:home];
        
        // add anotation to map
        [self.mapView addAnnotation:from];
    }
}

// setting up the google pin
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // static identifier for map-pin for re-usablility
    static NSString * const kPinAnnotationIdentifier2 = @"PinIdentifierOtherPins";
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: kPinAnnotationIdentifier2];
    
    // if pin is not dequeued
    if(!pin) {
        // create a new pin
        pin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier2];
        pin.userInteractionEnabled = YES;
        // create a button
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosureButton setFrame:CGRectMake(0, 0, 30, 30)];
        
        // set button as callOut accessory
        pin.rightCalloutAccessoryView = disclosureButton;
        
        // set annotation color
        pin.pinColor = MKPinAnnotationColorGreen;
        
        // set animation for drop on.
        pin.animatesDrop = YES;
        
        // set enabled yes - to access it.
        [pin setEnabled:YES];
        
        // set canShowCallout yes - which will open pop-up as given in the screen-shot.
        [pin setCanShowCallout:YES];
    }
    return pin;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
