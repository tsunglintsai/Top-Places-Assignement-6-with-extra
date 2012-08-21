//
//  VacationPhotoDetailViewController.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "VacationPhotoDetailViewController.h"
#import "VacationHelper.h"
#import "Itinerary+Create.h"
#import "Place+Create.h"
#import "FlickerPhoto.h"
#import "FlickrFetcher.h"
#import "Photo+FlickerPhoto.h"

@interface VacationPhotoDetailViewController ()

@end

@implementation VacationPhotoDetailViewController

- (void) viewDidLoad{
    [super viewDidLoad];
}

- (void)hideBusyIndicator{
    [super hideBusyIndicator];
    [self updateVisitUnvisitButton];
}

- (void)updateVisitUnvisitButton{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FlickerPhoto *flickerPhoto = (FlickerPhoto*)self.photo;
        [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance]currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
            NSManagedObjectContext *context = document.managedObjectContext;
            [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
                NSString *buttonLabel;
                if([Photo flickrPhotoExist:flickerPhoto inManagedObjectContext:context]){
                    buttonLabel = @"Unvisit";
                }else{
                    buttonLabel = @"Visit";
                }
                UIBarButtonItem * barButton = [[UIBarButtonItem alloc]initWithTitle:buttonLabel style:UIBarButtonItemStyleBordered target:self action:@selector(vistUnvistButtonClicked)];
                self.navigationItem.rightBarButtonItem =  barButton;
            }];
        }];
    });
}

- (void)vistUnvistButtonClicked{
    NSLog(@"vistUnvistButtonClicked");
    self.navigationItem.rightBarButtonItem = nil;
    if([self.photo isKindOfClass:[FlickerPhoto class]]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FlickerPhoto *flickerPhoto = (FlickerPhoto*)self.photo;
            NSString *placeName = [flickerPhoto.photoData objectForKey:FLICKR_PHOTO_PLACE_NAME];
            NSData *photoData = UIImagePNGRepresentation(flickerPhoto.largeImage);
            [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance]currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
                NSManagedObjectContext *context = document.managedObjectContext;
                [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
                    NSError *error;
                    if([Photo flickrPhotoExist:flickerPhoto inManagedObjectContext:context]){ // unvisit photo
                        Photo *photo = [Photo photoWithFlickrPhoto:flickerPhoto withPhotoData:photoData inManagedObjectContext:context];
                        [context deleteObject:photo];
                    }else{ // visit photo
                        Itinerary *itinerary = [Itinerary itineraryInManagedObjectContext:context];
                        Photo *photo = [Photo photoWithFlickrPhoto:flickerPhoto withPhotoData:photoData inManagedObjectContext:context];
                        Place *place = [Place placeWithName:placeName inManagedObjectContext:context];
                        place.vacation = itinerary;
                        photo.placeTookThisPhoto = place;
                    }
                    [context save:&error];
                    if(error){
                        NSLog(@"ERROR:%@",[error description]);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{ // back to main queue to update UI
                        [self updateVisitUnvisitButton];
                    });
                }];
            }];
        });
    }
}
@end
