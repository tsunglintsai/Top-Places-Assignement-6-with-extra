//
//  VacationPlacesTableViewController.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "VacationPlacesTableViewController.h"
#import "PhotoDetailViewController.h"
#import "FlickerPhoto.h"
#import "FlickrFetcher.h"
#import "Place+Create.h"
#import "VacationHelper.h"
#import "Itinerary+Create.h"

@interface VacationPlacesTableViewController ()

@end

@implementation VacationPlacesTableViewController
- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected{
    [super photoSelected:photoSelected];
}
@end
