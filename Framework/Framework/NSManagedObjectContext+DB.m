//
//  NSManagedObjectContext+DB.m
//  Database
//
//  Created by Dan Kalinin on 3/14/19.
//

#import "NSManagedObjectContext+DB.h"



@implementation NSManagedObjectContext (DB)

- (void)deleteObjects:(NSArray<NSManagedObject *> *)objects {
    for (NSManagedObject *object in objects) {
        [self deleteObject:object];
    }
}

@end
