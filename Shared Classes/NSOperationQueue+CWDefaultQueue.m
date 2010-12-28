//
//  NSOperationQueue+CWDefaultQueue.m
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

#import "NSOperationQueue+CWDefaultQueue.h"


@implementation NSOperationQueue (CWDefaultQueue)

static NSOperationQueue* cw_defaultQueue = nil;

+(NSOperationQueue*)defaultQueue;
{
	if (cw_defaultQueue == nil) {
        cw_defaultQueue = [[NSOperationQueue alloc] init];
        [cw_defaultQueue setMaxConcurrentOperationCount:CW_DEFAULT_OPERATION_COUNT];
    }
    return cw_defaultQueue;
}

+(void)setDefaultQueue:(NSOperationQueue*)operationQueue;
{
	if (operationQueue != cw_defaultQueue) {
        [cw_defaultQueue release];
        cw_defaultQueue = [operationQueue retain];
    }
}

-(void)cancelOperationsOfClass:(Class)aClass;
{
	for (NSOperation* operation in [self operations]) {
    	if ([operation isKindOfClass:aClass]) {
        	[operation cancel];
        }
    }
}

@end


@implementation NSObject (CWDefaultQueue)

-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg;
{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:aSelector object:arg];
    [[NSOperationQueue defaultQueue] addOperation:operation];
	return [operation autorelease];  
}

-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg dependencies:(NSArray*)dependencies priority:(NSOperationQueuePriority)priority;
{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:aSelector object:arg];
    [operation setQueuePriority:priority];
    for (NSOperation* dependency in dependencies) {
        [operation addDependency:dependency]; 
    }
    [[NSOperationQueue defaultQueue] addOperation:operation];
	return [operation autorelease];  
}

@end
