//
//  TCDetailViewController.h
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TCDetailViewController : UIViewController <UISplitViewControllerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
