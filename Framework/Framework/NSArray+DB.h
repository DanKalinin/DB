//
//  NSSet+DB.h
//  Pods
//
//  Created by Dan Kalinin on 4/5/17.
//
//

#import <CoreData/CoreData.h>










@interface NSArray (DB)

- (NSArray *)arrayByExecutingFetchRequest:(NSFetchRequest *)fr;

@end










@interface NSMutableArray (DB)

- (void)executeFetchRequest:(NSFetchRequest *)fr;

@end
