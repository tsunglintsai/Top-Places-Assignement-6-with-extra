//
//  VacationPhotoInTagAndPlaceDetailViewController.m
//  Top Places
//
//  Created by Daniela on 8/13/12.
//
//

#import "VacationPhotoInTagAndPlaceDetailViewController.h"
#import "VacationPhoto.h"
#import "VacationHelper.h"
#import "Itinerary+Create.h"
#import "Place+Create.h"
#import "FlickerPhoto.h"
#import "FlickrFetcher.h"
#import "Photo+FlickerPhoto.h"

@interface VacationPhotoInTagAndPlaceDetailViewController ()
@end

@implementation VacationPhotoInTagAndPlaceDetailViewController
/*
- (void)updateVisitUnvisitButton{
    // don't show button
}
*/

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.photo.largeImage==nil){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateVisitUnvisitButton{
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc]initWithTitle:@"Unvisit" style:UIBarButtonItemStyleBordered target:self action:@selector(vistUnvistButtonClicked)];
    self.navigationItem.rightBarButtonItem =  barButton;
}

- (void)vistUnvistButtonClicked{
    NSLog(@"vistUnvistButtonClicked");
    self.navigationItem.rightBarButtonItem = nil;
    if([self.photo isKindOfClass:[VacationPhoto class]]){
        VacationPhoto *vacationPhoto = (VacationPhoto*) self.photo;
        [[VacationHelper sharedInstance] useSharedManagedDocumentForVacationNamed:[[VacationHelper sharedInstance]currentOpenVacationName] toExecuteBlock:^(UIManagedDocument *document){
            NSManagedObjectContext *context = document.managedObjectContext;
            [context performBlock:^{ // managedObjectContext is not thread safe, make sure it's under right thread
                NSError *error;
                [context deleteObject:vacationPhoto.photo];
                [context save:&error];
                if(error){
                    NSLog(@"ERROR:%@",[error description]);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}

@end
