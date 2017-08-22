//
//  DB.h
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double DBVersionNumber;
FOUNDATION_EXPORT const unsigned char DBVersionString[];

#import <CoreData/CoreData.h>

#import <DB/NSManagedObjectModel+DB.h>
#import <DB/NSManagedObject+DB.h>
#import <DB/NSArray+DB.h>
#import <DB/FRCTVC.h>
#import <DB/FRCCVC.h>

typedef NS_ENUM(NSUInteger, EntityState) {
    EntityStateNormal,
    EntityStateDeleted,
    EntityStateCreated,
    EntityStateUpdated
};










@protocol DB <NSObject>

@optional
- (void)didImportObject:(NSManagedObject *)object fromDictionary:(NSDictionary *)dictionary;

@end










@interface DB : NSObject <DB>

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle;

@property (readonly) NSString *name;
@property (readonly) NSBundle *modelBundle;

@property (readonly) NSPersistentStore *store;
@property (readonly) NSPersistentStoreCoordinator *psc;
@property (readonly) NSManagedObjectModel *mom;
@property (readonly) NSManagedObjectContext *moc;

- (void)importContent;
- (NSDictionary *)mapForClass:(Class)cls;
- (NSManagedObjectContext *)newBackgroundContext;
- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;

@end
