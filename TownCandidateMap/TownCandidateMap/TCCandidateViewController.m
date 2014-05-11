//
//  TCCandidateViewController.m
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import "TCCandidateViewController.h"

@interface TCCandidateViewController ()
@end

@implementation TCCandidateViewController

- (instancetype)initWithCandidateDictionary:(NSDictionary *)inDictionary
{
    if (self = [super init]) {
        self.candidateDictionary = inDictionary;
    }
    return self;
}

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
    [self reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    grade.text = candidateDictionary[@"grade"];
    politicalParty.text = candidateDictionary[@"politicalParty"];
    headerView.image = [UIImage imageNamed:@"man"];
}

@synthesize candidateDictionary;
@end
