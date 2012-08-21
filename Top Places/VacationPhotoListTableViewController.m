//
//  VacationPhotoListTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/17/12.
//
//

#import "VacationPhotoListTableViewController.h"
#import "VacationHelper.h"
#import <CoreData/CoreData.h>
#import "Tag+Create.h"
#import "PhotoListViewController.h"
#import "VacationPhoto.h"
#import "PhotoDetailViewController.h"
#import "VacationPhoto.h"
#import "PhotoMapViewController.h"
#import "PhotoAnnotation.h"

@interface VacationPhotoListTableViewController ()<PhotoMapViewControllerDelegate>
@property (strong,nonatomic) MapViewController* displayMapViewController;
@end

@implementation VacationPhotoListTableViewController
@synthesize listTitle = _listTitle;
@synthesize predicate = _predicate;

-(void)viewDidLoad{
    self.navigationItem.title = self.listTitle;
}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"vid did disappare");
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");

    [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance] currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
        //request.predicate = [NSPredicate predicateWithFormat:@"tags.name contains %@", @"Amaro"];
        request.predicate = self.predicate;
        self.fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:document.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoDetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        PhotoDetailViewController *photoDetailViewController = segue.destinationViewController;
        VacationPhoto *vacationPhoto = [[VacationPhoto alloc]init];
        vacationPhoto.photo = photo;
        photoDetailViewController.photo = vacationPhoto;
        photoDetailViewController.photoTitle = photo.title;
    }else if ([segue.identifier isEqualToString:@"PushToPhotoMapView"]) {
        [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance]currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoId" ascending:YES ]];
            request.predicate = self.predicate;
            NSError *error;
            NSArray *matches = [document.managedObjectContext executeFetchRequest:request error:&error];
            if(error){
                NSLog(@"error in fetching data");
            }else{
                MapViewController *mapViewController;
                if(self.splitViewController == nil){ // iphone
                    UINavigationController *navigationController = segue.destinationViewController;
                    mapViewController = (MapViewController*) navigationController.visibleViewController;
                }else{
                    mapViewController = segue.destinationViewController;
                }
                
                NSMutableArray *annotations = [[NSMutableArray alloc]initWithCapacity:[matches count]];
                for( Photo *photo in matches){
                    [annotations addObject:[PhotoAnnotation annotationForPhoto:[photo toFlickerPhoto]]];
                }
                mapViewController.annotations = annotations;
                mapViewController.delegate = self;
                self.displayMapViewController = mapViewController;
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center removeObserver:self
                                  name:NSManagedObjectContextObjectsDidChangeNotification
                                object:document.managedObjectContext];
                [center addObserver:self
                           selector:@selector(contextChanged:)
                               name:NSManagedObjectContextObjectsDidChangeNotification
                             object:document.managedObjectContext];
                
            }
        }];
    }
}

- (void)contextChanged:(NSNotification *)notification{
    NSLog(@"contextChanged:map");
    if(self.displayMapViewController!=nil){
         [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance]currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
             NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
             request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoId" ascending:YES ]];
             request.predicate = self.predicate;
             NSError *error;
             NSArray *matches = [document.managedObjectContext executeFetchRequest:request error:&error];
             if(error){
                 NSLog(@"error in fetching data");
             }else{
                 MapViewController *mapViewController = self.displayMapViewController;
                 NSMutableArray *annotations = [[NSMutableArray alloc]initWithCapacity:[matches count]];
                 for( Photo *photo in matches){
                     [annotations addObject:[PhotoAnnotation annotationForPhoto:[photo toFlickerPhoto]]];
                 }
                 mapViewController.annotations = annotations;
             }
         }];
    }
}
         
#pragma mark - MapViewControllerDelegate call back

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation{
    return ((PhotoAnnotation*)annotation).photo.smallImage;
}

- (id<TopPlacesPhotoProtocol>)mapViewController:(MapViewController *)sender photoForAnnotation:(id <MKAnnotation>)annotation{
    return ((PhotoAnnotation*)annotation).photo;
}
- (BOOL) mapViewController:(MapViewController *)sender
       samePhotoAnnotation:(id <MKAnnotation>)annotation1
         asPhotoAnnotation:(id <MKAnnotation>)annotation2{
    id<TopPlacesPhotoProtocol> selectedPhoto1 = ((PhotoAnnotation*)annotation1).photo;
    id<TopPlacesPhotoProtocol> selectedPhoto2 = ((PhotoAnnotation*)annotation2).photo;
    if([selectedPhoto1.photoId isEqual:selectedPhoto2.photoId]){
        return true;
    }
    return false;
}
@end
