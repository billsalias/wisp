//
//  ViewController.m
//  WispExample
//
//  Created by Bill Clogston on 3/5/15.
//  Copyright (c) 2015 Bill Clogston. All rights reserved.
//

#import "AnimationManagerViewController.h"
#import "AppModel.h"

@interface AnimationManagerViewController ()
{
    // Our single image view when executing the simple solution
    UIImageView *animatedImage;
    
    // Our two active image controllers that we are switching between
    // when executing the complex solution
    AnimateImageViewController *curImageView;
    AnimateImageViewController *nextImageView;
    
    // Out application model that manages state
    AppModel *model;
}
@end

@implementation AnimationManagerViewController

/**
 * Retrieve an image presentation controller from the story board by name.
 */
- (AnimateImageViewController *)getImageControllerWithName:(NSString *)name
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AnimateImageViewController *controller = (AnimateImageViewController *)[storyboard instantiateViewControllerWithIdentifier:name];
    controller.delegate = self;
    
    return controller;
}

/**
 * Initialize our view state and begin the first image views animation.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Instantiate our model. If this were a more complex application this might
    // require a multi stage init, e.g. init, login, updateData, that would give
    // progress feedback through the UI. For now just init it.
    model = [AppModel new];
}

/**
 * User requested the simple solution be run.
 */
- (IBAction)simplePressed:(UIButton *)sender {
    [self startSimple];
}

/**
 * User requested the complex solution be run.
 */
- (IBAction)complexPressed:(UIButton *)sender {
    [self startComplex];
}


/**
 * Kick off the second solution, the simplest one.
 */
- (void) startSimple {
    // Allocate the image we will animate
    animatedImage = [UIImageView new];
    
    // Start zoomed in
    animatedImage.contentMode = UIViewContentModeScaleAspectFill;
    animatedImage.contentScaleFactor = 3;
    animatedImage.frame = CGRectMake(-1000, -1000, 5000, 5000);
    
    // Give it an initial image
    [animatedImage setImage:[self nextImage]];
    
    // Add it to our view hierarchy
    [self.view addSubview:animatedImage];
    
    // Kick off the animation cycle
    [self animateSimple:NO];
}

/**
 * Alternate between zooming in and out and do a flip transition between images.
 */
- (void) animateSimple:(BOOL)zoomIn {
   [UIView transitionWithView:animatedImage
                     duration:5.0
                      options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut
                   animations:  ^{
                        if ( zoomIn ) {
                            animatedImage.contentScaleFactor = 3;
                            animatedImage.frame = CGRectMake(-1000, -1000, 5000, 5000);
                        }
                        else {
                            animatedImage.contentScaleFactor = 1;
                            animatedImage.frame = self.view.bounds;
                        }
                   } completion:^(BOOL finished) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [UIView transitionWithView:animatedImage duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                               [animatedImage setImage:[self nextImage]];
                           } completion:^(BOOL finished) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self animateSimple:!zoomIn];
                               });
                           }];
                       });
                   }];
}

/**
 * Kick off the complex solution.
 */
- (void) startComplex {
    // Load two instances of image view controllers here.
    // NOTE: Given the simplicity of this app I could have done this
    // programatically but I thought it was more illustrative to do
    // it with a story board and constraints.
    curImageView = [self getImageControllerWithName:@"ImageControllerOne"];
    nextImageView = [self getImageControllerWithName:@"ImageControllerTwo"];
    
    // Load the first images into the child controllers
    [curImageView setImage:[self nextImage]];
    [nextImageView setImage:[self nextImage]];
    
    // Present the first image as our initial view, no animation
    // since it is our initial view
    [self addChildViewController:curImageView];
    curImageView.view.frame = self.view.bounds;
    [self.view addSubview:curImageView.view];
    [curImageView didMoveToParentViewController:self];
    
    // Start animating the first image, when it completes the process will
    // continue with the delegate callback animationComplete
    [curImageView startAnimation];
}

/**
 * Get the next UIImage to display.
 * NOTE: This uses the simple model of images as resource. In a networked application
 * with dynamic content this would probably have a local storage folder these were
 * downloaded to we would be pulling them from with imageWithContentsOfFile or similar.
 */
- (UIImage *)nextImage {
    return [UIImage imageNamed:[model getNextImageName]];
}


/**
 * Switch to the specified view controller, clearing any existing controller.
 * NOTE: I made this more complex than it needs to be to demonstrate custome navigation
 * controllers. In the simplest model we would do a similar transition but would not bother
 * with the image children being full controllers but simply child UIImageViews. This would
 * be fine in this simple case, but if the child views that we could transition between
 * could be varied and complex it might be valuable to explore the demonstrated model. Some
 * more alternatives include:
 * - A parent controller with one image view and a child controller with a second, these are
 *   then swapped using presentViewController and dismissViewControllerAnimated.
 * - A standard navigation/tab/page controller as a parent swapping between two or more child
 *   controllers.
 * - A GLKViewController based model where the images are textures, yes we are getting out 
 *   there but you could have some fun with this one.
 */
- (void) swapControllers {
    // Let the child controllers know they are about to transition
    [curImageView willMoveToParentViewController:nil];
    [nextImageView willMoveToParentViewController:self];

    // Animate the transition
    [UIView transitionFromView:curImageView.view toView:nextImageView.view duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        // Do the actual swap
        [curImageView.view removeFromSuperview];
        [curImageView removeFromParentViewController];
        [self addChildViewController:nextImageView];
        nextImageView.view.frame = self.view.bounds;
        [self.view addSubview:nextImageView.view];
        
        // Swap the controllers.
        AnimateImageViewController *tempImageView = curImageView;
        curImageView = nextImageView;
        nextImageView = tempImageView;
        
        // Tell the child controllers their transition is complete
        [curImageView didMoveToParentViewController:nil];
        [nextImageView didMoveToParentViewController:self];
        
        // Now that the transition is complete we can start the
        // new view animating and prepare the old one for the
        // next transition
        
        // Update the image on the view we just replaced
        [nextImageView setImage:[self nextImage]];
        
        // Kick off the animation of the new image
        dispatch_async(dispatch_get_main_queue(), ^{
            [curImageView startAnimation];
        });
    }];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark AnimateImageViewControllerDelegate implementation

/**
 * A child view has completed the requested animation, transition to the next view
 * then load a new image into the previous one and kick off the next animation once
 * that transition completes.
 */
- (void)animationComplete {
    // Swap the cur and next view controllers
    [self swapControllers];
}


@end
