//
//  AppModel.h
//  WispExample
//
//  Created by Bill Clogston on 3/5/15.
//  Copyright (c) 2015 Bill Clogston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject

// This is a forced example to demonstrate abstracting the application model
// from the UI to improve maintainability.
- (NSString *)getNextImageName;

@end
