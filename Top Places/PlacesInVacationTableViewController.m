//
//  PlacesInVacationTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "PlacesInVacationTableViewController.h"
#import "Itinerary+Create.h"
#import "Place+Create.h"
#import "VacationHelper.h"
#import "PhotoListViewController.h"
#import "VacationPhoto.h"
#import "VacationPhotoListTableViewController.h"

@interface PlacesInVacationTableViewController ()<PhotoListViewControllerDelegate>
@property (nonatomic,strong) NSOrderedSet *placeList;
@end

@implementation PlacesInVacationTableViewController
@synthesize placeList = _placeList;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.vacationName;
    self.navigationItem.rightBarButtonItem =  self.editButtonItem;
    
}


-(void)reloadData{
    [self cleanPlaceWithoutPicture];
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        Itinerary *itinerary = [Itinerary itineraryInManagedObjectContext:context];
        self.placeList = [itinerary.places copy];
        [self.tableView reloadData];
    }];
}

- (void) viewWillAppear:(BOOL)animated{
    [self reloadData];
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(contextChanged:)
                       name:NSManagedObjectContextObjectsDidChangeNotification
                     object:document.managedObjectContext];
        
    }];
}

- (void) viewWillDisappear:(BOOL)animated{
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self
                          name:NSManagedObjectContextObjectsDidChangeNotification
                        object:document.managedObjectContext];
    }];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cleanPlaceWithoutPicture{
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            for(Place *place in matches){
                if([place.photos count]==0){
                    [document.managedObjectContext deleteObject:place];
                }
            }
            [document.managedObjectContext save:&error];
        }];
    }];
}

- (void)contextChanged:(NSNotification *)notification{
    NSLog(@"contextChanged");
    [self reloadData];
}

#pragma mark - Table view reorder content

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing == YES)
    {
        NSLog(@"Your code for entering edit mode goes here");
    } else {
        [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
            NSManagedObjectContext *context = document.managedObjectContext;
            Itinerary *itinerary = [Itinerary itineraryInManagedObjectContext:context];
            itinerary.places = self.placeList;
            NSError *error;
            [context save:&error];
            if(error){
                NSLog(@"fail to save new place order:%@",[error description]);
            }else{
                NSLog(@"save successfully");
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Place *place = [self.placeList objectAtIndex:indexPath.row];
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i photos",[place.photos count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"reorder : %i -> %i",fromIndexPath.row,toIndexPath.row);
    NSMutableOrderedSet *newPlaceList = [self.placeList mutableCopy];
    [newPlaceList moveObjectsAtIndexes:[[NSIndexSet alloc]initWithIndex:fromIndexPath.row] toIndex:toIndexPath.row];
    self.placeList = newPlaceList;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - PhotoListViewControllerDelegate Methods
- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected{
    NSLog(@"photo selected");
}

#pragma mark - Segueway Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoListSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Place *selectedPlace = [self.placeList objectAtIndex:indexPath.row];
        VacationPhotoListTableViewController *vacationPhotoListTableViewController = segue.destinationViewController;
        vacationPhotoListTableViewController.listTitle = selectedPlace.name;
        vacationPhotoListTableViewController.predicate = [NSPredicate predicateWithFormat:@"placeTookThisPhoto.name contains %@", selectedPlace.name];
    }
}

@end
