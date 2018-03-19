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

typedef NS_ENUM(NSUInteger, NextValueMode) {
    NextValueModePrefix,
    NextValueModeSuffix,
    NextValueModePrefixAndSuffix
};



@interface NSManagedObject (DBSelectors)

@property NSDictionary *objectDictionary;

@end



@implementation NSManagedObject (DB)

+ (NSEntityDescription *)entity:(NSManagedObjectContext *)moc {
    NSString *name = NSStringFromClass(self);
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:moc];
    return entity;
}

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

+ (NSInteger)nextIdentifierForKey:(NSString *)key predicate:(NSPredicate *)predicate start:(NSInteger)start moc:(NSManagedObjectContext *)moc {
    while (YES) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %i", key, start];
        NSManagedObject *object = [self find:predicate moc:moc];
        if (object) {
            start++;
        } else {
            return start;
        }
    }
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

- (void)setNextValueForKey:(NSString *)key predicate:(NSPredicate *)predicate prefix:(NSString *)prefix suffix:(NSString *)suffix start:(NSInteger)start affectFirst:(BOOL)affectFirst {
    
    if (key.length == 0) return;
    if ((prefix.length == 0) && (suffix.length == 0)) return;
    
    NSPredicate *notSelfPredicate = [NSPredicate predicateWithFormat:@"self != %@", self];
    
    NSString *value = [self valueForKey:key];
    NSPredicate *valuePredicate;
    NextValueMode mode;
    if ((prefix.length > 0) && (suffix.length == 0)) {
        valuePredicate = [NSPredicate predicateWithFormat:@"%K ENDSWITH %@", key, value];
        mode = NextValueModePrefix;
    } else if ((prefix.length == 0) && (suffix.length > 0)) {
        valuePredicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", key, value];
        mode = NextValueModeSuffix;
    } else {
        valuePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", key, value];
        mode = NextValueModePrefixAndSuffix;
    }
    
    if (predicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, notSelfPredicate, valuePredicate]];
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[notSelfPredicate, valuePredicate]];
    }
    
    NSManagedObject *object;
    NSArray *objects = [self.class fetch:predicate moc:self.managedObjectContext];
    
    BOOL changeName;
    if (affectFirst) {
        changeName = YES;
    } else {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
        object = [objects filteredArrayUsingPredicate:predicate].firstObject;
        changeName = (object != nil);
    }
    
    if (changeName) {
        NSString *nextValue;
        do {
            NSString *format;
            if (mode == NextValueModePrefix) {
                format = [NSString stringWithFormat:@"%@%%@", prefix];
                nextValue = [NSString stringWithFormat:format, start, value];
            } else if (mode == NextValueModeSuffix) {
                format = [NSString stringWithFormat:@"%%@%@", suffix];
                nextValue = [NSString stringWithFormat:format, value, start];
            } else {
                format = [NSString stringWithFormat:@"%@%%@%@", prefix, suffix];
                nextValue = [NSString stringWithFormat:format, start, value, start];
            }
            
            predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, nextValue];
            object = [objects filteredArrayUsingPredicate:predicate].firstObject;
            start++;
        } while (object);
        
        [self setValue:nextValue forKey:key];
    }
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
