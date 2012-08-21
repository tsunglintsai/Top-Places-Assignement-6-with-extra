//
//  PlacesTableViewController.h
//  Top Places
//
//  Created by Henry Tsai on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoDetailViewController.h"

@interface PlacesTableViewController : UITableViewController
@property (strong,nonatomic) NSMutableSet *photoList;
- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected;
@end
