//
//  VacationCreationTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/18/12.
//
//

#import "VacationCreationTableViewController.h"
#import "VacationHelper.h"

@interface VacationCreationTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *vacationNameField;

@end

@implementation VacationCreationTableViewController
@synthesize vacationNameField;

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.vacationNameField becomeFirstResponder];
}

- (IBAction)cancelBUttonClicked:(id)sender {
    [self.delegate didCacnelCreation];
}

- (IBAction)doneButtonClicked:(id)sender {
    [self.delegate vacationCreationTableViewController:self didEnterNameOfVacation:self.vacationNameField.text];
}

- (void)viewDidUnload {
    [self setVacationNameField:nil];
    [super viewDidUnload];
}
@end
