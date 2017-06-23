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

@property IBInspectable UITableViewRowAnimation rowAnimation;

@property IBInspectable NSString *orderKeyPath;
@property IBInspectable BOOL orderInSection;

@property NSFetchedResultsController *frc;

@property NSManagedObject *object;
@property NSSet<NSManagedObject *> *objects;

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
