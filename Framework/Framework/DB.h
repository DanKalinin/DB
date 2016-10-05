//
//  DB.h
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <DB/NSManagedObject+DB.h>

FOUNDATION_EXPORT double DBVersionNumber;
FOUNDATION_EXPORT const unsigned char DBVersionString[];



@interface DB : NSObject

- (instancetype)initWithName:(NSString *)name fromBundle:(NSBundle *)bundle;

@property (readonly) NSString *name;
@property (readonly) NSBundle *bundle;

@property (readonly) NSPersistentStore *store;
@property (readonly) NSPersistentStoreCoordinator *psc;
@property (readonly) NSManagedObjectModel *mom;
@property (readonly) NSManagedObjectContext *moc;

- (NSManagedObjectContext *)newBackgroundContext;
- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;

@end
