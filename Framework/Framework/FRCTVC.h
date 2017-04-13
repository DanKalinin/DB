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

@property NSFetchedResultsController *frc;
@property UITableViewRowAnimation insertionAnimation;
@property UITableViewRowAnimation deletionAnimation;

@property __kindof NSManagedObject *object;
@property NSSet<__kindof NSManagedObject *> *objects;

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
