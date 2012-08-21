//
//  Place+Create.h
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Place.h"

@interface Place (Create)
+ (Place *)placeWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context;
@end
