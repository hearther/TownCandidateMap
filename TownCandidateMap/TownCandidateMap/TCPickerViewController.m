#import "TCPickerViewController.h"

@interface TCPickerViewController ()

@end

@implementation TCPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_doneButtonClicked:)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    toolbar.items = @[spaceItem, doneButton];
    [self.view addSubview:toolbar];
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44.0, 320, 300)];
    pickerView.delegate = self.pickerViewDelegate;
    pickerView.dataSource = self.pickerViewDatasource;
    pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:pickerView];
}

- (void)_doneButtonClicked:(id)sender
{
    if (pickerViewControllerDelegate && [pickerViewControllerDelegate respondsToSelector:@selector(pickerViewControllerDidDismiss:)]) {
        [pickerViewControllerDelegate pickerViewControllerDidDismiss:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@synthesize pickerView;
@synthesize pickerViewDelegate;
@synthesize pickerViewDatasource;
@synthesize pickerViewControllerDelegate;
@end
