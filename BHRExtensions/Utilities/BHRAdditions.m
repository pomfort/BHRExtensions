//
//  LGAdditions.m
//  LGGradingMobile
//
//  Created by Benedikt Hirmer on 1/10/14.
//  Copyright (c) 2014 HIRMER.me. All rights reserved.
//

#import "BHRAdditions.h"

@implementation BHRAdditions

@end

CGFloat clampf(CGFloat x, CGFloat low, CGFloat high)
{
	if (x > high) {
		return high;
	}
	if (x < low) {
		return low;
	}
	
	return x;
}

CGMutablePathRef CGPathCreatePathRotatedAroundBoundingBoxCenter(CGPathRef path, CGFloat radians)
{
    CGRect bounds = CGPathGetBoundingBox(path); // might want to use CGPathGetPathBoundingBox
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    return CGPathCreateMutableCopyByTransformingPath(path, &transform);
}

CGRect CGRectWithScale(CGRect rect, CGFloat scale)
{
	return CGRectMake(scale * rect.origin.x,
					  scale * rect.origin.y,
					  scale * rect.size.width,
					  scale * rect.size.height);
}

CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets)
{
    return CGRectMake(rect.origin.x += insets.left,
                      rect.origin.y += insets.top,
                      rect.size.width -= (insets.left + insets.right),
                      rect.size.height -= (insets.top + insets.bottom));
}

CGRect CGRectSquareInRect(CGRect rect)
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat aspect = width / height;

    //rect wider than heigh
    if (aspect >= 1.0f)
    {
        CGFloat offsetX = 0.5f * (width - height);
        return CGRectMake(CGRectGetMinX(rect) + offsetX,
                          CGRectGetMinY(rect),
                          height,
                          height);
    }
    else
    {
        CGFloat offsetY = 0.5f * (height - width);
        return CGRectMake(CGRectGetMinX(rect),
                          CGRectGetMinY(rect) + offsetY,
                          width,
                          width);
    }
}

CGSize CGSizeScaledProportionallyToSize(CGSize originalSize, CGSize targetSize)
{
	CGFloat width = originalSize.width;
	CGFloat height = originalSize.height;

	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;

	CGFloat scaleFactor = 0.0f;

	CGFloat widthFactor = targetWidth / width;
	CGFloat heightFactor = targetHeight / height;

	if (widthFactor < heightFactor) {
		scaleFactor = widthFactor;
	}
	else {
		scaleFactor = heightFactor;
	}

	return CGSizeMake(width * scaleFactor,
					  height * scaleFactor);
}

NSString *NSStringFromBOOL(BOOL boolean)
{
	if (boolean) {
		return @"YES";
	}
	return @"NO";
}

NSString *NSStringEmptyIfNil(id object)
{
	if (object == nil) {
		return @"";
	}
	return object;
}

CGFloat DegreeToRadians(CGFloat degreeValue)
{
	return (M_PI / 180) * degreeValue;
}

CGFloat RadiansToDegrees(CGFloat radiansValue)
{
	return radiansValue * (180 / M_PI);
}

CGFloat HorizontalDistanceFromRectToPoint(CGRect rect, CGPoint point)
{
	CGFloat closest = 0.f;

	if (point.x <= CGRectGetMinX(rect))
	{
		closest = CGRectGetMinX(rect);
	}
	else if (point.x >= CGRectGetMaxX(rect))
	{
		closest = CGRectGetMaxX(rect);
	}
	else
	{
		return 0.0f;
	}

	return closest - point.x;
}



NSString *EmptyStringIfNil(id object)
{
    if (!object) {
        return @"";
    }
    return object;
}

NSString *NilIfEmptyString(NSString *string)
{
    if ([string length] == 0) {
        return nil;
    }
    return string;
}

id NSNullIfNil(id object)
{
	if (object == nil)
	{
		return [NSNull null];
	}

	return object;
}

CGFloat Square(CGFloat value)
{
	return value * value;
}

CGFloat RotateValueAtPositionWithMax(CGFloat value, CGFloat flipPosition, CGFloat max)
{
	CGFloat flippedValue = value + flipPosition;

	if (flippedValue < 0.0f)
	{
		flippedValue += max;
	}

	if (flippedValue > max)
	{
		flippedValue -= max;
	}

	return flippedValue;
}
