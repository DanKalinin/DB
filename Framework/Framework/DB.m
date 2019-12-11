//
//  DB.m
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "DB.h"
#import <Helpers/Helpers.h>

NSNotificationName const DBDidMergeContextNotification = @"DBDidMergeContextNotification";

static NSString *const PathContent = @"/Content";
static NSString *const PathMap = @"/Map";



@interface DB ()

@property NSString *name;
@property NSBundle *modelBundle;
@property NSPersistentStore *store;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectModel *mom;
@property NSManagedObjectContext *moc;
@property NSUserDefaults *defaults;

@property NSString *pidKey;
@property NSString *mocKey;

@end



@implementation DB

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle group:(NSString *)group {
    self = [super init];
    if (self) {
        self.pidKey = @"pid";
        self.mocKey = @"moc";
        
        self.name = name;
        if (!bundle) bundle = [NSBundle mainBundle];
        self.modelBundle = bundle;
        
        // Managed object model
        
        NSURL *momURL = [bundle URLForResource:name withExtension:@"momd"];
        NSManagedObjectModel *mom = [NSManagedObjectModel.alloc initWithContentsOfURL:momURL];
        self.mom = mom;
        
        // Persistent store coordinator
        
        NSPersistentStoreCoordinator *psc = [NSPersistentStoreCoordinator.alloc initWithManagedObjectModel:mom];
        self.psc = psc;
        
        // Managed object context
        
        NSManagedObjectContext *moc = [NSManagedObjectContext.alloc initWithConcurrencyType:NSMainQueueConcurrencyType];
        moc.persistentStoreCoordinator = psc;
        self.moc = moc;
        
        moc.mergePolicy = NSOverwriteMergePolicy;
        moc.automaticallyMergesChangesFromParent = YES;
        moc.retainsRegisteredObjects = YES;
        
        moc.undoManager = NSUndoManager.new;
        moc.undoManager.groupsByEvent = NO;
        
//        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NSManagedObjectContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:moc];
        
        // Persistent store
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *documentsURL = [fm containerURLForSecurityApplicationGroupIdentifier:group];
        NSString *storeName = [NSString stringWithFormat:@"%@.sqlite", name];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:storeName];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        NSAssert(store, error.localizedDescription);
        self.store = store;
        
        self.defaults = [NSUserDefaults.alloc initWithSuiteName:group];
//        [self.defaults addObserver:self forKeyPath:self.mocKey options:0 context:NULL];
        NSString *importedKey = mom.versionIdentifiers.anyObject;
        BOOL imported = [self.defaults boolForKey:importedKey];
        if (!imported) {
            [self importContent];
            [self.moc save:nil];
            [self.moc reset];
            [self.defaults setBool:YES forKey:importedKey];
            [self.defaults synchronize];
        }
    }
    return self;
}

- (void)importContent {
    SEL selector = @selector(didImportObject:fromDictionary:);
    BOOL inform = [self respondsToSelector:selector];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent" ascending:YES];
    NSMutableArray *URLs = [self.modelBundle URLsForResourcesWithExtension:ExtensionPlist subdirectory:PathContent].mutableCopy;
    [URLs sortUsingDescriptors:@[descriptor]];
    
    for (NSURL *URL in URLs) {
        NSString *name = URL.lastPathComponent.stringByDeletingPathExtension;
        name = [name componentsSeparatedByString:@"-"].lastObject;
        NSArray *array = [NSArray arrayWithContentsOfURL:URL];
        Class class = NSClassFromString(name);
        [class delete:nil moc:self.moc];
        NSDictionary *map = [NSDictionary dictionaryWithContentsOfURL:URL];
        for (NSDictionary *dictionary in array) {
            NSManagedObject *object = [class create:self.moc];
            [object importFromDictionary:dictionary usingMap:map];
            if (inform) {
                [self didImportObject:object fromDictionary:dictionary];
            }
        }
    }
}

- (NSDictionary *)mapForClass:(Class)cls {
    NSString *name = NSStringFromClass(cls);
    NSURL *URL = [self.modelBundle URLForResource:name withExtension:ExtensionPlist subdirectory:PathMap];
    NSDictionary *map = [NSDictionary dictionaryWithContentsOfURL:URL];
    return map;
}

- (NSManagedObjectContext *)newBackgroundContext {
    NSManagedObjectContext *moc = [NSManagedObjectContext.alloc initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.persistentStoreCoordinator = self.psc;
    
    moc.mergePolicy = NSOverwriteMergePolicy;
    moc.automaticallyMergesChangesFromParent = YES;
    moc.retainsRegisteredObjects = YES;
    
    return moc;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    NSManagedObjectContext *moc = [self newBackgroundContext];
    [moc performBlock:^{
        block(moc);
    }];
}

- (void)NSManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    [self.defaults setInteger:NSProcessInfo.processInfo.processIdentifier forKey:self.pidKey];
    
    NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
    for (NSString *key in notification.userInfo.allKeys) {
        if ([key isEqualToString:NSInsertedObjectsKey] || [key isEqualToString:NSUpdatedObjectsKey] || [key isEqualToString:NSDeletedObjectsKey]) {
            NSSet *value = notification.userInfo[key];
            dictionary[key] = [value.allObjects valueForKeyPath:@"objectID.URIRepresentation"];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    [self.defaults setObject:data forKey:self.mocKey];
    
    [self.defaults synchronize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    NSInteger pid = [self.defaults integerForKey:self.pidKey];
    if (pid != NSProcessInfo.processInfo.processIdentifier) {
        NSData *data = [self.defaults dataForKey:self.mocKey];
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:dictionary intoContexts:@[self.moc]];
        [NSNotificationCenter.defaultCenter postNotificationName:DBDidMergeContextNotification object:self];
    }
}

@end
