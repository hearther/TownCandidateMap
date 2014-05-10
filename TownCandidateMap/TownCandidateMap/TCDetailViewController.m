#import "TCDetailViewController.h"
#import "TCMapAnnotation.h"
#import "TCPickerViewController.h"
#import "GATool.h"
#import "PlaceMark.h"

@import MapKit;
@interface TCDetailViewController ()
{
    MKMapView *mapView;
    UIPopoverController *popOverController;
    
    NSDictionary* counties;
    NSDictionary* towns;
    NSDictionary* town2county;
    NSDictionary* county2towns;
    
    UIButton *locationButton;
    NSUInteger selectedCountyIndex;
    NSString *selectedCountyName;
    NSString *selectedTownName;
}
@property (nonatomic,strong) NSArray* arOfStates;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (assign, nonatomic) NSUInteger selectedCountyIndex;
@property (strong, nonatomic) NSString *selectedCountyName;
@property (strong, nonatomic) NSString *selectedTownName;
@property (strong, nonatomic) UIButton *locationButton;
- (void)configureView;
@end

@implementation TCDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.title = @"Map";
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.mapType = MKMapTypeStandard;
    mapView.scrollEnabled = YES;
    mapView.zoomEnabled = YES;
    mapView.delegate = self;
    [self _resetMapCenter];
    [self.view addSubview:mapView];
    [self _addToolbarToNavigationbar];
    [self readTownConunty];
}

- (void)_addToolbarToNavigationbar
{
    CGFloat toolbarHeight = 44.0;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 64.0, CGRectGetWidth(self.view.frame), toolbarHeight)];
    toolbar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolbar];

    CGFloat countyButtonWidth = 100.0;
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(300.0, 1.0, countyButtonWidth, 43.0);
    [locationButton setTitle:@"Location" forState:UIControlStateNormal];
    [locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    locationButton.backgroundColor = [UIColor whiteColor];
    [locationButton.layer setMasksToBounds:YES];
    [locationButton.layer setCornerRadius:10.0f];
    [locationButton.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    locationButton.layer.borderColor = [UIColor blueColor].CGColor;
    locationButton.layer.borderWidth = 1.0;
    [locationButton addTarget:self action:@selector(_locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:locationButton];
}


- (void)_locationButtonClicked:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    TCPickerViewController *pickerViewController = [[TCPickerViewController alloc] init];
    pickerViewController.pickerViewDelegate = self;
    pickerViewController.pickerViewDatasource = self;
    pickerViewController.pickerViewControllerDelegate = self;
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:pickerViewController];
    popOverController.popoverContentSize = CGSizeMake(320.0, 300.0);
    [popOverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)_resetMapCenter
{
#warning test data
    //25.040205, 121.512812
    //    lat = "0.4361032193958104";  lng = "121.0095478850263";

    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(25.040205, 121.512812);
	mapView.region = MKCoordinateRegionMakeWithDistance(location, 1000 * 2, 1000 * 2);
	mapView.centerCoordinate = location;
    
    TCMapAnnotation *annotation = [[TCMapAnnotation alloc] initWithCoordinate:location title:@"testTitle" subtitle:@"testSubleTitle"];
    [mapView addAnnotation:annotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Candidates", @"Candidates");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
#pragma -mark
-(void)readTownConunty{
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"list" ofType:@"json"];
    NSError *error = nil;
    
    NSString* jsonString = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        counties = [[NSDictionary alloc]initWithDictionary:dic[@"counties"]];
        towns = [[NSDictionary alloc]initWithDictionary:dic[@"towns"]];
        town2county = [[NSDictionary alloc]initWithDictionary:dic[@"town2county"]];
        county2towns = [[NSDictionary alloc]initWithDictionary:dic[@"county2towns"]];
        
        //        NSLog(@"%d %d %d %d",[counties count],[towns count], [town2county count], [county2towns count]);
        //        NSLog(@"%@",[counties valueForKey:@"63000"]);
        
        [self showTowns:@"63000"];
    }
}

-(void)showTowns:(NSString*)countyID{
    NSArray* showtowns = county2towns[countyID];
    
    [showtowns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString*polygonfileName = [NSString stringWithFormat:@"%@_%@",countyID,obj];
        [self readPolygonInfo:polygonfileName];
        
        *stop = YES;
    }];
}

