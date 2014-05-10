#import "TCDetailViewController.h"
#import "TCMapAnnotation.h"

@import MapKit;
@interface TCDetailViewController ()
{
    MKMapView *mapView;
    
    NSDictionary* counties;
    NSDictionary* towns;
    NSDictionary* town2county;
    NSDictionary* county2towns;
}
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
    
    NSArray *arcs = dic[@"arcs"];
    NSArray * bbox = dic[@"bbox"];
    NSDictionary* objects = dic[@"objects"];
    NSDictionary* transform = dic[@"transform"];
    NSString* type = dic[@"type"];
    
    
    [self addpolygon];
    
    NSLog(@"");
}

-(void)addpolygon{
    CLLocationCoordinate2D libComPark[4];
    
    libComPark[0] = CLLocationCoordinate2DMake(33.874689,-98.520148);
    libComPark[1] = CLLocationCoordinate2DMake(33.87469,-98.519692);
    libComPark[2] = CLLocationCoordinate2DMake(33.874314,-98.519687);
    libComPark[3] = CLLocationCoordinate2DMake(33.874316,-98.520146);
    
    MKPolygon *polLibcomPark = [MKPolygon polygonWithCoordinates:libComPark count:4];
    
    [mapView addOverlay:polLibcomPark];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolygon class]])
	{
		MKPolygonView* aView = [[MKPolygonView alloc]initWithPolygon:(MKPolygon*)overlay];
		aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
		aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
		aView.lineWidth = 3;
		return aView;
	}
	return nil;
}
@synthesize mapView;
@end
