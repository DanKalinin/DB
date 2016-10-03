//
//  Person+CoreDataProperties.m
//  App
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Person"];
}

@dynamic name;
@dynamic age;

@end
