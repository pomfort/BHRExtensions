//
//  UIImage+Extensions.h
//  VirtualUIElements
//
//  Created by Benedikt Hirmer on 26.01.13.
//  Copyright (c) 2013 Institute of Ergonomics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BHRExtensions)

- (NSString *)saveJPEGToDocumentsDirectoryWithName:(NSString *)name;
- (NSString *)saveToDocumentsDirectoryWithName:(NSString *)name;

- (UIImage *)imageCroppedToRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;


+ (UIImage *)imageRetinaWithContentsOfFile:(NSString *)file;

/**
 * Colorizes the clipping masked image
 */
- (UIImage *)colorizedImageWithColor:(UIColor *)color;
- (UIImage *)grayscaleImage;
+ (UIImage*)solidColorImageWithColor:(UIColor*)color;

- (UIImage *)imageWithFixedRotation;

#pragma mark - AppIcon

/**
 * Both work for iOS version >= 7
 */
+ (UIImage *)iPhoneAppIcon;
+ (UIImage *)iPadAppIcon;

@end
