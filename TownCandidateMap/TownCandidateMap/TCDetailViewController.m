#import "TCDetailViewController.h"
#import "TCMapAnnotation.h"
#import "GATool.h"

@import MapKit;
@interface TCDetailViewController ()
{
    MKMapView *mapView;
    
    NSDictionary* counties;
    NSDictionary* towns;
    NSDictionary* town2county;
    NSDictionary* county2towns;
}
@property (nonatomic,strong) NSArray* arOfStates;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) MKMapView *mapView;
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
    
    [self readTownConunty];
}

- (void)_resetMapCenter
{
#warning test data
    //25.040205, 121.512812

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
//    [self performSelector:@selector(addAnnotationsOnMap) withObject:nil afterDelay:3];
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
@synthesize mapView;
@end
