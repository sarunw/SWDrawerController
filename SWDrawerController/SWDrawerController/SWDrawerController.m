//
//  SWDrawerController.m
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import "SWDrawerController.h"


@interface SWDrawerController ()

@property (nonatomic, strong) UIView *mainContainerView;

@property (nonatomic, assign, getter = isOpen) BOOL open;

@end

@implementation SWDrawerController

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController topDrawerViewController:(UIViewController *)topDrawerViewController
{
    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
        self.topDrawerViewController = topDrawerViewController;
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
    [self.mainContainerView addSubview:self.mainViewController.view];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

#pragma mark - Custom Accessors
- (UIView *)mainContainerView
{
    if (_mainContainerView) {
        return _mainContainerView;
    }
    
    NSLog(@"%f %f", self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"%f %f", self.view.frame.size.width, self.view.frame.size.height);

    
    _mainContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainContainerView.backgroundColor = [UIColor orangeColor];
    _mainContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_mainContainerView];
    
    
    return _mainContainerView;
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
            [self.mainContainerView addSubview:_mainViewController.view];
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
            [self.view insertSubview:_topDrawerViewController.view belowSubview:self.mainContainerView];
            [_topDrawerViewController endAppearanceTransition];
        }
    }
}

#pragma mark - Public
- (void)openDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if (self.topDrawerViewController == nil) {
        // Can't be show if no top view controller
        return;
    }
    
    [self.topDrawerViewController beginAppearanceTransition:YES animated:NO];
    [self.view insertSubview:self.topDrawerViewController.view belowSubview:self.mainContainerView];
    
    CGRect beginRect = self.mainContainerView.frame;
    CGRect endRect = beginRect;
    endRect.origin.y = self.view.bounds.size.height - 50;
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.65f initialSpringVelocity:0 options:0 animations:^{
        self.mainContainerView.frame = endRect;
    } completion:^(BOOL finished) {
        [self.topDrawerViewController endAppearanceTransition];
        self.open = YES;
        if (completion) {
            completion(finished);
        }
    }];
    
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    CGRect beginRect = self.mainContainerView.frame;
    CGRect endRect = beginRect;
    endRect.origin.y = 0;
    
    [self.topDrawerViewController beginAppearanceTransition:NO animated:animated];
    
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
                self.mainContainerView.frame = endRect;
    } completion:^(BOOL finished) {
        [self.topDrawerViewController endAppearanceTransition];
        
        [self.topDrawerViewController.view removeFromSuperview];
        
        self.open = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)toggleDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if (self.isOpen) {
        [self closeDrawerAnimated:animated completion:completion];
    } else {
        [self openDrawerAnimated:animated completion:completion];
    }
}

@end
