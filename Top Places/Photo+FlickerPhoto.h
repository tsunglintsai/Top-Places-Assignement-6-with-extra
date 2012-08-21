//
//  Photo+FlickerPhoto.h
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Photo.h"
#import "FlickerPhoto.h"
#import "TopPlacesPhotoProtocol.h"

@interface Photo (FlickerPhoto)
+ (Photo *)photoWithFlickrPhoto:(FlickerPhoto *)flickrPhoto
                  withPhotoData:(NSData*)photoData
         inManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)flickrPhotoExist:(FlickerPhoto *)flickrInfo
         inManagedObjectContext:(NSManagedObjectContext *)context;
- (FlickerPhoto*) toFlickerPhoto;
@end
