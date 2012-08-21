//
//  Itinerary+Create.m
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import "Itinerary+Create.h"
#define ItineraryTitle @"Itinerary"
@implementation Itinerary (Create)

+ (Itinerary *)itineraryInManagedObjectContext:(NSManagedObjectContext *)context
{
    Itinerary *itinerary = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES ]];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", ItineraryTitle];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        // handle error
        NSLog(@"ERROR:more than one match");
    } else if (![matches count]) {
        itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary" inManagedObjectContext:context];
        itinerary.title = ItineraryTitle;
    } else {
        itinerary = [matches lastObject];
        NSLog(@"found Itinerary entry in database");
    }
    if(error){
        NSLog(@"ERROR:%@",[error description]);
    }
    return itinerary;
}



@end
