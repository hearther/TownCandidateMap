//
//  TCCandidateViewController.h
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCandidateViewController : UIViewController
{
    IBOutlet UILabel *grade;
    IBOutlet UILabel *politicalParty;
    IBOutlet UIImageView *headerView;
    NSDictionary *candidateInformation;
}
- (instancetype)initWithCandidateDictionary:(NSDictionary *)inDictionary;
- (void)reloadData;
@property (nonatomic, strong) NSDictionary *candidateDictionary;
@end
