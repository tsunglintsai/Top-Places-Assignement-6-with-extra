//
//  VacationFunctionListTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import "VacationFunctionListTableViewController.h"
#import "VacationHelper.h"
#import "Itinerary+Create.h"
#import "Place+Create.h"
#import "PlacesInVacationTableViewController.h"
#import "TagTableViewController.h"

@interface VacationFunctionListTableViewController ()

@end

@implementation VacationFunctionListTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.vacationName;
}
#pragma mark - Segueway Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"VacationFunctionListTableViewController:prepareForSegue");
    if ([segue.identifier isEqualToString:@"pushToPlacesListInVacationSegue"]) {
        PlacesInVacationTableViewController *placesInVacationTableViewController = segue.destinationViewController;
        placesInVacationTableViewController.vacationName = self.vacationName;
    }else if([segue.identifier isEqualToString:@"pushToTagListInVacationSegue"]) {
        TagTableViewController *tagTableViewController = segue.destinationViewController;
        tagTableViewController.vacationName = self.vacationName;
    }
}

@end
