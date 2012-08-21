//
//  TagTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "TagTableViewController.h"
#import "VacationHelper.h"
#import <CoreData/CoreData.h>
#import "Tag+Create.h"
#import "PhotoListViewController.h"
#import "VacationPhoto.h"
#import "VacationPhotoListTableViewController.h"




@interface TagTableViewController ()<PhotoListViewControllerDelegate,UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic,strong) NSArray *tagList;
@property (nonatomic,strong) NSArray *tagSearchList;
@end

@implementation TagTableViewController
@synthesize vacationName = _vacationName;
@synthesize tagList = _tagList;
@synthesize tagSearchList = _tagSearchList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.vacationName;
}

-(void)reloadData{
    [self cleanTagWithoutPicture];
    NSMutableArray *tagList = [[NSMutableArray alloc]init];
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            [tagList addObjectsFromArray:matches];
            NSArray *sortedArray;
            sortedArray = [tagList sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
                Tag *tag1 = a;
                Tag *tag2 = b;
                if([[NSNumber numberWithInt:[tag2.photos count]] compare: [NSNumber numberWithInt:[tag1.photos count]]]==NSOrderedSame){
                    return [tag1.name compare: tag2.name];
                }else{	
                    return [[NSNumber numberWithInt:[tag2.photos count]] compare: [NSNumber numberWithInt:[tag1.photos count]]];
                }
            }];
            self.tagList = [sortedArray copy];
            [self.tableView reloadData];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center removeObserver:self
                              name:NSManagedObjectContextObjectsDidChangeNotification
                            object:context];
            [center addObserver:self
                       selector:@selector(contextChanged:)
                           name:NSManagedObjectContextObjectsDidChangeNotification
                         object:document.managedObjectContext];
            
            
        }];
    }];
}

- (void)cleanTagWithoutPicture{
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            for(Tag *tag in matches){
                if([tag.photos count]==0){
                    [document.managedObjectContext deleteObject:tag];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void) viewDidUnload{
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center removeObserver:self
                              name:NSManagedObjectContextObjectsDidChangeNotification
                            object:context];
        }];
    }];
    
}

#pragma mark - PhotoListViewControllerDelegate Methods

- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected{
    NSLog(@"photo selected");
}


#pragma mark - Segueway Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoListSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tag *selectedTag = [self.tagList objectAtIndex:indexPath.row];
        VacationPhotoListTableViewController *vacationPhotoListTableViewController = segue.destinationViewController;
        vacationPhotoListTableViewController.listTitle = selectedTag.name;
        vacationPhotoListTableViewController.predicate = [NSPredicate predicateWithFormat:@"tags.name contains %@", selectedTag.name];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.tagSearchList count];
    }else{
        return [self.tagList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Tag *tag;
	if (tableView == self.searchDisplayController.searchResultsTableView){
        tag = [self.tagSearchList objectAtIndex:indexPath.row];
    }else{
        tag = [self.tagList objectAtIndex:indexPath.row];
        
    }
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i photos", tag.photos.count];
    return cell;
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tagSearchList = [[NSMutableArray alloc]init];
    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:self.vacationName toExecuteBlock:^(UIManagedDocument *document){
        NSManagedObjectContext *context = document.managedObjectContext;
        [context performBlockAndWait:^{ // managedObjectContext is not thread safe, make sure it's under right thread
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            request.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            [tagSearchList addObjectsFromArray:matches];
            NSArray *sortedArray;
            sortedArray = [tagSearchList sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
                Tag *tag1 = a;
                Tag *tag2 = b;
                if([[NSNumber numberWithInt:[tag2.photos count]] compare: [NSNumber numberWithInt:[tag1.photos count]]]==NSOrderedSame){
                    return [tag1.name compare: tag2.name];
                }else{
                    return [[NSNumber numberWithInt:[tag2.photos count]] compare: [NSNumber numberWithInt:[tag1.photos count]]];
                }
            }];
            self.tagSearchList = [sortedArray copy];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	if (tableView == self.searchDisplayController.searchResultsTableView){
        cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"PushToPhotoListSegue" sender:cell];
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end
