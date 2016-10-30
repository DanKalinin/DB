//
//  DB.h
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <DB/NSManagedObjectModel+DB.h>
#import <DB/NSManagedObject+DB.h>
#import <DB/FRCTVC.h>

FOUNDATION_EXPORT double DBVersionNumber;
FOUNDATION_EXPORT const unsigned char DBVersionString[];

typedef NS_ENUM(NSUInteger, EntityState) {
    EntityStateNormal,
    EntityStateDeleted,
    EntityStateCreated,
    EntityStateUpdated
};



@interface DB : NSObject

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle;

@property (readonly) NSString *name;
@property (readonly) NSBundle *modelBundle;

@property (readonly) NSPersistentStore *store;
@property (readonly) NSPersistentStoreCoordinator *psc;
@property (readonly) NSManagedObjectModel *mom;
@property (readonly) NSManagedObjectContext *moc;

- (void)importContent;
- (NSManagedObjectContext *)newBackgroundContext;
- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;

@end
