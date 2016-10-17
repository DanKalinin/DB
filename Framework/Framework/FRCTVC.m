//
//  FRCTVC.m
//  Framework
//
//  Created by Dan Kalinin on 17/10/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "FRCTVC.h"



@interface FRCTVC ()

@end



@implementation FRCTVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.insertionAnimation = self.deletionAnimation = UITableViewRowAnimationFade;
        self.cellIdentifier = @"Cell";
    }
    return self;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeMove) {
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSArray *indexPathsToInsert = @[newIndexPath];
    NSArray *indexPathsToDelete = @[indexPath];
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeUpdate) {
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Helpers

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end
