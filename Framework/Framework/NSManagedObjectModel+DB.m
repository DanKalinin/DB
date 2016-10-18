//
//  NSManagedObjectModel+DB.m
//  Framework
//
//  Created by Dan Kalinin on 18/10/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "NSManagedObjectModel+DB.h"
#import <Helpers/Helpers.h>



@implementation NSManagedObjectModel (DB)

+ (void)load {
    SEL swizzling = @selector(fetchRequestFromTemplateWithName:substitutionVariables:);
    SEL swizzled = @selector(swizzledFetchRequestFromTemplateWithName:substitutionVariables:);
    [self swizzleInstanceMethod:swizzling with:swizzled];
    
    swizzling = @selector(fetchRequestTemplateForName:);
    swizzled = @selector(swizzledFetchRequestTemplateForName:);
    [self swizzleInstanceMethod:swizzling with:swizzled];
}

- (NSFetchRequest *)swizzledFetchRequestFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary<NSString *,id> *)variables {
    NSFetchRequest *fr = [self swizzledFetchRequestFromTemplateWithName:name substitutionVariables:variables].copy;
    [self setSortDescriptors:fr name:name];
    return fr;
}

- (NSFetchRequest *)swizzledFetchRequestTemplateForName:(NSString *)name {
    NSFetchRequest *fr = [self swizzledFetchRequestTemplateForName:name].copy;
    [self setSortDescriptors:fr name:name];
    return fr;
}

- (void)setSortDescriptors:(NSFetchRequest *)fr name:(NSString *)name {
    
    NSURLComponents *components = [NSURLComponents new];
    components.query = fr.entity.userInfo[name];
    
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:queryItem.name ascending:queryItem.value.boolValue];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    fr.sortDescriptors = sortDescriptors;
}

@end
