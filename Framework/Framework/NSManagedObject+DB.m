//
//  NSManagedObject+Helpers.m
//  CookerDemo
//
//  Created by Dan on 15.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import "NSManagedObject+DB.h"
#import <objc/runtime.h>

static NSString *const IgnoreKey = @"ignore";



@interface NSManagedObject (DBSelectors)

@property NSDictionary *objectDictionary;

@end



@implementation NSManagedObject (DB)

+ (instancetype)create:(NSManagedObjectContext *)moc {
    NSString *name = NSStringFromClass(self);
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:moc];
    return mo;
}

+ (instancetype)find:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSFetchRequest *fr = [self fetchRequest];
    fr.predicate = predicate;
    fr.fetchLimit = 1;
    fr.includesSubentities = NO;
    NSManagedObject *mo = [moc executeFetchRequest:fr error:nil].firstObject;
    return mo;
}

+ (instancetype)findOrCreate:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSManagedObject *mo = [self find:predicate moc:moc];
    if (!mo) {
        mo = [self create:moc];
    }
    return mo;
}

+ (instancetype)replace:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSArray *mos = [self fetch:predicate moc:moc];
    for (NSManagedObject *mo in mos) {
        [moc deleteObject:mo];
    }
    
    NSManagedObject *mo = [self create:moc];
    return mo;
}

+ (NSArray *)fetch:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSFetchRequest *fr = [self fetchRequest];
    fr.predicate = predicate;
    fr.fetchBatchSize = 100;
    fr.includesSubentities = NO;
    NSArray *mos = [moc executeFetchRequest:fr error:nil];
    return mos;
}

+ (void)delete:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSArray *mos = [self fetch:predicate moc:moc];
    for (NSManagedObject *mo in mos) {
        [moc deleteObject:mo];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (NSFetchRequest *)fetchRequest {
    NSString *name = NSStringFromClass(self);
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:name];
    return fr;
}

#pragma clang diagnostic pop

+ (NSUInteger)count:(NSManagedObjectContext *)moc {
    NSFetchRequest *fr = self.fetchRequest;
    NSUInteger count = [moc countForFetchRequest:fr error:nil];
    return count;
}

- (void)importFromDictionary:(NSDictionary *)dictionary usingMap:(NSDictionary *)map {
    
    dictionary = [self dictionary:dictionary usingMap:map];
    
    NSArray *keys = dictionary.allKeys;
    NSArray *attributes = self.entity.attributesByName.allKeys;
    for (NSString *key in keys) {
        if ([attributes containsObject:key]) {
            id value = dictionary[key];
            [self setValue:value forKey:key];
        }
    }
}

- (NSDictionary *)exportToDictionaryUsingMap:(NSDictionary *)map {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *keys = self.entity.attributesByName.allKeys;
    for (NSString *key in keys) {
        NSAttributeDescription *attribute = self.entity.attributesByName[key];
        NSNumber *ignore = attribute.userInfo[IgnoreKey];
        if (ignore.boolValue) continue;
        
        id value = [self valueForKey:key];
        dictionary[key] = value;
    }
    
    dictionary = [self dictionary:dictionary usingMap:map].mutableCopy;
    
    return dictionary;
}

- (void)setPrimitiveValue:(id)value forKey:(NSString *)key notify:(BOOL)notify {
    if (notify) {
        [self willChangeValueForKey:key];
    }
    
    [self setPrimitiveValue:value forKey:key];
    
    if (notify) {
        [self didChangeValueForKey:key];
    }
}

- (id)primitiveValueForKey:(NSString *)key notify:(BOOL)notify {
    if (notify) {
        [self willAccessValueForKey:key];
    }
    
    id value = [self primitiveValueForKey:key];
    
    if (notify) {
        [self didAccessValueForKey:key];
    }
    
    return value;
}

- (void)replaceValue:(NSManagedObject *)value forKey:(NSString *)key {
    NSManagedObject *currentValue = [self primitiveValueForKey:key notify:NO];
    
    if ([value isEqual:currentValue]) return;
    
    if (currentValue) {
        [self.managedObjectContext deleteObject:currentValue];
    }
    
    [self setValue:value forKey:key];
}

- (void)push {
    self.objectDictionary = [self dictionaryWithValuesForKeys:self.entity.propertiesByName.allKeys];
}

- (void)pop {
    [self setValuesForKeysWithDictionary:self.objectDictionary];
}

#pragma mark - Accessors

- (void)setObjectDictionary:(NSDictionary *)objectDictionary {
    objc_setAssociatedObject(self, @selector(objectDictionary), objectDictionary, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)objectDictionary {
    return objc_getAssociatedObject(self, @selector(objectDictionary));
}

#pragma mark - Helpers

- (NSDictionary *)dictionary:(NSDictionary *)dictionary usingMap:(NSDictionary *)map {
    NSMutableDictionary *mappedDictionary = dictionary.mutableCopy;
    for (NSString *mapKey in map.allKeys) {
        id value = mappedDictionary[mapKey];
        if (value) {
            NSString *mapValue = map[mapKey];
            mappedDictionary[mapValue] = value;
            mappedDictionary[mapKey] = nil;
        }
    }
    return mappedDictionary;
}

@end
