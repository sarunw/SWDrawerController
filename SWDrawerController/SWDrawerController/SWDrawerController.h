//
//  SWDrawerController.h
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SWDrawerSide){
    SWDrawerSideNone = 0,
    SWDrawerSideTop,
};

typedef NS_ENUM(NSInteger, SWDrawerOpenCenterInteractionMode) {
    SWDrawerOpenCenterInteractionModeNone,
    SWDrawerOpenCenterInteractionModeFull,
    SWDrawerOpenCenterInteractionModeNavigationBarOnly,
};

@interface SWDrawerController : UIViewController

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *topDrawerViewController;

@property (nonatomic, assign, readonly) SWDrawerSide openSide;
@property (nonatomic, assign) CGFloat animationVelocity;

-(id)initWithCenterViewController:(UIViewController *)centerViewController topDrawerViewController:(UIViewController *)topDrawerViewController;

@end
