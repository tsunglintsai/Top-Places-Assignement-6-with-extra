//
//  Itinerary+Create.h
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import "Itinerary.h"

@interface Itinerary (Create)
+ (Itinerary *)itineraryInManagedObjectContext:(NSManagedObjectContext *)context;
@end
