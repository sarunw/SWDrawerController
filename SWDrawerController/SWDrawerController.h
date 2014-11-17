//
//  SWDrawerController.h
//  SWDrawerController
//
//  Created by Sarun Wongpatcharapakorn on 23/3/14.
//  Copyright (c) 2014 Sarun Wongpatcharapakorn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SWDrawerControllerOperation)
{
    SWDrawerControllerOperationNone,
    SWDrawerControllerOperationOpen,
    SWDrawerControllerOperationClose
};

typedef NS_ENUM(NSInteger, SWDrawerControllerMainViewPosition)
{
    SWDrawerControllerMainViewPositionCenter,
    SWDrawerControllerMainViewPositionBottom
};

typedef void(^SWCompletionBlock)(BOOL finished);

@class SWDrawerController;

@protocol SWDrawerControllerDelegate <NSObject>

@optional

- (id<UIViewControllerAnimatedTransitioning>)drawerController:(SWDrawerController *)drawerController animationControllerForOperation:(SWDrawerControllerOperation)operation fromViewController:(UIViewController *)fromVC;

@end

@interface SWDrawerController : UIViewController <UIViewControllerContextTransitioning>

@property (nonatomic, strong) UIViewController *topDrawerViewController;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, weak) id<SWDrawerControllerDelegate> delegate;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                   topDrawerViewController:(UIViewController *)topDrawerViewController;


- (void)openDrawerAnimated:(BOOL)animated;
- (void)openDrawerAnimated:(BOOL)animated completion:(SWCompletionBlock)completion;
- (void)toggleDrawerAnimated:(BOOL)animated completion:(SWCompletionBlock)completion;

@end
