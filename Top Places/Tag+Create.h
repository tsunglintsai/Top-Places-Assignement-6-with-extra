//
//  Tag+Create.h
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Tag.h"
#import "Photo+FlickerPhoto.h"

@interface Tag (Create)
+ (Tag *)tagWithName:(NSString *)name
inManagedObjectContext:(NSManagedObjectContext *)context;
@end
