//
//  FRCCVC.h
//  Framework
//
//  Created by Dan Kalinin on 12/8/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Controls/Controls.h>



@interface FRCCVC : CollectionViewController <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *frc;

@property NSManagedObject *object;
@property NSSet<NSManagedObject *> *objects;

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)prepareForReloadData;
- (void)reloadData;

@end
