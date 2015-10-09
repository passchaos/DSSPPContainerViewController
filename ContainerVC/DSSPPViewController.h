//
//  DSSPPContainerViewController.h
//  ContainerVC
//
//  Created by passchaos on 15/10/9.
//  Copyright © 2015年 passchaos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSSPPViewController;

@protocol DSSPPViewControllerDelegate <NSObject>

- (void)ppViewController:(DSSPPViewController *)ppViewController
 didSelectViewController:(UIViewController *)viewController;

@end

@interface DSSPPViewController : UIViewController

@property(nonatomic, copy)
    NSArray<__kindof UIViewController *> *viewControllers;
@property(nonatomic, strong) NSNumber *scrollableZoneHeight;

@end
