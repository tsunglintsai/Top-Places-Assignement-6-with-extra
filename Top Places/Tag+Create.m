//
//  Tag+Create.m
//  Top Places
//
//  Created by Daniela on 8/12/12.
//
//

#import "Tag+Create.h"

@implementation Tag (Create)
+ (Tag *)tagWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES ]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        // handle error
        NSLog(@"ERROR:more than one match");
    } else if (![matches count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.name = name;
        NSLog(@"create new tag entry in database");
    } else {
        tag = [matches lastObject];
        NSLog(@"found tag entry in database");
    }
    if(error){
        NSLog(@"ERROR:%@",[error description]);
    }
    return tag;
}

@end
