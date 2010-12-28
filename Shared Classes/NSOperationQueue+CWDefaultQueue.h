//
//  NSOperationQueue+CWDefaultQueue.h
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

#import <Foundation/Foundation.h>

#ifndef CW_DEFAULT_OPERATION_COUNT
	#define CW_DEFAULT_OPERATION_COUNT 3
#endif


/*!
 * @abstract Category on NSOperationQueue to add support for a default queue.
 */
@interface NSOperationQueue (CWDefaultQueue)

/*!
 * Returns the shared NSOperationQueue instance. A shared instance with max
 * concurent operations set to CW_DEFAULT_OPERATION_COUNT will be created if no
 * shared instance has previously been set, or created.
 *
 * @result a shared NSOperationQueue instance.
 */
+(NSOperationQueue*)defaultQueue;

/*!
 * Set the shared NSOperationQueue instance.
 * 
 * @param operationQueue the new shared NSOperationQueue instance.
 */
+(void)setDefaultQueue:(NSOperationQueue*)operationQueue;


/**
 * Cancel all queued and executing operations of a class.
 *
 * @param aClass the operation subclass to cancel.
 */
-(void)cancelOperationsOfClass:(Class)aClass;

@end

/*!
 * @abstract Category on NSObject to add support for the default NSoperationQueue
 */
@interface NSObject (CWDefaultQueue)

/*!
 * Invokes a method of the receiver on a new background queue.
 *
 * @param aSelector A selector that identifies the method to invoke. 
 *									The method should not have a significant return value and 
 *									should take a single argument of type id, or no arguments.
 * @param arg The argument to pass to the method when it is invoked. 
 *            Pass nil if the method does not take an argument.
 * @result an autoreleased NSInvocationOperation instance.
 *			   Can be used to setup dependencies.
 */
-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg;

/*!
 * Invokes a method of the receiver on a new background queue.
 *
 * @param aSelector A selector that identifies the method to invoke. 
 *									The method should not have a significant return value and 
 *									should take a single argument of type id, or no arguments.
 * @param arg The argument to pass to the method when it is invoked. 
 *            Pass nil if the method does not take an argument.
 * @param dependencies an array of operations that must complete before
 *                     this operation can execute.
 * @param priority Sets the priority of the operation.
 * @result an autoreleased NSInvocationOperation instance.
 *			   Can be used to setup dependencies.
 */
-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg dependencies:(NSArray*)dependencies priority:(NSOperationQueuePriority)priority;

@end
