//
//  NSSet+DB.m
//  Pods
//
//  Created by Dan Kalinin on 4/5/17.
//
//

#import "NSArray+DB.h"










@implementation NSArray (DB)

- (NSArray *)arrayByExecutingFetchRequest:(NSFetchRequest *)fr {
    NSMutableArray *array = self.mutableCopy;
    [array executeFetchRequest:fr];
    return array;
}

@end










@implementation NSMutableArray (DB)

- (void)executeFetchRequest:(NSFetchRequest *)fr {
    if (fr.predicate) {
        [self filterUsingPredicate:fr.predicate];
    }
    if (fr.sortDescriptors.count > 0) {
        [self sortUsingDescriptors:fr.sortDescriptors];
    }
}

@end
