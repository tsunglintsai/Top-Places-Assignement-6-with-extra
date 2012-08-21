//
//  VacationHelper.h
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface VacationHelper : NSObject
+ (VacationHelper*) sharedInstance;
- (void) useSharedManagedDocumentForVacationNamed:(NSString *)vacationName
                                  toExecuteBlock:(completion_block_t)completionBlock;
- (NSArray *) getVacationNameList;
- (NSString *) currentOpenVacationName;
- (void) createDocumentForVacation : (NSString*)vacationName completionHandler:(void (^)(BOOL success))completionHandler;
@end
