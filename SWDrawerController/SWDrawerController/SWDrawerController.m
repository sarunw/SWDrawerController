//
//  SWDrawerController.m
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import "SWDrawerController.h"
#import "SWDrawerTransitionDelegate.h"

@interface SWDrawerController ()

@property (nonatomic, assign, getter = isOpen) BOOL open;

// UIViewControllerContextTransitioning
@property (nonatomic, copy) SWCompletionBlock completionBlock;
@property (nonatomic, strong) SWDrawerTransitionDelegate *defaultOpenAnimationController;
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, assign) BOOL isInteractive;
@property (nonatomic, assign) BOOL transitionWasCancelled;
@property (nonatomic, assign) SWDrawerControllerOperation currentOperation; // So we know how to handle when completionTransition
@property (nonatomic, assign) SWDrawerControllerMainViewPosition currentMainViewPosition;

@end

@implementation SWDrawerController

#pragma mark - Lifecycle
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController topDrawerViewController:(UIViewController *)topDrawerViewController
{
    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
        self.topDrawerViewController = topDrawerViewController;
        self.currentMainViewPosition = SWDrawerControllerMainViewPositionCenter;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mainViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mainViewController endAppearanceTransition];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.mainViewController == nil) {
        [NSException raise:@"Missing mainViewController" format:@"Set the mainViewController before loading  SWDrawerController"];
    }
    [self.view addSubview:self.mainViewController.view];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"bounf %@", NSStringFromCGRect(self.view.bounds));
    
    NSLog(@"main %@", NSStringFromCGRect([self finalFrameForViewController:self.mainViewController]));
    NSLog(@"top %@", NSStringFromCGRect([self finalFrameForViewController:self.topDrawerViewController]));
    if (self.currentOperation == SWDrawerControllerOperationNone) {
        NSLog(@"layout dai");
        self.mainViewController.view.frame = [self mainViewFrameForPosition:self.currentMainViewPosition];
        self.topDrawerViewController.view.frame = self.view.bounds;
    }
}

#pragma mark - Custom Accessors
- (SWDrawerTransitionDelegate *)defaultOpenAnimationController
{
    if (_defaultOpenAnimationController) {
        return _defaultOpenAnimationController;
    }
    
    _defaultOpenAnimationController = [[SWDrawerTransitionDelegate alloc] init];
    return _defaultOpenAnimationController;
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    if (_mainViewController == mainViewController) {
        return;
    }
    
    _mainViewController = mainViewController;
    
    
    if (_mainViewController) {
        [self addChildViewController:_mainViewController];
        [_mainViewController didMoveToParentViewController:self];
        
        
        if ([self isViewLoaded]) {
            [_mainViewController beginAppearanceTransition:YES animated:NO];
            [self.view addSubview:_mainViewController.view];
            [_mainViewController endAppearanceTransition];
        }
    }
}

- (void)setTopDrawerViewController:(UIViewController *)topDrawerViewController
{
    UIViewController *oldTopViewController = _topDrawerViewController;
    
    [oldTopViewController.view removeFromSuperview];
    [oldTopViewController willMoveToParentViewController:nil];
    [oldTopViewController beginAppearanceTransition:NO animated:NO];
    [oldTopViewController removeFromParentViewController];
    [oldTopViewController endAppearanceTransition];
    
    _topDrawerViewController = topDrawerViewController;
    
    if (_topDrawerViewController) {
        [self addChildViewController:_topDrawerViewController];
        [_topDrawerViewController didMoveToParentViewController:self];
        
        if ([self isViewLoaded] && self.isOpen) {
            [_topDrawerViewController beginAppearanceTransition:YES animated:NO];
            [self.view insertSubview:_topDrawerViewController.view belowSubview:self.mainViewController.view];
            [_topDrawerViewController endAppearanceTransition];
        }
    }
}

#pragma mark - Public
- (void)openDrawerAnimated:(BOOL)animated
{
    [self openDrawerAnimated:animated completion:nil];
}

- (void)openDrawerAnimated:(BOOL)animated completion:(SWCompletionBlock)completion
{
    self.isAnimated = animated;
    self.completionBlock = completion;
    self.currentOperation = SWDrawerControllerOperationOpen;
    
    SWDrawerControllerOperation operation = [self operationFromPosition:self.currentMainViewPosition toPosition:SWDrawerControllerMainViewPositionBottom];
    
    self.defaultOpenAnimationController.operation = operation;
    [self.topDrawerViewController beginAppearanceTransition:YES animated:NO];
    [self.defaultOpenAnimationController animateTransition:self];
    
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    self.currentOperation = SWDrawerControllerOperationClose;
    self.defaultOpenAnimationController.operation = SWDrawerControllerOperationClose;
    [self.topDrawerViewController beginAppearanceTransition:NO animated:NO];
    [self.defaultOpenAnimationController animateTransition:self];

}

