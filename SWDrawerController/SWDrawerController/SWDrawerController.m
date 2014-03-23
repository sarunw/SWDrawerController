//
//  SWDrawerController.m
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import "SWDrawerController.h"

CGFloat const SWDrawerDefaultAnimationVelocity = 840.0f;

static NSString *SWDrawerTopDrawerKey = @"SWDrawerTopDrawer";
static NSString *SWDrawerCenterKey = @"SWDrawerCenter";
static NSString *SWDrawerOpenSideKey = @"SWDrawerOpenSide";

@interface SWDrawerCenterContainerView : UIView

@property (nonatomic, assign) SWDrawerOpenCenterInteractionMode centerInteractionMode;
@property (nonatomic, assign) SWDrawerSide openSide;

@end

@implementation SWDrawerCenterContainerView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView &&
       self.openSide != SWDrawerSideNone){
        UINavigationBar * navBar = [self navigationBarContainedWithinSubviewsOfView:self];
        CGRect navBarFrame = [navBar convertRect:navBar.bounds toView:self];
        if((self.centerInteractionMode == SWDrawerOpenCenterInteractionModeNavigationBarOnly &&
            CGRectContainsPoint(navBarFrame, point) == NO) ||
           self.centerInteractionMode == SWDrawerOpenCenterInteractionModeNone){
            hitView = nil;
        }
    }
    return hitView;
}

-(UINavigationBar*)navigationBarContainedWithinSubviewsOfView:(UIView*)view{
    UINavigationBar * navBar = nil;
    for(UIView * subview in [view subviews]){
        if([view isKindOfClass:[UINavigationBar class]]){
            navBar = (UINavigationBar*)view;
            break;
        }
        else {
            navBar = [self navigationBarContainedWithinSubviewsOfView:subview];
            if (navBar != nil) {
                break;
            }
        }
    }
    return navBar;
}
@end

@interface SWDrawerController ()

@property (nonatomic, strong) SWDrawerCenterContainerView * centerContainerView;
@property (nonatomic, strong) UIView * childControllerContainerView;
@property (nonatomic, assign, getter = isAnimatingDrawer) BOOL animatingDrawer;


@end

@implementation SWDrawerController

#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        [self commonSetup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	self = [super initWithCoder:aDecoder];
	if (self) {
        [self commonSetup];
	}
	return self;
}

- (id)initWithCenterViewController:(UIViewController *)centerViewController topDrawerViewController:(UIViewController *)topDrawerViewController
{
    NSParameterAssert(centerViewController);
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)commonSetup{
    self.animationVelocity = SWDrawerDefaultAnimationVelocity;
//    [self setMaximumLeftDrawerWidth:MMDrawerDefaultWidth];
//    [self setMaximumRightDrawerWidth:MMDrawerDefaultWidth];
//    
//    [self setAnimationVelocity:MMDrawerDefaultAnimationVelocity];
//    
//    [self setShowsShadow:YES];
//    [self setShouldStretchDrawer:YES];
//    
//    [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
//    [self setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeNavigationBarOnly];
}

#pragma mark - Custom Accessors
- (void)setTopDrawerViewController:(UIViewController *)topDrawerViewController
{
    [self setDrawerViewController:topDrawerViewController forSide:SWDrawerSideTop];
}

- (void)setDrawerViewController:(UIViewController *)viewController forSide:(SWDrawerSide)drawerSide{
    NSParameterAssert(drawerSide != SWDrawerSideNone);
    
    UIViewController *currentSideViewController = [self sideDrawerViewControllerForSide:drawerSide];
    if (currentSideViewController != nil) {
        [currentSideViewController beginAppearanceTransition:NO animated:NO];
        [currentSideViewController.view removeFromSuperview];
        [currentSideViewController endAppearanceTransition];
        [currentSideViewController removeFromParentViewController];
    }
    
    UIViewAutoresizing autoResizingMask = 0;
    if (drawerSide == MMDrawerSideLeft) {
        _leftDrawerViewController = viewController;
        autoResizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
    }
    else if(drawerSide == MMDrawerSideRight){
        _rightDrawerViewController = viewController;
        autoResizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    }
    
    if(viewController){
        [self addChildViewController:viewController];
        
        if((self.openSide == drawerSide) &&
           [self.childControllerContainerView.subviews containsObject:self.centerContainerView]){
            [self.childControllerContainerView insertSubview:viewController.view belowSubview:self.centerContainerView];
            [viewController beginAppearanceTransition:YES animated:NO];
            [viewController endAppearanceTransition];
        }
        else{
            [self.childControllerContainerView addSubview:viewController.view];
            [self.childControllerContainerView sendSubviewToBack:viewController.view];
            [viewController.view setHidden:YES];
        }
        [viewController didMoveToParentViewController:self];
        [viewController.view setAutoresizingMask:autoResizingMask];
        [viewController.view setFrame:viewController.mm_visibleDrawerFrame];
    }
}

