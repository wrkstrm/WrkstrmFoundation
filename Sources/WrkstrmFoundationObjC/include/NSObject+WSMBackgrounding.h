//
//  NSObject+WSMBackgrounding.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/18/14.
//
//

@import Foundation;
#ifdef UIKit
@import UIKit;

@interface NSObject (WSMBackgrounding)

/**
 Make any object capable of registering for background tasks.
 */

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (void)setupBackgrounding;

@end
#endif
