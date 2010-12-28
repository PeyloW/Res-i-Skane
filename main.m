//
//  main.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2009-12-07.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define EXTENDED_DEBUG_SUPPORTED
#else
#undef EXTENDED_DEBUG_SUPPORTED
#endif

#ifdef EXTENDED_DEBUG_SUPPORTED
#import "GTMStackTrace.h"

void exceptionHandler(NSException *exception) {
	NSLog(@"%@", GTMStackTraceFromException(exception));
}
#endif


int main(int argc, char *argv[]) {

#ifdef EXTENDED_DEBUG_SUPPORTED
	NSLog(@"Debug enabled");
  NSSetUncaughtExceptionHandler(&exceptionHandler);
#endif

  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  int retVal = UIApplicationMain(argc, argv, nil, nil);
  [pool release];
  return retVal;
}
