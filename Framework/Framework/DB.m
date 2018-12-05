//
//  DB.m
//  Framework
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "DB.h"
#import <Helpers/Helpers.h>

static NSString *const PathContent = @"/Content";
static NSString *const PathMap = @"/Map";



@interface DB ()

@property NSString *name;
@property NSBundle *modelBundle;
@property NSPersistentStore *store;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectModel *mom;
@property NSManagedObjectContext *moc;

@end



@implementation DB

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        
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
        
        NSUserDefaults *defaults = [NSUserDefaults.alloc initWithSuiteName:self.modelBundle.bundleIdentifier];
        NSString *localization = NSBundle.mainBundle.preferredLocalizations.firstObject;
        NSString *importedKey = [NSString stringWithFormat:@"imported.%@", localization];
        BOOL imported = [defaults boolForKey:importedKey];
        if (!imported) {
            [self importContent];
            [self.moc save:nil];
            [self.moc reset];
            [defaults setBool:YES forKey:importedKey];
            [defaults synchronize];
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
    return moc;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    NSManagedObjectContext *moc = [self newBackgroundContext];
    [moc performBlock:^{
        block(moc);
    }];
}

@end
