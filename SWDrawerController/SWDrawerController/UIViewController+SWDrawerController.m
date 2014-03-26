//
//  UIViewController+SWDrawerController.m
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 3/26/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import "UIViewController+SWDrawerController.h"

@implementation UIViewController (SWDrawerController)

- (SWDrawerController *)drawerViewController
{
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    while (!(viewController == nil || [viewController isKindOfClass:[SWDrawerController class]])) {
        viewController = viewController.parentViewController ? viewController.parentViewController : viewController.presentingViewController;
    }
    
    return (SWDrawerController *)viewController;
}

@end
