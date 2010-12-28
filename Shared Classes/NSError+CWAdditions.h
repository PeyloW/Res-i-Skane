//
//  NSError+CWAdditions.h
//  CWFoundationAdditions
//
//  Copyright 2010 Jayway. All rights reserved.
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

/*!
 * @abstract A generic application error.
 */
extern NSString* const CWFoundationAdditionsErrorDomain;

/*!
 * @abstract A generic application error.
 */
extern NSString* const CWApplicationErrorDomain;

@protocol CWErrorRecoveryAttempting;


/*!
 * @abstract Category on NSError adding convinience methods for creating and copying errors.
 */
@interface NSError (CWErrorAdditions) <NSMutableCopying>

/*!
 * @abstract Initialize a copy of the error.
 */
-(id)initWithError:(NSError*)error;

/*!
 * @abstract Create a copy of the error.
 */
+(id)errorWithError:(NSError*)error;

/*!
 * @abstract Return an NSError with localized description and reason.
 */
+(id)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason;

/*!
 * @abstract Return an NSError with localized description, reason and recovery options.
 *
 * @discussion The order of the recovery options are consistent with how AppKit expects
 *			   them for correct display in a NSAlert.
 *			   Index 0 - Default button, eg "Save".
 *			   Index 1 - Alternate button, eg. "Don't Save".
 *			   Index 2 - Other button, eg. "Cancel"
 *			   If only two options are available then the index 1 is treated as index 2.
 */
+(id)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason
localizedRecoverySuggestion:(NSString*)suggestionOrNil
         recoveryAttempter:(id<CWErrorRecoveryAttempting>)recoveryAttempterOrNil
  localizedRecoveryOptions:(NSArray*)recoveryOptionsOrNil;

/*!
 * @abstract Get the underlying error that caused this error.
 */
-(NSError*)underlyingError;

@end

/*!
 * @abstract A mutable subclass of NSError.
 */
@interface NSMutableError : NSError {
@private
    NSMutableDictionary* _mutableUserInfo;
}

- (NSMutableDictionary*)mutableUserInfo;

- (void)setDomain:(NSString *)domain;
- (void)setCode:(NSInteger)code;

- (void)setLocalizedDescription:(NSString*)description;
- (void)setLocalizedFailureReason:(NSString*)reason;
- (void)setLocalizedRecoverySuggestion:(NSString*)recoverySuggestion;
- (void)setLocalizedRecoveryOptions:(NSArray*)recoveryOptions;
- (void)setRecoveryAttempter:(id)recoveryAttempter;

- (void)setUnderlyingError:(NSError*)error;

@end


/*!
 * @abstract A concrete protocol mimicng the informal protocol NSErrorRecoveryAttempting.
 */
@protocol CWErrorRecoveryAttempting <NSObject>

@required
/*!
 * @abstract Implement to attempt a recovery from an error noted in an application-modal dialog.
 *
 * @discussion recoveryOptionIndex can be NSNotFound on iOS where system can cancel alerts.
 */
-(BOOL)attemptRecoveryFromError:(NSError*)error optionIndex:(NSUInteger)recoveryOptionIndex;

@end
