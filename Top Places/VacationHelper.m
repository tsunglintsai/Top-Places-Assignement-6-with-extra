//
//  VacationHelper.m
//  Top Places
//
//  Created by Daniela on 8/11/12.
//
//

#import "VacationHelper.h"
#define Vacation_Folder @"Vacations"
#define Default_Vacation_Name @"My Vacation"

@interface VacationHelper()
@property (strong,nonatomic) NSString *currentOpenVacationName;
@property (strong,nonatomic) UIManagedDocument *currentOpenDocument;
@end

@implementation VacationHelper
@synthesize currentOpenVacationName = _currentOpenVacationName;
@synthesize currentOpenDocument = _currentOpenDocument;

static VacationHelper *_shareInstance;

+ (VacationHelper*) sharedInstance{
    if(_shareInstance==nil){
        _shareInstance = [[VacationHelper alloc]init];
    }
    return _shareInstance;
}

- (NSString *) currentOpenVacationName{
    if(_currentOpenVacationName==nil){
        _currentOpenVacationName = Default_Vacation_Name;
    }
    return _currentOpenVacationName;
}

- (void) executeBlock:(completion_block_t)completionBlock
          inDocument:(UIManagedDocument*)document{
    if (document.documentState == UIDocumentStateNormal) {
        //NSLog(@"UIDocumentStateNormal");
        completionBlock(document);
        //NSLog(@"finish executeBlock");
    } else if (document.documentState == UIDocumentStateClosed) {
        //NSLog(@"UIDocumentStateClosed");
        [document openWithCompletionHandler:^(BOOL success) {
            //NSLog(@"Open Document...");
            if (success) {
                //NSLog(@"Open Document...Done");
                completionBlock(document);
                //NSLog(@"finish executeBlock");
            }else{
                //NSLog(@"Failt to open Docuement");
            }
        }];
    }
}

- (void) createDocumentForVacation : (NSString*)vacationName completionHandler:(void (^)(BOOL success))completionHandler{
    UIManagedDocument *document;
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:YES
                                                           error:NULL];
    url = [url URLByAppendingPathComponent:Vacation_Folder];
    url = [url URLByAppendingPathComponent:vacationName];
    document = [[UIManagedDocument alloc]initWithFileURL:url];
    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
      completionHandler:^(BOOL success) {
         completionHandler(success);
    }];
}

- (void) useSharedManagedDocumentForVacationNamed:(NSString *)vacationName
                                   toExecuteBlock:(completion_block_t)completionBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createVacationFolderIfNotExist: self.vacationFolderURL];
        UIManagedDocument *document = self.currentOpenDocument;
        if(document!=nil && [vacationName isEqualToString:self.currentOpenVacationName]){
            NSLog(@"found document in memory");
        }else{
            UIManagedDocument *documentToClose = self.currentOpenDocument;
            [documentToClose closeWithCompletionHandler:^(BOOL success){
                if(success){
                    NSLog(@" close document %@", [documentToClose.fileURL path]);
                }else{
                    NSLog(@" fail to close doucment %@",[documentToClose.fileURL path]);
                }
            }];
            document = nil;
        }
        if(document==nil){
            //NSLog(@"document is not in memory create one");
            NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                inDomain:NSUserDomainMask
                                                       appropriateForURL:nil
                                                                  create:YES
                                                                   error:NULL];
            url = [url URLByAppendingPathComponent:Vacation_Folder];
            url = [url URLByAppendingPathComponent:vacationName];
            document = [[UIManagedDocument alloc]initWithFileURL:url];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                [document openWithCompletionHandler:^(BOOL success) {
                    if (success) {
                        [self executeBlock:completionBlock inDocument:document];
                        self.currentOpenVacationName = vacationName;
                        self.currentOpenDocument = document;
                        NSLog(@"open document at %@", url);
                    }else{
                        NSLog(@"couldn’t open document at %@", url);
                    }
                }];
            } else {
                [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
                  completionHandler:^(BOOL success) {
                      if (success) {
                          [self executeBlock:completionBlock inDocument:document];
                          self.currentOpenVacationName = vacationName;
                          self.currentOpenDocument = document;
                          NSLog(@"save document at %@", url);
                      }else{
                          NSLog(@"couldn’t create document at %@", url);
                      }
                }];
            }
        }else{
            [self executeBlock:completionBlock inDocument:document];
            self.currentOpenVacationName = vacationName;
        }
    });
}

- (NSOrderedSet *) getVacationNameList{
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:YES
                                                           error:NULL];
    url = [url URLByAppendingPathComponent:Vacation_Folder];
    url = [url URLByAppendingPathComponent:Default_Vacation_Name];
    [self createVacationFolderIfNotExist: self.vacationFolderURL];
    NSMutableOrderedSet * result = [[NSMutableOrderedSet alloc]init];
    [result addObject:Default_Vacation_Name];
    for(NSURL *url in self.listOfVacationFileURL){
        [result addObject:[url lastPathComponent]];
    }
    return result;
}


- (NSURL*) vacationFolderURL{
    NSURL *result = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *documentDirectory = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    result = [documentDirectory URLByAppendingPathComponent:Vacation_Folder];
    return result;
}

- (void) createVacationFolderIfNotExist:(NSURL*)url{
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        // do nothing if folder exist.
    }else{
        [[NSFileManager defaultManager] createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
        //NSLog(@"create vacation folder URL");
    }
    if(error){
        NSLog(@"%@",[error description]);
    }
}

- (NSArray*) listOfVacationFileURL{
    NSMutableArray* result = [[NSMutableArray alloc]init];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSURL *documentDirectory = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL *vacationDocumentDirectory = [documentDirectory URLByAppendingPathComponent:Vacation_Folder];
    NSArray *filesInDocument = [fileManager contentsOfDirectoryAtURL:vacationDocumentDirectory includingPropertiesForKeys:(NSArray *)nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if(error){
        NSLog(@"%@",[error description]);
    }
    //NSLog(@"number of vacation in folder:%i",[result count]);
    [filesInDocument enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [result addObject:object];
        //NSLog(@"[%i]%@",idx,[object class]);
    }];
    return result;
}


@end