-(void)readPolygonInfo:(NSString*)fileName{
    NSString* filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSError *error = nil;
    
    NSString* jsonString = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
//    NSArray *arcs = dic[@"arcs"];
//    NSArray * bbox = dic[@"bbox"];
    NSDictionary* objects = dic[@"objects"];
//    NSDictionary* transform = dic[@"transform"];
//    NSString* type = dic[@"type"];
    
    [self addpolygon:objects];
    
    NSLog(@"");
}


-(void)addpolygon:(NSDictionary*)objects{
    //find object and add to self.arOfStates
    NSDictionary* layer = objects[@"layer1"];
    NSArray* geometries = layer[@"geometries"];
    
    NSMutableArray* objectsQQ = [NSMutableArray array];
    //一層一層又一層層
    NSMutableArray *arOfPoints = [NSMutableArray array];
    NSUInteger index = 0;
    
    for (NSDictionary* geoObj in geometries) {
        if ([geoObj[@"type"] isEqualToString:@"Polygon"]) {
            NSDictionary* properties = geoObj[@"properties"];
            double X = [properties[@"X"] doubleValue];
            double Y = [properties[@"Y"] doubleValue];
            NSDictionary* loaction = [GATool TWD97TM2toWGS84:X :Y];
            //            NSLog(@"TW97 :%f,%f",X,Y);
            //            NSLog(@"WS794:%f,%f",[loaction[@"lat"] doubleValue],[loaction[@"lng"] doubleValue]);
            [arOfPoints addObject:loaction];
        }
    }
    
    [objectsQQ addObject:@{@"points":arOfPoints,
                           @"name":@"",
                           @"id":[NSNumber numberWithInt:index++]}];
    
    self.arOfStates = objectsQQ;
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
        //        [polygon setTitle:[[dState valueForKey:@"id"] stringValue]];
        [self.mapView addOverlay:polygon];
    }
    // add annotations on map after some delay
    [self performSelector:@selector(addAnnotationsOnMap) withObject:nil afterDelay:3];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    // create a polygonView using polygon_overlay object
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    
    // applying line-width
    polygonView.lineWidth = 1.5;
    
    // a code to create generate random number, which will be helpful to generate random color
    int color = arc4random()%3;
    UIColor *colorValue = (color==0)?[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1] : (
                                                                                              (color==1)? [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1] : [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1] );
    
    // apply stroke &amp; fill color
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    polygonView.fillColor = colorValue;
    
    return polygonView;
}

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


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        NSString *countyName = counties.allValues[row];
        self.selectedCountyName = countyName;
        return countyName;
    }
    else if (component == 1) {
        NSString *townKey = county2towns[counties.allKeys[selectedCountyIndex]][row];
        NSString *townName = towns[townKey];
        self.selectedTownName = townName;
        return townName;
    }
    
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 160.0;
    
    return sectionWidth;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedCountyIndex = row;
        TCPickerViewController *pickerViewController = (TCPickerViewController *)popOverController.contentViewController;
        [pickerViewController.pickerView reloadAllComponents];
    }
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [counties.allValues count];
    }
    else if (component == 1) {
        return [county2towns[counties.allKeys[selectedCountyIndex]] count];
    }
    
    return 0;
}

#pragma mark - TCPickerViewControllerDelegate

- (void)pickerViewControllerDidDismiss:(TCPickerViewController *)inViewController
{
    NSString *locationString = [NSString stringWithFormat:@"%@ %@", selectedCountyName, selectedTownName];
    [locationButton setTitle:locationString forState:UIControlStateNormal];
    [locationButton sizeToFit];
    self.selectedCountyIndex = 0;
    [popOverController dismissPopoverAnimated:YES];
}


@synthesize mapView;
@synthesize popOverController;
@synthesize selectedCountyIndex;
@synthesize selectedCountyName;
@synthesize selectedTownName;
@synthesize locationButton;
@end
