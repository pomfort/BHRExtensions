//
//  UIViewController+BHRExtensions.h
//  BHRExtensions
//
//  Created by Benedikt Hirmer on 6/29/14.
//  Copyright (c) 2014 HIRMER.me. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BHRChildViewRelation) {
	BHRChildViewRelationToSuperview,
	BHRChildViewRelationToLayoutGuides,
};

@interface UIViewController (BHRExtensions)

+ (UIViewController*)topViewController;
- (UIViewController*)topVisibleViewController;

/**
 * Adds a constraint based child view controller filling out the whole space by respecting childViewRelationType
 */
- (void)addConstraintBasedChildViewController:(UIViewController *)childViewController
							childViewRelation:(BHRChildViewRelation)childViewRelation;

- (void)addConstraintBasedSubview:(UIView *)subview
                         relation:(BHRChildViewRelation)childViewRelation;

@end
