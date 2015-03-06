//
//  AnimateImageViewController.h
//  WispExample
//
//  Created by Bill Clogston on 3/5/15.
//  Copyright (c) 2015 Bill Clogston. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnimateImageViewControllerDelegate;

@interface AnimateImageViewController : UIViewController<UIScrollViewDelegate>

// Our contract with our parent controller, used to pass state information.
@property NSObject<AnimateImageViewControllerDelegate> *delegate;


// Set the image to display in this controller.
- (void) setImage:(UIImage *)image;

// Start animating the image, call the delegate when complete.
// NOTE: Could add a parameter to controll the animation here as well
- (void) startAnimation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightCon;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

/**
 This protocol is used to communicate status of the image animation.
 */
@protocol AnimateImageViewControllerDelegate

@required

/// Called when the zoom animation of the image is complete.
- (void)animationComplete;

@end
