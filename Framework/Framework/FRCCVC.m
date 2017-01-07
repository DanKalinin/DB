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



@implementation FRCCVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
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

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
//    if (type == NSFetchedResultsChangeInsert) {
//        [self.tableView insertSections:sections withRowAnimation:self.insertionAnimation];
//    } else if (type == NSFetchedResultsChangeDelete) {
//        [self.tableView deleteSections:sections withRowAnimation:self.deletionAnimation];
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    if (type == NSFetchedResultsChangeInsert) {
//        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertionAnimation];
//    } else if (type == NSFetchedResultsChangeDelete) {
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deletionAnimation];
//    } else if (type == NSFetchedResultsChangeMove) {
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deletionAnimation];
//        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertionAnimation];
//    } else if (type == NSFetchedResultsChangeUpdate) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        [self configureCell:cell atIndexPath:indexPath];
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}

#pragma mark - Helpers

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return @"Cell";
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end