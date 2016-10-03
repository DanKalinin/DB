//
//  ViewController.m
//  App
//
//  Created by Dan Kalinin on 20/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ViewController.h"
#import "DB+App.h"
#import "Person+CoreDataClass.h"



@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DB db].moc performBlockAndWait:^{
        NSArray *persons = [Person fetch:nil moc:[DB db].moc];
        NSLog(@"count - %i", (int)persons.count);
    }];
    
    [[DB db] performBackgroundTask:^(NSManagedObjectContext *moc) {
        Person *person = [Person create:moc];
        person.name = @"John";
        person.age = 18;
        
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        [moc save:&error];
        NSLog(@"1 - %@", error);
    }];
    
    [[DB db] performBackgroundTask:^(NSManagedObjectContext *moc) {
        Person *person = [Person create:moc];
        person.name = @"John";
        person.age = 18;
        
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        [moc save:&error];
        NSLog(@"2 - %@", error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
