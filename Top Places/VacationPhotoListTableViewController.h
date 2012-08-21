//
//  VacationPhotoListTableViewController.h
//  Top Places
//
//  Created by Daniela on 8/17/12.
//
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface VacationPhotoListTableViewController : CoreDataTableViewController
@property (nonatomic,strong) NSString* listTitle;
@property (nonatomic,strong) NSPredicate *predicate;
@end
