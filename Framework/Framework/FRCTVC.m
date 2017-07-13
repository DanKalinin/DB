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
    __weak id <NSFetchedResultsControllerDelegate> _delegate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _objects = [NSMutableSet set];
        
        self.rowAnimation = UITableViewRowAnimationFade;
        self.orderKeyPath = @"order";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.clearsSelectionOnViewWillAppear) {
        [_objects removeAllObjects];
    } else {
        if (_loaded) return;
        _loaded = YES;
        
        UITableViewScrollPosition position = (self.objects.count == 1) ? UITableViewScrollPositionMiddle : UITableViewScrollPositionNone;
        [self selectObjects:position];
    }
}

#pragma mark - Accessors

- (void)setObject:(NSManagedObject *)object {
    if (!object) return;
    _objects = [NSMutableSet setWithObject:object];
}

- (NSManagedObject *)object {
    return _objects.anyObject;
}

- (void)setObjects:(NSSet<NSManagedObject *> *)objects {
    if (!objects) return;
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
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    [_objects removeObject:object];
}

- (void)tableView:(UITableView *)tableView didToggleSelectAllButton:(UIButton *)button {
    if (button.selected) {
        [_objects addObjectsFromArray:self.frc.fetchedObjects];
    } else {
        [_objects removeAllObjects];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([destinationIndexPath isEqual:sourceIndexPath]) return;
    
    id <NSFetchedResultsControllerDelegate> delegate = self.frc.delegate;
    self.frc.delegate = nil;
    
    NSInteger sourceIndex, destinationIndex;
    NSMutableArray *objects;
    
    if (self.orderInSection) {
        sourceIndex = sourceIndexPath.row;
        destinationIndex = destinationIndexPath.row;
        id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[sourceIndexPath.section];
        objects = sectionInfo.objects.mutableCopy;
    } else {
        sourceIndex = destinationIndex = 0;
    }
    
    NSManagedObject *object = objects[sourceIndex];
    [objects removeObjectAtIndex:sourceIndex];
    [objects insertObject:object atIndex:destinationIndex];
    
    for (NSUInteger order = 0; order < objects.count; order++) {
        object = objects[order];
        [object setValue:@(order) forKeyPath:self.orderKeyPath];
    }
    
    [self.frc.managedObjectContext save:nil];
    
    [self.frc performFetch:nil];
    self.frc.delegate = delegate;
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:sections withRowAnimation:self.rowAnimation];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteSections:sections withRowAnimation:self.rowAnimation];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([UIDevice.currentDevice.systemVersion isGreaterThanOrEqualToVersion:@"10"] && (type == NSFetchedResultsChangeUpdate) && newIndexPath) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.rowAnimation];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.rowAnimation];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:newIndexPath];
        [self configureCell:cell atIndexPath:newIndexPath];
        
        return;
    }
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.rowAnimation];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.rowAnimation];
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.rowAnimation];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.rowAnimation];
    } else if (type == NSFetchedResultsChangeUpdate) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self selectObjects:UITableViewScrollPositionNone];
}

#pragma mark - Helpers

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return @"Cell";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

- (void)prepareForReloadData {
    if (!self.frc.delegate) return;
    
    _delegate = self.frc.delegate;
    self.frc.delegate = nil;
}

- (void)reloadData {
    [self.frc performFetch:nil];
    [self.tableView reloadData];
    self.frc.delegate = _delegate;
}

- (void)selectObjects:(UITableViewScrollPosition)position {
    for (NSManagedObject *object in self.objects) {
        NSIndexPath *indexPath = [self.frc indexPathForObject:object];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:position];
    }
}

@end
