//
//  VacationTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import "VacationListTableViewController.h"
#import "VacationHelper.h"
#import "VacationFunctionListTableViewController.h"
#import "VacationCreationTableViewController.h"


@interface VacationListTableViewController ()<VacationCreationTableViewControllerDelegate>
@property (strong,nonatomic) NSArray *vacationNameList;
@end

@implementation VacationListTableViewController
@synthesize vacationNameList = _vacationNameList;

- (NSArray*) vacationNameList{
    if(_vacationNameList==nil){
        _vacationNameList = [[VacationHelper sharedInstance]getVacationNameList];
    }
    return _vacationNameList;
}

- (void) reloadData{
    self.vacationNameList = nil; // reload document list when views appear
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated{
    [self reloadData];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vacationNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.vacationNameList objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Segueway Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"pushToVacationSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        VacationFunctionListTableViewController *vacationFunctionListTableViewController = segue.destinationViewController;
        vacationFunctionListTableViewController.vacationName = [self.vacationNameList objectAtIndex:indexPath.row];
        [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[self.vacationNameList objectAtIndex:indexPath.row] toExecuteBlock:^(UIManagedDocument *document){}];
    }else if([segue.identifier isEqualToString:@"VacationCreationModelSeque"]){
        VacationCreationTableViewController *vacationCreationTableViewController = segue.destinationViewController;
        vacationCreationTableViewController.delegate = self;
    }
}
#pragma mark - VacationCreationTableViewControllerDelegate Call Back Methods

- (void)didCacnelCreation{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)vacationCreationTableViewController:(VacationCreationTableViewController *)sender
                     didEnterNameOfVacation:(NSString *)vacationName{
    [self dismissModalViewControllerAnimated:YES];
    [[VacationHelper sharedInstance] createDocumentForVacation:vacationName completionHandler:^(BOOL success){
        [self reloadData];        
    }];
}
@end
