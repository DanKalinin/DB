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

@property IBInspectable NSString *orderKeyPath; // Key path of object's numeric property which defines it's order in table view. The default value is @"order".
@property IBInspectable BOOL orderInSection;

@property NSFetchedResultsController *frc;

@property NSManagedObject *object; // Object which cell is selected on appearance with scrolling to central position
@property NSSet<NSManagedObject *> *objects; // Objects which cells are selected on appearance without scrolling

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath; // Reusable cell identifier at specified index path. The default value is @"Cell". Override to specify different value.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath; // Override to configure the cell instead of - tableView:cellForRowAtIndexPath:

- (void)prepareForReloadData;
- (void)reloadData;

@end
