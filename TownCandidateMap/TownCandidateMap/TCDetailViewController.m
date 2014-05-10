#import "TCDetailViewController.h"
#import "TCMapAnnotation.h"
#import "TCPickerViewController.h"

@import MapKit;
@interface TCDetailViewController ()
{
    MKMapView *mapView;
    UIPopoverController *popOverController;
    
    NSDictionary* counties;
    NSDictionary* towns;
    NSDictionary* town2county;
    NSDictionary* county2towns;
    
    NSUInteger selectedCountyIndex;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (assign, nonatomic) NSUInteger selectedCountyIndex;
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
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    NSLog(@"");
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return counties.allValues[row];
    }
    else if (component == 1) {
        NSString *townKey = county2towns[counties.allKeys[selectedCountyIndex]][row];
        return towns[townKey];
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
        [pickerViewController.pickerView reloadComponent:1];
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
    self.selectedCountyIndex = 0;
    [popOverController dismissPopoverAnimated:YES];
}

@synthesize mapView;
@synthesize popOverController;
@synthesize selectedCountyIndex;
@end
