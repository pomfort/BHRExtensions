//
//  UIViewController+BHRExtensions.m
//  BHRExtensions
//
//  Created by Benedikt Hirmer on 6/29/14.
//  Copyright (c) 2014 HIRMER.me. All rights reserved.
//

#import "UIViewController+BHRExtensions.h"

@implementation UIViewController (BHRExtensions)


+ (UIViewController*)topViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    return [rootViewController topVisibleViewController];
}

- (UIViewController*)topVisibleViewController
{
	if ([self isKindOfClass:[UIAlertController class]])
	{
		return nil;
	}
    if ([self isKindOfClass:[UITabBarController class]])
    {
        UITabBarController* tabBarController = (UITabBarController*)self;
        return [tabBarController.selectedViewController topVisibleViewController];
    }
    else if ([self isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*)self;

		UIViewController *topVisibleVC = [navigationController.visibleViewController topVisibleViewController];
		if (topVisibleVC)
		{
			return [navigationController.visibleViewController topVisibleViewController];
		}

		return [[navigationController topViewController] topVisibleViewController];
    }
    else if (self.presentedViewController &&
			 ![self.presentedViewController isKindOfClass:[UIAlertController class]])
    {
        return [self.presentedViewController topVisibleViewController];
    }
    else if (self.childViewControllers.count > 0)
    {
        return [self.childViewControllers.lastObject topVisibleViewController];
    }

    return self;
}


- (void)addConstraintBasedChildViewController:(UIViewController *)childViewController
							childViewRelation:(BHRChildViewRelation)childViewRelation
{
	UIView *childView = childViewController.view;
	[self addChildViewController:childViewController];
    [self addConstraintBasedSubview:childView relation:childViewRelation];
	[childViewController didMoveToParentViewController:self];
}

- (void)addConstraintBasedSubview:(UIView *)subview
                         relation:(BHRChildViewRelation)childViewRelation
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;

    subview.frame = self.view.bounds;
    [self.view addSubview:subview];

    NSDictionary *views = @{ @"childView": subview,
                             @"topLayoutGuide": self.topLayoutGuide,
                             @"bottomLayoutGuide": self.bottomLayoutGuide };

    if (childViewRelation == BHRChildViewRelationToLayoutGuides)
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][childView][bottomLayoutGuide]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    }
    else
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

@end
