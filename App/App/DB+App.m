//
//  DB+App.m
//  App
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "DB+App.h"



@implementation DB (App)

+ (instancetype)db {
    static DB *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [[self alloc] initWithName:@"MyDB" fromBundle:nil];
    });
    return db;
}

@end