- (void)toggleDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if (self.isOpen) {
        [self closeDrawerAnimated:animated completion:completion];
    } else {
        [self openDrawerAnimated:animated completion:completion];
    }
}

#pragma mark - Private
#pragma mark - Animation
- (SWDrawerControllerOperation)operationFromPosition:(SWDrawerControllerMainViewPosition)fromPosition toPosition:(SWDrawerControllerMainViewPosition)toPosition
{
    if (fromPosition == SWDrawerControllerMainViewPositionCenter &&
        toPosition == SWDrawerControllerMainViewPositionBottom) {
        return SWDrawerControllerOperationOpen;
    } else if (fromPosition == SWDrawerControllerMainViewPositionBottom &&
               toPosition == SWDrawerControllerMainViewPositionCenter) {
        return SWDrawerControllerOperationClose;
    } else {
        return SWDrawerControllerOperationNone;
    }
}

- (void)animateOperation:(SWDrawerControllerOperation)operation
{
    if ([self.delegate respondsToSelector:@selector(drawerController:animationControllerForOperation:fromViewController:)]) {
        // TODO: in case delegate has custom animation
    } else {
        
    }
    
    if (operation == SWDrawerControllerOperationOpen) {
       
    }
}

#pragma mark - UIViewControllerContextTransitioning
- (UIView *)containerView
{
    return self.view;
}

- (BOOL)isAnimated
{
    return _isAnimated;
}

- (BOOL)isInteractive
{
    return _isInteractive;
}

- (BOOL)transitionWasCancelled
{
    return _transitionWasCancelled;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationCustom;
}

// Get notified when the transition animation is done.
- (void)completeTransition:(BOOL)didComplete
{
    if (self.currentOperation == SWDrawerControllerOperationOpen) {
        [self.topDrawerViewController endAppearanceTransition];
        self.currentMainViewPosition = SWDrawerControllerMainViewPositionBottom;
        self.open = YES;
    } else if (self.currentOperation == SWDrawerControllerOperationClose) {
        [self.topDrawerViewController endAppearanceTransition];
        self.currentMainViewPosition = SWDrawerControllerMainViewPositionCenter;
        self.open = NO;
    }
    
    if (self.completionBlock) {
        self.completionBlock(didComplete);
        self.completionBlock = nil;
    }
    
    // Clear state
    self.currentOperation = SWDrawerControllerOperationNone;
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    if (self.currentOperation == SWDrawerControllerOperationOpen) {
        if (key == UITransitionContextFromViewControllerKey) {
            return self.mainViewController;
        }
        if (key == UITransitionContextToViewControllerKey) {
            return self.topDrawerViewController;
        }
    } else if (self.currentOperation == SWDrawerControllerOperationClose) {
        if (key == UITransitionContextFromViewControllerKey) {
            return self.topDrawerViewController;
        }
        if (key == UITransitionContextToViewControllerKey) {
            return self.mainViewController;
        }
    }
    
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    if (self.currentOperation == SWDrawerControllerOperationOpen) {
        if ([vc isEqual:self.mainViewController]) {
            return self.view.bounds;
        }
        if ([vc isEqual:self.topDrawerViewController]) {
            return self.view.bounds;
        }
    } else if (self.currentOperation == SWDrawerControllerOperationClose) {
        if ([vc isEqual:self.mainViewController]) {
            CGRect rect = self.view.bounds;
            rect.origin.y = self.view.bounds.size.height - 50;
            return rect;
        }
        
        if ([vc isEqual:self.topDrawerViewController]) {
            return self.view.bounds;
        }
    }
    
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    if (self.currentOperation == SWDrawerControllerOperationOpen) {
        if ([vc isEqual:self.mainViewController]) {
            CGRect rect = self.view.bounds;
            rect.origin.y = self.view.bounds.size.height - 50;
            return rect;
        }
        if ([vc isEqual:self.topDrawerViewController]) {
            return self.view.bounds;
        }
    } else if (self.currentOperation == SWDrawerControllerOperationClose) {
        if ([vc isEqual:self.mainViewController]) {
            return self.view.bounds;
        }
        
        if ([vc isEqual:self.topDrawerViewController]) {
            return self.view.bounds;
        }
    }
    
    return CGRectZero;
}

- (CGRect)mainViewFrameForPosition:(SWDrawerControllerMainViewPosition)position
{
    CGRect containerViewFrame = self.view.bounds;
    switch (position) {
        case SWDrawerControllerMainViewPositionCenter:
            return containerViewFrame;
            break;
        case SWDrawerControllerMainViewPositionBottom:
            containerViewFrame.origin.y = self.view.bounds.size.height - 50;
            return containerViewFrame;
            break;
        default:
            return CGRectZero;
    }
}


@end
