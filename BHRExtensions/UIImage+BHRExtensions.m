//
//  UIImage+Extensions.m
//  VirtualUIElements
//
//  Created by Benedikt Hirmer on 26.01.13.
//  Copyright (c) 2013 Institute of Ergonomics. All rights reserved.
//

#import "UIImage+BHRExtensions.h"
#import "NSObject+BHRExtensions.h"
#import "UIDevice+BHRExtensions.h"

@implementation UIImage (BHRExtensions)


#pragma mark - Saving Images

- (NSString *)saveJPEGToDocumentsDirectoryWithName:(NSString *)name
{
    NSData *pngData = UIImageJPEGRepresentation(self, 0.9f);

    NSString *documentsPath = [NSObject documentsDirectory];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", name]];
    [pngData writeToFile:filePath atomically:YES];

    return filePath;
}


- (NSString *)saveToDocumentsDirectoryWithName:(NSString *)name
{
	NSData *pngData = UIImagePNGRepresentation(self);

	NSString *documentsPath = [NSObject documentsDirectory];
	NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
	[pngData writeToFile:filePath atomically:YES];

    return filePath;
}

#pragma mark - Cropping/Scaling

- (UIImage *)imageCroppedToRect:(CGRect)rect
{
	UIGraphicsBeginImageContextWithOptions(rect.size, false, [self scale]);

	[self drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];

	UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return croppedImage;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {

	UIImage *sourceImage = self;
	UIImage *newImage = nil;

	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;

	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;

	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;

	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

	if (!CGSizeEqualToSize(imageSize, targetSize)) {

		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		if (widthFactor < heightFactor)
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;

		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;

		// center the image

		if (widthFactor < heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		} else if (widthFactor > heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}


	// this is actually the interesting part:

	UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0f);

	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;

	[sourceImage drawInRect:thumbnailRect];

	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if(newImage == nil) NSLog(@"could not scale image");


	return newImage ;
}

#pragma mark - Getting

+ (UIImage *)imageRetinaWithContentsOfFile:(NSString *)file
{
	UIImage *image = nil;

	if ([UIScreen instancesRespondToSelector:@selector(scale)] &&
		[[UIScreen mainScreen] scale] == 2.0)
	{
		NSString *path2x;
		NSString *newLastPathComponent;

		newLastPathComponent = [NSString stringWithFormat:@"%@@2x.%@", [[file lastPathComponent] stringByDeletingPathExtension], [file pathExtension]];
		path2x = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:newLastPathComponent];

		if ([[NSFileManager defaultManager] fileExistsAtPath:path2x])
		{
			image = [[UIImage alloc] initWithCGImage:[[UIImage imageWithData:[NSData dataWithContentsOfFile:path2x]] CGImage]
											   scale:2.0
										 orientation:UIImageOrientationUp];
		}
	}

	if (image == nil) {
		image =  [UIImage imageWithContentsOfFile:file];
	}

	return image;
}

- (UIImage *)colorizedImageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

	UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);

	[color set];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextClipToMask(context, rect, [self CGImage]);
	CGContextFillRect(context, rect);

	UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return colorizedImage;
}

- (UIImage *)grayscaleImage
{
	CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil,
												 self.size.width,
												 self.size.height,
												 8,
												 0,
												 colorSpace,
												 0);

	CGContextDrawImage(context, imageRect, [self CGImage]);

	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:imageRef];

	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	CFRelease(imageRef);

	return newImage;
}

+ (UIImage*)solidColorImageWithColor:(UIColor*)color
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(1.f, 1.f);

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, size.width, size.height);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, frame);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)imageWithFixedRotation
{
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        default:
            break;
    }

    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        default:
            break;
    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    CGImageRef cgImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImageRef];
    CGContextRelease(ctx);
    CGImageRelease(cgImageRef);

    return image;
}

#pragma mark -

+ (UIImage *)appIcon
{
    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSString *keyPath;
    CGFloat scale = [[UIScreen mainScreen] scale];

    if ([[UIDevice currentDevice] isiPad])
    {
        keyPath = @"CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles";
    }
    else
    {
        keyPath = @"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles";
    }

    NSString *baseName = [[infoPlist valueForKeyPath:keyPath] lastObject];

    UIImage *image = nil;

    while (scale > 0 && !image)
    {
        NSString *resolutionSuffix = [self _imageResolutionSuffixForScale:scale];
        NSString *iconName = [NSString stringWithFormat:@"%@%@",baseName, resolutionSuffix];
        image = [UIImage imageNamed:iconName];
        scale -= 1.f;
    }

    return image;
}

+ (NSString *)_imageResolutionSuffixForScale:(CGFloat)scale
{
    if (scale == 2.f) {
        return @"@2x";
    }
    else if (scale == 3.f) {
        return @"@3x";
    }

    return @"";
}

+ (UIImage *)iPhoneAppIcon;
{
	return [UIImage imageNamed:@"AppIcon60x60"];
}

+ (UIImage *)iPadAppIcon;
{
	return [UIImage imageNamed:@"AppIcon76x76"];
}

@end
