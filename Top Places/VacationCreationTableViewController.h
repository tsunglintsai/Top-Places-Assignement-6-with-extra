//
//  VacationCreationTableViewController.h
//  Top Places
//
//  Created by Daniela on 8/18/12.
//
//

#import <UIKit/UIKit.h>

@class VacationCreationTableViewController;

@protocol VacationCreationTableViewControllerDelegate
- (void)didCacnelCreation;
- (void)vacationCreationTableViewController:(VacationCreationTableViewController *)sender
                     didEnterNameOfVacation:(NSString *)vacationName;
@end


@interface VacationCreationTableViewController : UITableViewController
@property (nonatomic,weak) id<VacationCreationTableViewControllerDelegate> delegate;
@end
