//
//  DB.m
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "DB.h"



@interface DB ()

@property NSString *name;
@property NSPersistentStore *store;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectModel *mom;
@property NSManagedObjectContext *moc;

@end



@implementation DB

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        
        bundle = bundle ? bundle : [NSBundle mainBundle];
        
        self.name = name;
        
        // Managed object model
        
        NSURL *momURL = [bundle URLForResource:name withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
        self.mom = mom;
        
        // Persistent store coordinator
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        self.psc = psc;
        
        // Managed object context
        
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        moc.persistentStoreCoordinator = psc;
        self.moc = moc;
        
        // Persistent store
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *documentsURL = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        NSString *storeName = [NSString stringWithFormat:@"%@.sqlite", name];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:storeName];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        NSAssert(store, error.localizedDescription);
        self.store = store;
    }
    return self;
}

- (NSManagedObjectContext *)newBackgroundContext {
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.persistentStoreCoordinator = self.psc;
    return moc;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    NSManagedObjectContext *moc = [self newBackgroundContext];
    [moc performBlock:^{
        block(moc);
    }];
}

@end
