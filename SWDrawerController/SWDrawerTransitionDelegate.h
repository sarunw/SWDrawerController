//
//  SWDrawerTransitionDelegate.h
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 28/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWDrawerController.h"

@interface SWDrawerTransitionDelegate : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) SWDrawerControllerOperation operation;

@end
