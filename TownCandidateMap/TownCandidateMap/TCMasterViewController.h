//
//  TCMasterViewController.h
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCDetailViewController;

@interface TCMasterViewController : UITableViewController

@property (strong, nonatomic) TCDetailViewController *detailViewController;

@end
