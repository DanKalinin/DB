//
//  NSManagedObjectContext+DB.h
//  Database
//
//  Created by Dan Kalinin on 3/14/19.
//

#import <CoreData/CoreData.h>



@interface NSManagedObjectContext (DB)

- (void)deleteObjects:(NSArray<NSManagedObject *> *)objects;

@end
