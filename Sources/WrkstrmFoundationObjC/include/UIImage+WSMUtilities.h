//
//  UIImage+WSMUtilities.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#ifdef UIKit
@import UIKit;

@interface UIImage (WSMUtilities)

+ (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize;

- (UIImage *)imageAtRect:(CGRect)rect;

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
#endif  // UIKit
