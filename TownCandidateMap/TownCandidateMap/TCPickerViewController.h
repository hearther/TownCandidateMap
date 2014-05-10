#import <UIKit/UIKit.h>
@class TCPickerViewController;

@protocol TCPickerViewControllerDelegate <NSObject>

- (void)pickerViewControllerDidDismiss:(TCPickerViewController *)inViewController;

@end
@interface TCPickerViewController : UIViewController
@property (nonatomic, assign) id <UIPickerViewDelegate> pickerViewDelegate;
@property (nonatomic, assign) id <UIPickerViewDataSource> pickerViewDatasource;
@property (nonatomic, assign) id <TCPickerViewControllerDelegate> pickerViewControllerDelegate;
@property (nonatomic, strong) UIPickerView *pickerView;
@end
