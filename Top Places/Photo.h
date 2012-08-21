//
//  Photo.h
//  Top Places
//
//  Created by Henry on 8/18/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoBlob, Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * geotag_latitude;
@property (nonatomic, retain) NSNumber * geotag_longitude;
@property (nonatomic, retain) PhotoBlob *photoBlob;
@property (nonatomic, retain) Place *placeTookThisPhoto;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
