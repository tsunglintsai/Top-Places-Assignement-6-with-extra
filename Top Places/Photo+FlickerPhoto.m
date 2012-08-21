//
//  Photo+FlickerPhoto.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Photo+FlickerPhoto.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"
#import "Place+Create.h"
#import "PhotoBlob.h"

@implementation Photo (FlickerPhoto)

- (FlickerPhoto*) toFlickerPhoto{
    FlickerPhoto *result = [[FlickerPhoto alloc]init];
    [self.managedObjectContext performBlockAndWait:^{
        result.photoSmallURL = nil;
        result.photoLargeURL = nil;
        result.photoOriginalURL = nil;
        result.photoTitle = self.title;
        result.photoSubTitle = self.subtitle;
        result.smallImage = [UIImage imageWithData:self.thumbnail];
        result.largeImage = [UIImage imageWithData:self.photoBlob.bytes];
        result.originalImage = nil;
        result.photoData = nil;
        result.photoId = self.photoId;
        result.coordinate = CLLocationCoordinate2DMake([self.geotag_latitude doubleValue], [self.geotag_longitude doubleValue]);
    }];
    return result;
}

- (void)prepareForDeletion
{
    /*
    NSLog(@"prepareForDeletion: if no photo in tag or place, delete place or tag");
    if([self.placeTookThisPhoto.photos count]==1){
        [self.managedObjectContext deleteObject:self.placeTookThisPhoto];
    }
    
    for(Tag *tag in self.tags){
        if([tag.photos count]==1){
            [self.managedObjectContext deleteObject:tag];
        }
    }
    */
}

+ (NSString*) makeFirstLetterCapitalized:(NSString*) str{
    NSString *result = str;
    if([str length]>0){
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
        NSString *firstChar = [str substringToIndex:1];
        NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
         result = [[folded uppercaseString] stringByAppendingString:[str substringFromIndex:1]];
    }
    return result;
}

+ (BOOL)flickrPhotoExist:(FlickerPhoto *)flickrPhoto
     inManagedObjectContext:(NSManagedObjectContext *)context{
    __block BOOL result = NO;
    [context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoId" ascending:YES ]];
        request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", [flickrPhoto.photoId description]];
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        if ([matches count]>0){
            result = YES;
        }else{
            result = NO;
        }
    }];
    return result;
}

+ (Photo *)photoWithFlickrPhoto:(FlickerPhoto *)flickrPhoto
                  withPhotoData:(NSData*)photoData
        inManagedObjectContext:(NSManagedObjectContext *)context{
    Photo *photo ;
    NSString *photoId = [flickrPhoto.photoId description];
    NSString *photoPlace = [flickrPhoto.photoData objectForKey:FLICKR_PHOTO_PLACE_NAME];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoId" ascending:YES ]];
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", photoId];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSArray *tags = [[flickrPhoto.photoData objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
    NSMutableArray *cleanTags = [[NSMutableArray alloc]init];
    for(NSString *tag in tags){
        if( [tag length]>0 && [tag rangeOfString:@":"].length <= 0){
            [cleanTags addObject:[[self class]makeFirstLetterCapitalized:tag]];
        }
    }
    if (!matches || ([matches count] > 1)) {
        // handle error
        NSLog(@"ERROR:more than one match");
    } else if (![matches count]) {
        // create photoBlob
        if(photoData==nil){
            photoData = UIImagePNGRepresentation(flickrPhoto.largeImage);
        }
        PhotoBlob *photoBlob = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoBlob" inManagedObjectContext:context];
        photoBlob.bytes = photoData;
        // fill in photo data
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.photoBlob = photoBlob;
        photo.subtitle = flickrPhoto.photoSubTitle;
        photo.timestamp = [NSDate date];
        photo.title = flickrPhoto.photoTitle;
        photo.thumbnail = UIImagePNGRepresentation(flickrPhoto.smallImage);
        photo.placeTookThisPhoto = [Place placeWithName:photoPlace inManagedObjectContext:context];
        photo.photoId = photoId;
        photo.geotag_latitude = [NSNumber numberWithDouble:flickrPhoto.coordinate.latitude];
        photo.geotag_longitude = [NSNumber numberWithDouble:flickrPhoto.coordinate.longitude];
        NSMutableSet *tagsInPhoto = [photo.tags mutableCopy];
        if(tagsInPhoto==nil){
            tagsInPhoto = [[NSMutableSet alloc]init];
        }
        for(NSString *tagStr in cleanTags){
            Tag *tag = [Tag tagWithName:tagStr inManagedObjectContext:context];
            [tagsInPhoto addObject:tag];
            [tag addPhotosObject:photo];
        }
        photo.tags = tagsInPhoto;
        NSLog(@"create new Photo entry in database");
    } else {
        photo = [matches lastObject];
        NSLog(@"found photo entry in database");
    }
    if(error){
        NSLog(@"ERROR:%@",[error description]);
    }
    return photo;
}
@end
