#import <UIKit/UIKit.h>
#import "TCPickerViewController.h"

@import MapKit;
@import CoreLocation;
@interface TCDetailViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate, UISplitViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, TCPickerViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
