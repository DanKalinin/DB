//
//  FRCCVC.h
//  Framework
//
//  Created by Dan Kalinin on 12/8/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@interface FRCCVC : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *frc;

@property (nonatomic) NSManagedObject *object;
@property (nonatomic) NSSet<NSManagedObject *> *objects;

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
