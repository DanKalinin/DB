//
//  FRCCVC.m
//  Framework
//
//  Created by Dan Kalinin on 12/8/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "FRCCVC.h"



@interface FRCCVC ()

@end



@implementation FRCCVC {
    BOOL _loaded;
    
    NSMutableIndexSet *_insertedSections;
    NSMutableIndexSet *_deletedSections;
    
    NSMutableOrderedSet *_insertedItems;
    NSMutableOrderedSet *_deletedItems;
    NSMutableOrderedSet *_updatedItems;
    
    NSMutableSet *_objects;
    
    __weak id <NSFetchedResultsControllerDelegate> _delegate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _objects = [NSMutableSet set];
        
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
        
        UICollectionViewScrollPosition position = (self.objects.count == 1) ? (UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally) : UICollectionViewScrollPositionNone;
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

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSUInteger sections = self.frc.sections.count;
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    NSUInteger items = sectionInfo.numberOfObjects;
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    [_objects addObject:object];
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    [_objects removeObject:object];
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([destinationIndexPath isEqual:sourceIndexPath]) return;
    
    id <NSFetchedResultsControllerDelegate> delegate = self.frc.delegate;
    self.frc.delegate = nil;
    
    NSInteger sourceIndex, destinationIndex;
    NSMutableArray *objects;
    
    if (self.orderInSection) {
        sourceIndex = sourceIndexPath.item;
        destinationIndex = destinationIndexPath.item;
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
    _insertedSections = [NSMutableIndexSet indexSet];
    _deletedSections = [NSMutableIndexSet indexSet];
    
    _insertedItems = [NSMutableOrderedSet orderedSet];
    _deletedItems = [NSMutableOrderedSet orderedSet];
    _updatedItems = [NSMutableOrderedSet orderedSet];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (type == NSFetchedResultsChangeInsert) {
        [_insertedSections addIndex:sectionIndex];
    } else if (type == NSFetchedResultsChangeDelete) {
        [_deletedSections addIndex:sectionIndex];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [_insertedItems addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        [_deletedItems addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        [_deletedItems addObject:indexPath];
        [_insertedItems addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeUpdate) {
        [_updatedItems addObject:indexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        if (_insertedSections.count > 0) {
            [self.collectionView insertSections:_insertedSections];
        }
        if (_deletedSections.count > 0) {
            [self.collectionView deleteSections:_deletedSections];
        }
        
        if (_insertedItems.count > 0) {
            [self.collectionView insertItemsAtIndexPaths:_insertedItems.array];
        }
        if (_deletedItems.count > 0) {
            [self.collectionView deleteItemsAtIndexPaths:_deletedItems.array];
        }
        if (_updatedItems.count > 0) {
            [self.collectionView reloadItemsAtIndexPaths:_updatedItems.array];
        }
    } completion:nil];
    
    [self selectObjects:UICollectionViewScrollPositionNone];
}

#pragma mark - Helpers

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return @"Cell";
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

- (void)selectObjects:(UICollectionViewScrollPosition)position {
    for (NSManagedObject *object in self.objects) {
        NSIndexPath *indexPath = [self.frc indexPathForObject:object];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:position];
    }
}

- (void)prepareForReloadData {
    if (!self.frc.delegate) return;
    
    _delegate = self.frc.delegate;
    self.frc.delegate = nil;
}

- (void)reloadData {
    [self.frc performFetch:nil];
    [self.collectionView reloadData];
    self.frc.delegate = _delegate;
}

@end
