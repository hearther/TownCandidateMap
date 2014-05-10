//
//  TCMasterViewController.m
//  TownCandidateMap
//
//  Created by joehsieh on 5/10/14.
//  Copyright (c) 2014 TC. All rights reserved.
//

#import "TCMasterViewController.h"
#import "TCDetailViewController.h"
#import "TCCandidateViewController.h"

@interface TCMasterViewController () {
    NSMutableArray *_objects;
    TCCandidateViewController *selectedCandidateViewController;
}
@property (nonatomic, strong) TCCandidateViewController *selectedCandidateViewController;
@end

@implementation TCMasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (TCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.title = @"Candidates";
    
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
#warning test data
    [_objects addObjectsFromArray:@[@{@"name" : @"吳育昇", @"grade" : @"這不好說",  @"politicalParty": @"果民黨"},
                                   @{@"name" : @"錢薇娟", @"grade" : @"籃球很強",   @"politicalParty": @"果民黨"}
                                    ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *dictionary = _objects[indexPath.row];
    cell.textLabel.text = dictionary[@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = _objects[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.detailViewController.navigationController topViewController] == selectedCandidateViewController) {
        selectedCandidateViewController.candidateDictionary = dictionary;
        [selectedCandidateViewController reloadData];
        return;
    }
    self.selectedCandidateViewController = [[TCCandidateViewController alloc] initWithCandidateDictionary:dictionary];
    [self.detailViewController.navigationController pushViewController:selectedCandidateViewController animated:YES];
}

@synthesize selectedCandidateViewController;
@end
