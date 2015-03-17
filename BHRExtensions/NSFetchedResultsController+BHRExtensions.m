//
//  NSFetchedResultsController+BHRExtensions.m
//  BHRExtensions
//
//  Created by Benedikt Hirmer on 3/13/14.
//  Copyright (c) 2014 HIRMER.me. All rights reserved.
//

#import "NSFetchedResultsController+BHRExtensions.h"
#import "BHRCoreDataErrorManager.h"

@implementation NSFetchedResultsController (BHRExtensions)


- (void)moveObjectAtIndexPath:(NSIndexPath *)sourceIndexPath
                  toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *objects = [[self fetchedObjects] mutableCopy];

    NSManagedObject *movedObject = [self objectAtIndexPath:sourceIndexPath];

    // Remove the object we're moving from the array.
    [objects removeObject:movedObject];
    // Now re-insert it at the destination.
    [objects insertObject:movedObject atIndex:[destinationIndexPath row]];

    int i = 0;
    for (NSManagedObject *object in objects)
    {
        [object setValue:@(i++) forKey:@"sortIndex"];
    }

#warning saving here is bad when it's not the main context!
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
    {
        [[BHRCoreDataErrorManager sharedManager] showErrorAlert];
    }
}

- (void)deleteObjectsAtIndexPaths:(NSArray *)indexPaths
{
    NSManagedObjectContext *context = [self managedObjectContext];

    for (NSIndexPath *indexPath in indexPaths)
    {
        NSManagedObject *object = [self objectAtIndexPath:indexPath];
        if (object)
        {
            [context deleteObject:object];
        }
    }


#warning saving here is bad when it's not the main context!
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
        [[BHRCoreDataErrorManager sharedManager] showErrorAlert];
    }
}

- (void)flattenObjectsWithSortingKey:(NSString *)sortingKey
{
    NSArray *objects = [self fetchedObjects];

    // All of the objects are now in their correct order. Update each
    // object's displayOrder field by iterating through the array.
    int i = 0;
    for (NSManagedObject *object in objects)
    {
        [object setValue:@(i++) forKey:sortingKey];
    }
}

- (NSArray *)objectsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *objects = [NSMutableArray array];

    for (NSIndexPath *path in indexPaths)
    {
        id object = [self objectAtIndexPath:path];
        if (object)
        {
            [objects addObject:object];
        }
    }

    return objects;
}


- (id)nextObjectForObject:(id)object
{
    NSIndexPath *indexPathOfGrade = [self indexPathForObject:object];

    if (!indexPathOfGrade) {
        return nil;
    }

    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPathOfGrade];
    return [self objectAtIndexPath:nextIndexPath];
}

- (id)previousObjectForObject:(id)object
{
    NSIndexPath *indexPathOfGrade = [self indexPathForObject:object];

    if (!indexPathOfGrade) {
        return nil;
    }

    NSIndexPath *nextIndexPath = [self previousIndexPathForIndexPath:indexPathOfGrade];
    return [self objectAtIndexPath:nextIndexPath];
}


- (BOOL)isLastInSection:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [self sections][indexPath.section];
    NSUInteger sectionItemsCount = [sectionInfo numberOfObjects];

    if (indexPath.item >= (sectionItemsCount - 1)) {
        return YES;
    }

    return NO;
}

- (BOOL)isFirstInSection:(NSIndexPath *)indexPath
{
    return (indexPath.item == 0);
}

- (BOOL)isLastSection:(NSUInteger)section
{
    return ([self nextSectionForSection:section] == NSNotFound);
}

- (BOOL)isFirstSection:(NSUInteger)section
{

    return ([self previousSectionForSection:section] == NSNotFound);
}

- (NSUInteger)nextSectionForSection:(NSUInteger)section
{
    NSUInteger numberOfSections = [[self sections] count];

    if (section >= numberOfSections - 1)
    {
        return NSNotFound;
    }

    return section + 1;
}

- (NSUInteger)previousSectionForSection:(NSUInteger)section
{
    if (section == 0)
    {
        return NSNotFound;
    }

    return section - 1;
}

- (NSIndexPath *)nextIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger item = indexPath.item + 1;
    NSUInteger section = indexPath.section;

    if ([self isLastInSection:indexPath])
    {
        if ([self isLastSection:indexPath.section])
        {
            return nil;
        }

        section++;

        id<NSFetchedResultsSectionInfo>sectionInfo = [self sections][section];
        if ([sectionInfo numberOfObjects] == 0)
        {
            return nil;
        }

        item = 0;
    }

    return [NSIndexPath indexPathForItem:item
                               inSection:section];
}

- (NSIndexPath *)previousIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger item = indexPath.item - 1;
    NSUInteger section = indexPath.section;

    if ([self isFirstInSection:indexPath])
    {
        if ([self isFirstSection:indexPath.section])
        {
            return nil;
        }

        section--;

        id<NSFetchedResultsSectionInfo>sectionInfo = [self sections][section];
        NSUInteger sectionItemsCount = [sectionInfo numberOfObjects];
        if (sectionItemsCount == 0)
        {
            return nil;
        }
        
        item = sectionItemsCount - 1;
    }
    
    return [NSIndexPath indexPathForItem:item
                               inSection:section];
}

@end
