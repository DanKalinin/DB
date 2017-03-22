//
//  NSManagedObject+Helpers.h
//  CookerDemo
//
//  Created by Dan on 15.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import <CoreData/CoreData.h>



@interface NSManagedObject (DB)

+ (instancetype)create:(NSManagedObjectContext *)moc;

+ (instancetype)find:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;
+ (instancetype)findOrCreate:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;
+ (instancetype)replace:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;

+ (NSArray *)fetch:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;
+ (void)delete:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;

+ (NSFetchRequest *)fetchRequest;
+ (NSUInteger)count:(NSManagedObjectContext *)moc;

- (void)importFromDictionary:(NSDictionary *)dictionary usingMap:(NSDictionary *)map;
- (NSDictionary *)exportToDictionaryUsingMap:(NSDictionary *)map;

- (void)setPrimitiveValue:(id)value forKey:(NSString *)key notify:(BOOL)notify;
- (id)primitiveValueForKey:(NSString *)key notify:(BOOL)notify;

- (void)push;
- (void)pop;

@end
