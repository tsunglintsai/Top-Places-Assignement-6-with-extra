//
//  VacationPhoto.m
//  Top Places
//
//  Created by Daniela on 8/13/12.
//
//

#import "VacationPhoto.h"

@implementation VacationPhoto

@synthesize photoSmallURL = _photoSmallURL;
@synthesize photoLargeURL = _photoLargeURL;
@synthesize photoOriginalURL = _photoOriginalURL;
@synthesize photoTitle = _photoTitle;
@synthesize photoSubTitle = _photoSubTitle;
@synthesize smallImage = _smallImage;
@synthesize largeImage = _largeImage;
@synthesize originalImage = _originalImage;
@synthesize photoId = _photoId;
@synthesize coordinate = _coordinate;
@synthesize photo = _photo;

- (id) photoId{
    //NSLog(@"photoId");
    return self.photo.photoId;
}
- (NSURL*) photoSmallURL{
    //NSLog(@"photoSmallURL");
    return nil;
}
- (NSURL*) photoLargeURL{
    //NSLog(@"photoLargeURL");
    
    return nil;
}
- (NSURL*) photoOriginalURL{
    //NSLog(@"photoOriginalURL");
    
    return nil;
}

- (NSString*) photoTitle{
    //NSLog(@"photoTitle");
    return self.photo.title;
}
- (NSString*) photoSubTitle{
    //NSLog(@"photoSubTitle");
    
    return self.photo.subtitle;
}
- (UIImage*) smallImage{
    //NSLog(@"smallImage");
    return [UIImage imageWithData:self.photo.thumbnail];
}
- (UIImage*) largeImage{
    //NSLog(@"largeImage");
    __block UIImage *image;
    [self.photo.managedObjectContext performBlockAndWait:^{
        image = [UIImage imageWithData:self.photo.photoBlob.bytes];
    }];
    return image;
}
- (UIImage*) originalImage{
    //NSLog(@"originalImage");
    
    return nil;
}
- (CLLocationCoordinate2D) coordinate{
    //NSLog(@"coordinate");
    return CLLocationCoordinate2DMake([self.photo.geotag_latitude doubleValue], [self.photo.geotag_longitude doubleValue]);
}



@end
