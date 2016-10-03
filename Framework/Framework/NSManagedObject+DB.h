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

+ (NSArray *)fetch:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;
+ (void)delete:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc;

+ (NSFetchRequest *)fetchRequest;

- (void)importFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)exportToDictionary;

@end
