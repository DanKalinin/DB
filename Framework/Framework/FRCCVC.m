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
    BOOL loaded;
    
    NSMutableIndexSet *insertedSections;
    NSMutableIndexSet *deletedSections;
    
    NSMutableOrderedSet *insertedItems;
    NSMutableOrderedSet *deletedItems;
    NSMutableOrderedSet *updatedItems;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (loaded) return;
    loaded = YES;
    
    if (_object) {
        NSIndexPath *indexPath = [self.frc indexPathForObject:_object];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally)];
    }
    
    if (_objects) {
        for (NSManagedObject *object in _objects) {
            NSIndexPath *indexPath = [self.frc indexPathForObject:object];
            if (indexPath) {
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }
}

#pragma mark - Accessors

- (NSManagedObject *)object {
    NSManagedObject *object = [self.frc objectAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
    return object;
}

- (NSSet<NSManagedObject *> *)objects {
    NSMutableSet *objects = [NSMutableSet set];
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
        [objects addObject:object];
    }
    return objects;
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

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    insertedSections = [NSMutableIndexSet indexSet];
    deletedSections = [NSMutableIndexSet indexSet];
    
    insertedItems = [NSMutableOrderedSet orderedSet];
    deletedItems = [NSMutableOrderedSet orderedSet];
    updatedItems = [NSMutableOrderedSet orderedSet];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (type == NSFetchedResultsChangeInsert) {
        [insertedSections addIndex:sectionIndex];
    } else if (type == NSFetchedResultsChangeDelete) {
        [deletedSections addIndex:sectionIndex];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [insertedItems addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        [deletedItems addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        [deletedItems addObject:indexPath];
        [insertedItems addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeUpdate) {
        [updatedItems addObject:indexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        if (insertedSections.count > 0) {
            [self.collectionView insertSections:insertedSections];
        }
        if (deletedSections.count > 0) {
            [self.collectionView deleteSections:deletedSections];
        }
        
        if (insertedItems.count > 0) {
            [self.collectionView insertItemsAtIndexPaths:insertedItems.array];
        }
        if (deletedItems.count > 0) {
            [self.collectionView deleteItemsAtIndexPaths:deletedItems.array];
        }
        if (updatedItems.count > 0) {
            [self.collectionView reloadItemsAtIndexPaths:updatedItems.array];
        }
    } completion:nil];
}

#pragma mark - Helpers

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return @"Cell";
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end
