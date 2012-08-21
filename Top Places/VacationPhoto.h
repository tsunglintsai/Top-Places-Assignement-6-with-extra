//
//  VacationPhoto.h
//  Top Places
//
//  Created by Daniela on 8/13/12.
//
//

#import <Foundation/Foundation.h>
#import "TopPlacesPhotoProtocol.h"
#import "Photo+FlickerPhoto.h"
#import "PhotoBlob.h"

@interface VacationPhoto : NSObject<TopPlacesPhotoProtocol>
@property (strong,nonatomic) Photo *photo;
@end
