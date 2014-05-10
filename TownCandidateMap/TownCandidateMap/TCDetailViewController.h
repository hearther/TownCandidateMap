#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TCPickerViewController.h"

@interface TCDetailViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate, UISplitViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, TCPickerViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
