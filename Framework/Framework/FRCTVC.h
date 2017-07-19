//
//  FRCTVC.h
//  Framework
//
//  Created by Dan Kalinin on 17/10/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@interface FRCTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property IBInspectable UITableViewRowAnimation rowAnimation; // Row animation for content changes

@property IBInspectable NSString *orderKeyPath; // Key path for numeric property of the object which defines it's order in table view. The default value is @"order".
@property IBInspectable BOOL orderInSection; // YES - recompute the order when moving row within section. NO - across the table.

@property NSFetchedResultsController *frc; // Controller maintaining the fetch request. Initialize, set delegate and perform the fetch in overriden - viewDidLoad method.

@property NSManagedObject *object; // Object which cell is selected on appearance with scrolling to central position
@property NSSet<NSManagedObject *> *objects; // Objects which cells are selected on appearance without scrolling

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath; // Reusable cell identifier at specified index path. The default value is @"Cell". Override to specify different value.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath; // Override to configure the cell instead of - tableView:cellForRowAtIndexPath:

- (void)prepareForReloadData; // Pause to deliver content changes setting @ frc delegate to nil
- (void)reloadData; // Perform the fetch, reload the table view and restore @ frc delegate

@end
