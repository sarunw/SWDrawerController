//
//  SWDrawerTransitionDelegate.m
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 28/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import "SWDrawerTransitionDelegate.h"

static CGFloat const SWOpenTransitionDuration = 0.65f;
static CGFloat const SWCloseTransitionDuration = 0.2f;
static CGFloat const SWSpringDampling = 0.65f;

@implementation SWDrawerTransitionDelegate

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.operation == SWDrawerControllerOperationOpen) {
        return SWOpenTransitionDuration;
    } else if (self.operation == SWDrawerControllerOperationClose) {
        return SWCloseTransitionDuration;
    }
    
    return 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *mainViewController = nil;
    UIViewController *topViewController = nil;
    
    if (self.operation == SWDrawerControllerOperationOpen) {
        mainViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        topViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    } else if (self.operation == SWDrawerControllerOperationClose) {
        mainViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        topViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    
    
    UIView *containerView = [transitionContext containerView];
    CGRect mainViewInitialFrame = [transitionContext initialFrameForViewController:mainViewController];
    CGRect mainViewFinalFrame   = [transitionContext finalFrameForViewController:mainViewController];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    topViewController.view.frame = [transitionContext finalFrameForViewController:topViewController];
    
    if (self.operation == SWDrawerControllerOperationOpen) {
        [containerView insertSubview:topViewController.view belowSubview:mainViewController.view];
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:SWSpringDampling initialSpringVelocity:0 options:0 animations:^{
            mainViewController.view.frame = mainViewFinalFrame;
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                mainViewController.view.frame = mainViewInitialFrame;
            }
            
            [transitionContext completeTransition:finished];
        }];
    } else if (self.operation == SWDrawerControllerOperationClose) {
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            mainViewController.view.frame = mainViewFinalFrame;
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                mainViewController.view.frame = mainViewInitialFrame;
            }
            
            [topViewController.view removeFromSuperview];
            
            [transitionContext completeTransition:finished];
        }];
    }

    
    
}

@end
