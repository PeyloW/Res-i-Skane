//
//  NSInvocation+CWVariableArguments.m
//  CWFoundationAdditions
//
//  Copyright 2009 Jayway. All rights reserved.
//  Created by Fredrik Olsson.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSInvocation+CWVariableArguments.h"
#import "NSOperationQueue+CWDefaultQueue.h"
#include <stdarg.h>

@implementation NSInvocation (CWVariableArguments)

+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments, ...;
{
	va_list arguments;
    va_start(arguments, retainArguments);
    NSInvocation* invocation = [self invocationForInstancesOfClass:aClass
                                                      withSelector:selector
                                                   retainArguments:retainArguments
                                                         arguments:arguments];
    va_end(arguments);
	return invocation;
}

+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments
                                    arguments:(va_list)arguments;
{
    NSMethodSignature* signature = [aClass instanceMethodSignatureForSelector:selector];
    if (aClass == Nil || selector == NULL || signature == nil) {
    	return nil;
    }
    char* args = (char*)arguments;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (retainArguments) {
        [invocation retainArguments];
    }
    [invocation setSelector:selector];
    for (int index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        NSUInteger size, align;
        NSGetSizeAndAlignment(type, &size, &align);
        NSUInteger mod = (NSUInteger)args % align;
        if (mod != 0) {
            args += (align - mod);
        }
        [invocation setArgument:args atIndex:index];
        args += size;
    }
    return invocation;
}

+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments, ...;
{
	va_list arguments;
    va_start(arguments, retainArguments);
    NSInvocation* invocation = [self invocationWithTarget:target 
                                                 selector:aSelector 
                                          retainArguments:retainArguments 
                                                arguments:arguments];
    va_end(arguments);
	return invocation;
}

+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments
                           arguments:(va_list)arguments;
{
    NSInvocation* invocation = [self invocationForInstancesOfClass:[target class]
                                                      withSelector:aSelector
                                                   retainArguments:retainArguments
                                                         arguments:arguments];
    [invocation setTarget:target];
    return invocation;
}

-(void)invokeInBackground;
{
	[self performSelectorInBackground:@selector(invoke) withObject:nil];
}

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;
{
	[self invokeOnThread:[NSThread mainThread] waitUntilDone:wait];
}

-(void)invokeOnThread:(NSThread*)thread waitUntilDone:(BOOL)wait;
{
    if ([[NSThread currentThread] isEqual:thread]) {
    	[self invoke];
    } else {
    	[self performSelector:@selector(invoke) 
                     onThread:thread
                   withObject:nil
                waitUntilDone:wait];
    }
}

-(void)invokeOnDefaultQueueWaitUntilDone:(BOOL)wait;
{
	[self invokeOnOperationQueue:[NSOperationQueue defaultQueue] waitUntilDone:wait];
}

-(void)invokeOnOperationQueue:(NSOperationQueue*)queue waitUntilDone:(BOOL)wait;
{
	NSOperation* operation = [[NSInvocationOperation alloc] initWithInvocation:self];
    [queue addOperation:operation];
    if (wait) {
        if ([operation respondsToSelector:@selector(waitUntilFinished)]) {
		    [operation performSelector:@selector(waitUntilFinished)];
        } else {
			while ([[queue operations] containsObject:operation]) {
            	[[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes
                                         beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
            }
        }
    }
    [operation release];
}

-(void)invokeAfterDelay:(NSTimeInterval)delay;
{
	[self performSelector:@selector(invoke) 
               withObject:nil 
               afterDelay:delay];
}

-(void)invokeWithAllTargets:(NSArray*)targets;
{
	for (id target in targets) {
    	[self invokeWithTarget:target];
    }
}

@end

