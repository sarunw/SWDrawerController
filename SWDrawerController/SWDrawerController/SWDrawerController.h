//
//  SWDrawerController.h
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWDrawerController : UIViewController

@property (nonatomic, strong) UIViewController *topDrawerViewController;
@property (nonatomic, strong) UIViewController *mainViewController;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                   topDrawerViewController:(UIViewController *)topDrawerViewController;

- (void)openDrawerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)toggleDrawerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;

@end