- (UIView *)childControllerContainerView
{
    if(_childControllerContainerView == nil){
        //Issue #152 (https://github.com/mutualmobile/MMDrawerController/issues/152)
        //Turns out we have two child container views getting added to the view during init,
        //because the first request self.view.bounds was kicking off a viewDidLoad, which
        //caused us to be able to fall through this check twice.
        //
        //The fix is to grab the bounds, and then check again that the child container view has
        //not been created.
        CGRect childContainerViewFrame = self.view.bounds;
        if(_childControllerContainerView == nil){
            _childControllerContainerView = [[UIView alloc] initWithFrame:childContainerViewFrame];
            [_childControllerContainerView setBackgroundColor:[UIColor clearColor]];
            [_childControllerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            [self.view addSubview:_childControllerContainerView];
        }
        
    }
    return _childControllerContainerView;

}

#pragma mark - State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [super encodeRestorableStateWithCoder:coder];
    if (self.topDrawerViewController){
        [coder encodeObject:self.topDrawerViewController forKey:SWDrawerTopDrawerKey];
    }
    
    if (self.centerViewController){
        [coder encodeObject:self.centerViewController forKey:SWDrawerCenterKey];
    }
    
    [coder encodeInteger:self.openSide forKey:SWDrawerOpenSideKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    UIViewController *controller;
    SWDrawerSide openside;
    
    [super decodeRestorableStateWithCoder:coder];
    
    if ((controller = [coder decodeObjectForKey:SWDrawerTopDrawerKey])){
        self.topDrawerViewController = controller;
    }
    
    if ((controller = [coder decodeObjectForKey:SWDrawerCenterKey])){
        self.centerViewController = controller;
    }
    
    if ((openside = [coder decodeIntegerForKey:SWDrawerOpenSideKey])){
        
        [self openDrawerSide:openside animated:false completion:nil];
    }
}

#pragma mark - Open/Close methods
-(void)openDrawerSide:(SWDrawerSide)drawerSide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    NSParameterAssert(drawerSide != SWDrawerSideNone);
    
    [self openDrawerSide:drawerSide animated:animated velocity:self.animationVelocity animationOptions:UIViewAnimationOptionCurveEaseInOut completion:completion];
}

-(void)openDrawerSide:(SWDrawerSide)drawerSide animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion{
    NSParameterAssert(drawerSide != SWDrawerSideNone);
    if (self.isAnimatingDrawer) {
        if(completion){
            completion(NO);
        }
    }
    else {
        self.animatingDrawer = animated;
        UIViewController * sideDrawerViewController = [self sideDrawerViewControllerForSide:drawerSide];
        CGRect visibleRect = CGRectIntersection(self.childControllerContainerView.bounds,sideDrawerViewController.view.frame);
        BOOL drawerFullyCovered = (CGRectContainsRect(self.centerContainerView.frame, visibleRect) ||
                                   CGRectIsNull(visibleRect));
        if(drawerFullyCovered){
            [self prepareToPresentDrawer:drawerSide animated:animated];
        }
        
        if(sideDrawerViewController){
            CGRect newFrame;
            CGRect oldFrame = self.centerContainerView.frame;
            if(drawerSide == MMDrawerSideLeft){
                newFrame = self.centerContainerView.frame;
                newFrame.origin.x = self.maximumLeftDrawerWidth;
            }
            else {
                newFrame = self.centerContainerView.frame;
                newFrame.origin.x = 0-self.maximumRightDrawerWidth;
            }
            
            CGFloat distance = ABS(CGRectGetMinX(oldFrame)-newFrame.origin.x);
            NSTimeInterval duration = MAX(distance/ABS(velocity),MMDrawerMinimumAnimationDuration);
            
            [UIView
             animateWithDuration:(animated?duration:0.0)
             delay:0.0
             options:options
             animations:^{
                 [self setNeedsStatusBarAppearanceUpdateIfSupported];
                 [self.centerContainerView setFrame:newFrame];
                 [self updateDrawerVisualStateForDrawerSide:drawerSide percentVisible:1.0];
             }
             completion:^(BOOL finished) {
                 //End the appearance transition if it already wasn't open.
                 if(drawerSide != self.openSide){
                     [sideDrawerViewController endAppearanceTransition];
                 }
                 [self setOpenSide:drawerSide];
                 
                 [self resetDrawerVisualStateForDrawerSide:drawerSide];
                 [self setAnimatingDrawer:NO];
                 if(completion){
                     completion(finished);
                 }
             }];
        }
    }
}

#pragma mark - Helpers
-(UIViewController*)sideDrawerViewControllerForSide:(SWDrawerSide)drawerSide{
    UIViewController * sideDrawerViewController = nil;
    if(drawerSide != SWDrawerSideNone){
        sideDrawerViewController = [self childViewControllerForSide:drawerSide];
    }
    return sideDrawerViewController;
}

-(UIViewController*)childViewControllerForSide:(SWDrawerSide)drawerSide{
    UIViewController * childViewController = nil;
    switch (drawerSide) {
        case SWDrawerSideTop:
            childViewController = self.topDrawerViewController;
            break;
        case SWDrawerSideNone:
            childViewController = self.centerViewController;
            break;
    }
    return childViewController;
}

-(void)prepareToPresentDrawer:(SWDrawerSide)drawer animated:(BOOL)animated{
    SWDrawerSide drawerToHide = SWDrawerSideNone;
    
    UIViewController * sideDrawerViewControllerToPresent = [self sideDrawerViewControllerForSide:drawer];
    UIViewController * sideDrawerViewControllerToHide = [self sideDrawerViewControllerForSide:drawerToHide];
    
    [self.childControllerContainerView sendSubviewToBack:sideDrawerViewControllerToHide.view];
    [sideDrawerViewControllerToHide.view setHidden:YES];
    [sideDrawerViewControllerToPresent.view setHidden:NO];
    [self resetDrawerVisualStateForDrawerSide:drawer];
    [sideDrawerViewControllerToPresent.view setFrame:sideDrawerViewControllerToPresent.mm_visibleDrawerFrame];
    [self updateDrawerVisualStateForDrawerSide:drawer percentVisible:0.0];
    [sideDrawerViewControllerToPresent beginAppearanceTransition:YES animated:animated];
}



@end
