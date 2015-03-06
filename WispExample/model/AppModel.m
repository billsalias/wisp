//
//  AppModel.m
//  WispExample
//
//  Created by Bill Clogston on 3/5/15.
//  Copyright (c) 2015 Bill Clogston. All rights reserved.
//

#import "AppModel.h"

@interface AppModel ()
{
    int nextImage;
    NSArray *images;
}

@end


@implementation AppModel

/**
 * Initialize our state.
 */
- (id)init
{
    self = [super init];
    
    if (self) {
        nextImage = 0;
        images = @[@"images/imageOne.jpg",@"images/imageTwo.jpg",@"images/imageThree.jpg"];
    }
    
    return self;
}

/**
 * Get the next image in the series, returning to the start when we run out.
 */
- (NSString *)getNextImageName {
    // Reset if we run off the end
    if ( nextImage >= images.count )
        nextImage = 0;
    
    // Pull the path to the next image from our list
    NSString *path = images[nextImage];
    
    // Increment for the next call
    nextImage++;
    
    // return the selected image path
    return path;
}

@end
