//
//  Itinerary.h
//  Top Places
//
//  Created by Daniela on 8/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Itinerary : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *places;
@end

@interface Itinerary (CoreDataGeneratedAccessors)

- (void)insertObject:(Place *)value inPlacesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlacesAtIndex:(NSUInteger)idx;
- (void)insertPlaces:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlacesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlacesAtIndex:(NSUInteger)idx withObject:(Place *)value;
- (void)replacePlacesAtIndexes:(NSIndexSet *)indexes withPlaces:(NSArray *)values;
- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSOrderedSet *)values;
- (void)removePlaces:(NSOrderedSet *)values;
@end
