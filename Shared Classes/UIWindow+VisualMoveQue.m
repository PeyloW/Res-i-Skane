//
//  UIWindow+VisualMoveQue.m
//  SC68 Player
//
//  Created by Fredrik Olsson on 2008-11-10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UIWindow+VisualMoveQue.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION (.5f)
#define ANIMATION_MOVE_ID @"CWVisualMoveQue"
#define ANIMATION_FLASH_ID @"CWVisualFlashQue"

static BOOL CWRectFitsRect(CGRect rect1, CGRect rect2) {
	return (rect1.size.width <= rect2.size.width && rect1.size.height <= rect2.size.height);
}

static CGRect CWRectScaleToFillRect(CGRect rect1, CGRect rect2) {
	CGFloat ratio = rect1.size.height / rect1.size.width;
  CGRect rect = CGRectMake(rect1.origin.x, rect1.origin.y, rect2.size.width, rect2.size.width * ratio);
  if (!CWRectFitsRect(rect, rect2)) {
  	rect = CGRectMake(rect1.origin.x, rect1.origin.y, rect2.size.height / ratio, rect2.size.height);
	}
  return rect;
}

static CGRect CWRectCenterInRect(CGRect rect1, CGRect rect2) {
	CGFloat x = rect2.origin.x + (rect2.size.width - rect1.size.width) / 2;
	CGFloat y = rect2.origin.y + (rect2.size.height - rect1.size.height) / 2;
	return CGRectMake(x, y, rect1.size.width, rect1.size.height);
}

static CGRect CWRectFitAndCenterInRect(CGRect rect1, CGRect rect2) {
	if (!CWRectFitsRect(rect1, rect2)) {
		rect1 = CWRectScaleToFillRect(rect1, rect2);
  }
  return CWRectCenterInRect(rect1, rect2);
}

static CGRect gToRect;

@implementation UIWindow (VisualMoveQue)

-(void)displayVisualQueForMovingImage:(UIImage*)image fromRect:(CGRect)fromRect toRect:(CGRect)toRect;
{
	gToRect = toRect;
  UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = fromRect;
  [self addSubview:imageView];
  toRect = CWRectFitAndCenterInRect(fromRect, toRect);

  // Create a ballistic path to that destination.
  CGMutablePathRef ballisticPath = CGPathCreateMutable();
  CGPoint toCenter = toRect.origin;
  toCenter.x += roundf(toRect.size.width / 2.0f);
  toCenter.y += roundf(toRect.size.height / 2.0f);
  CGPoint fromCenter = fromRect.origin;
  fromCenter.x += roundf(fromRect.size.width / 2.0f);
  fromCenter.y += roundf(fromRect.size.height / 2.0f);
  CGPathMoveToPoint(ballisticPath, NULL, fromCenter.x, fromCenter.y);
  CGPathAddQuadCurveToPoint(ballisticPath, NULL, toCenter.x, 0.0f, toCenter.x, toCenter.y);

  // Create a keyframe animation.
  CAKeyframeAnimation* keyFrame = [CAKeyframeAnimation animation];
  [keyFrame setKeyPath:@"position"];
  [keyFrame setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil]];
  [keyFrame setPath:ballisticPath];
  [keyFrame setDuration:ANIMATION_DURATION];
  [keyFrame setCalculationMode:kCAAnimationLinear];
  [keyFrame setDelegate:self];
  [keyFrame setFillMode:@"frozen"];
  [keyFrame setRemovedOnCompletion:NO];
  [[imageView layer] addAnimation:keyFrame forKey:@"position"];
  CGPathRelease(ballisticPath);

  // Now we need to rotate the image view and fade out.
  [UIView beginAnimations:ANIMATION_MOVE_ID context:(void*)imageView];
  [UIView setAnimationDuration:ANIMATION_DURATION];
  [UIView setAnimationDelegate:self];
  CGAffineTransform transform;
  transform = [imageView transform];
	transform = CGAffineTransformRotate(transform, -0.167f * M_PI);
  transform = CGAffineTransformScale(transform, toRect.size.width / fromRect.size.width, toRect.size.height / fromRect.size.height);
  [imageView setTransform:transform];
	//[imageView setAlpha:0.0];

  [UIView commitAnimations];
}

-(void)displayVisualQueForMovingView:(UIView*)fromView fromRect:(CGRect)fromRect toRect:(CGRect)toRect;
{
  fromRect = CGRectInset(fromRect, -16, -16);
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	UIGraphicsBeginImageContext(fromView.bounds.size);
  [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

	UIGraphicsBeginImageContext(fromRect.size);
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
  CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, -2), 12, [UIColor blackColor].CGColor);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(16, -16, image.size.width, -image.size.height), image.CGImage);
  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
	[self displayVisualQueForMovingImage:image fromRect:fromRect toRect:toRect];
}

-(void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;
{
	if ([animationID isEqualToString:ANIMATION_MOVE_ID]) {
  	UIImageView* imageView = (UIImageView*)context;
    [imageView removeFromSuperview];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    UIImage* flashImage = [UIImage imageNamed:@"flash.png"];
		UIImageView* flashView = [[UIImageView alloc] initWithImage:flashImage];
    flashView.frame = gToRect;
    [self addSubview:flashView];
    [UIView beginAnimations:ANIMATION_FLASH_ID context:(void*)flashView];
    [flashView setAlpha:0.0];
    [UIView commitAnimations];
  } else if ([animationID isEqualToString:ANIMATION_FLASH_ID]) {
  	UIImageView* imageView = (UIImageView*)context;
    [imageView removeFromSuperview];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
  } else {
  	[(id)super animationDidStop:animationID finished:finished context:context];
  }
}

@end
