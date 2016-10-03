//
//  NSManagedObject+Helpers.m
//  CookerDemo
//
//  Created by Dan on 15.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import "NSManagedObject+DB.h"



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

+ (NSArray *)fetch:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc {
    NSFetchRequest *fr = [self fetchRequest];
    fr.predicate = predicate;
    fr.fetchBatchSize = 100;
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

- (void)importFromDictionary:(NSDictionary *)dictionary {
    NSArray *keys = dictionary.allKeys;
    NSArray *attributes = self.entity.attributesByName.allKeys;
    for (NSString *key in keys) {
        if ([attributes containsObject:key]) {
            id value = dictionary[key];
            [self setValue:value forKey:key];
        }
    }
}

- (NSDictionary *)exportToDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *keys = self.entity.attributesByName.allKeys;
    for (NSString *key in keys) {
        id value = [self valueForKey:key];
        dictionary[key] = value;
    }
    return dictionary;
}

@end
