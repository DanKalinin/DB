//
//  FRCTVC.m
//  Framework
//
//  Created by Dan Kalinin on 17/10/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "FRCTVC.h"
#import <Helpers/Helpers.h>



@interface FRCTVC ()

@end



@implementation FRCTVC {
    BOOL _loaded;
    
    NSMutableSet *_objects;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _objects = [NSMutableSet set];
        
        self.insertionAnimation = self.deletionAnimation = UITableViewRowAnimationFade;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_loaded) return;
    _loaded = YES;
    
    if (self.object) {
        NSIndexPath *indexPath = [self.frc indexPathForObject:self.object];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    for (NSManagedObject *object in self.objects) {
        NSIndexPath *indexPath = [self.frc indexPathForObject:object];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - Accessors

- (void)setObjects:(NSSet<NSManagedObject *> *)objects {
    _objects = [NSMutableSet setWithSet:objects];
}

- (NSSet<NSManagedObject *> *)objects {
    return _objects;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger sections = self.frc.sections.count;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    NSUInteger rows = sectionInfo.numberOfObjects;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    NSString *title = sectionInfo.name;
    return title;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    [_objects addObject:object];
    self.object = object;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    [_objects removeObject:object];
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:sections withRowAnimation:self.insertionAnimation];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteSections:sections withRowAnimation:self.deletionAnimation];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([UIDevice.currentDevice.systemVersion isGreaterThanOrEqualToVersion:@"10"] && (type == NSFetchedResultsChangeUpdate) && newIndexPath) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deletionAnimation];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertionAnimation];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:newIndexPath];
        [self configureCell:cell atIndexPath:newIndexPath];
        
        return;
    }
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertionAnimation];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deletionAnimation];
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deletionAnimation];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertionAnimation];
    } else if (type == NSFetchedResultsChangeUpdate) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Helpers

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return @"Cell";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end
