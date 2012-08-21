//
//  PhotoBlob.h
//  Top Places
//
//  Created by Daniela on 8/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface PhotoBlob : NSManagedObject

@property (nonatomic, retain) NSData * bytes;
@property (nonatomic, retain) Photo *photo;

@end
