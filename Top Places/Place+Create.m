//
//  Place+Create.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Place+Create.h"
#import "Itinerary+Create.h"

@implementation Place (Create)
+ (Place *)placeWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES ]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        // handle error
        NSLog(@"ERROR:more than one match");
    } else if (![matches count]) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = name;
        NSLog(@"create new place entry in database");
    } else {
        place = [matches lastObject];
        NSLog(@"found place entry in database");
    }
    if(error){
        NSLog(@"ERROR:%@",[error description]);
    }
    return place;
}
@end
