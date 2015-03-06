//
//  AnimateImageViewController.m
//  WispExample
//
//  Created by Bill Clogston on 3/5/15.
//  Copyright (c) 2015 Bill Clogston. All rights reserved.
//

#import "AnimateImageViewController.h"

@interface AnimateImageViewController ()
{
    UIImage *curImage;
}

@end

@implementation AnimateImageViewController

/**
 *
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make sure we are the delegate and we have a large zoom range to play with
    self.imageScrollView.delegate = self;
    self.imageScrollView.maximumZoomScale = 100;
    self.imageScrollView.minimumZoomScale = 0.1;
}

/**
 * Called to change the image displayed by this controller.
 */
- (void)setImage:(UIImage *)image {
    // Make sure out view heirarchy is loaded
    [self view];
    
    // Update out image views image
    [self.imageView setImage:image];
    curImage = image;
    
    // Adjust the constraints to reflect the new image size
    self.imageHeightCon.constant = image.size.height;
    self.imageWidthCon.constant = image.size.width;

    // Reset the scroll view to default settings
    self.imageScrollView.zoomScale = 1;
    self.imageScrollView.contentOffset = CGPointMake(0, 0);
}

/**
 *
 */
- (void)startAnimation {
    // Give the view hierarchy a chance to settle after changing images. This is
    // needed because layout logic, including constraint evaluation, happens on
    // the main thread and if setImage and then this are both called on the main
    // thread without an async call then that logic doesn't get to run before we
    // start doing calculations on the view layout. This would not be needed if
    // this was trigger by user action since that is inherently asynchronous.
    // This could also be avoided if we depend on a fixed scroll view frame size,
    // or atleast one that is deterministic based device.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Figure out some characteristics of the image
        float xRatio = curImage.size.width/(float)self.imageScrollView.frame.size.width;
        float yRatio = curImage.size.height/(float)self.imageScrollView.frame.size.height;
        
        // Use the lesser of the scale factors to have the screen full but minimize
        // the lost image area
        if ( xRatio < yRatio ) {
            self.imageScrollView.zoomScale = 1/xRatio;
            self.imageScrollView.bounds = self.imageScrollView.frame;
        }
        else {
            self.imageScrollView.zoomScale = 1/yRatio;
            self.imageScrollView.bounds = self.imageScrollView.frame;
        }
        // Scroll and zoom to a random point, well picked at random by me, to vary this
        // we could literally make it random or better yet spend some time finding
        // patterns that look good.
        [UIView animateWithDuration:5.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.imageScrollView zoomToRect:CGRectMake(curImage.size.width-200, 200, 200,200) animated:false];
        } completion:^(BOOL finished) {
            [self.delegate animationComplete];
        }];
   });
}

////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
@end
