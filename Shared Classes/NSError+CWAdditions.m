//
//  NSError+CWAdditions.m
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

#import "NSError+CWAdditions.h"

NSString* const CWFoundationAdditionsErrorDomain = @"CWFoundationAdditionsErrorDomain";
NSString* const CWApplicationErrorDomain = @"CWApplicationErrorDomain";

@implementation NSError (CWErrorAdditions)

-(id)init;
{
	return [self initWithDomain:CWFoundationAdditionsErrorDomain code:0 userInfo:nil];
}

-(id)initWithError:(NSError*)error;
{
    return [self initWithDomain:[error domain] code:[error code] userInfo:[error userInfo]];
}

+(id)errorWithError:(NSError*)error;
{
	return [[[self alloc] initWithError:error] autorelease];
}

+(id)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason;
{
	return [self errorWithDomain:domainOrNil
                            code:code
            localizedDescription:description
                 localizedReason:reason
     localizedRecoverySuggestion:nil
               recoveryAttempter:nil
        localizedRecoveryOptions:nil];    
}

+(id)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason
localizedRecoverySuggestion:(NSString*)suggestionOrNil
         recoveryAttempter:(id<CWErrorRecoveryAttempting>)recoveryAttempterOrNil
  localizedRecoveryOptions:(NSArray*)recoveryOptionsOrNil;
{
    if (domainOrNil == nil) {
    	domainOrNil = CWApplicationErrorDomain;
    }
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    if (suggestionOrNil) {
    	[userInfo setObject:suggestionOrNil forKey:NSLocalizedRecoverySuggestionErrorKey];
    }
    if (recoveryAttempterOrNil && [recoveryOptionsOrNil count] > 0) {
    	[userInfo setObject:recoveryAttempterOrNil forKey:NSRecoveryAttempterErrorKey];
        [userInfo setObject:recoveryOptionsOrNil forKey:NSLocalizedRecoveryOptionsErrorKey];
    }
    return [self errorWithDomain:domainOrNil code:code userInfo:userInfo];
}

-(NSError*)underlyingError;
{
	return [[self userInfo] objectForKey:NSUnderlyingErrorKey];    
}

-(id)copyWithZone:(NSZone *)zone;
{
    if ([self isKindOfClass:[NSMutableError class]]) {
		return [[NSError allocWithZone:zone] initWithError:self];
    } else {
    	return [self retain];
    }
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
	return [[NSMutableError allocWithZone:zone] initWithError:self];
}

@end

@implementation NSMutableError

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
{
	self = [super initWithDomain:domain code:code userInfo:dict];
    if (self) {
    	_mutableUserInfo = [[NSMutableDictionary alloc] initWithCapacity:[dict count] + 4];
        if (dict) {
        	[_mutableUserInfo addEntriesFromDictionary:dict];
        }
    }
    return self;
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
{
	return [[[self alloc] initWithDomain:domain code:code userInfo:dict] autorelease];
}

-(void)dealloc;
{
	[_mutableUserInfo release];
    [super dealloc];
}

-(NSDictionary*)userInfo;
{
	if ([_mutableUserInfo count] > 0) {
    	return [NSDictionary dictionaryWithDictionary:_mutableUserInfo];
    }
    return nil;
}

-(NSMutableDictionary*)mutableUserInfo;
{
	return _mutableUserInfo;
}

- (void)setDomain:(NSString *)domain;
{
	[self setValue:[NSString stringWithString:domain]
            forKey:@"_domain"];    
}

- (void)setCode:(NSInteger)code;
{
	[self setValue:[NSNumber numberWithInteger:code] 
            forKey:@"_code"];
}

- (void)setLocalizedDescription:(NSString*)description;
{
    if (description) {
		[_mutableUserInfo setObject:[NSString stringWithString:description]
                             forKey:NSLocalizedDescriptionKey];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    }
}

- (void)setLocalizedFailureReason:(NSString*)reason;
{
    if (reason) {
		[_mutableUserInfo setObject:[NSString stringWithString:reason]
                             forKey:NSLocalizedFailureReasonErrorKey];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedFailureReasonErrorKey];
    }
}

- (void)setLocalizedRecoverySuggestion:(NSString*)recoverySuggestion;
{
    if (recoverySuggestion) {
		[_mutableUserInfo setObject:[NSString stringWithString:recoverySuggestion]
                             forKey:NSLocalizedRecoverySuggestionErrorKey];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    }
}

- (void)setLocalizedRecoveryOptions:(NSArray*)recoveryOptions;
{
    if (recoveryOptions) {
		[_mutableUserInfo setObject:[NSArray arrayWithArray:recoveryOptions]
                             forKey:NSLocalizedRecoveryOptionsErrorKey];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedRecoveryOptionsErrorKey];
    }
}

- (void)setRecoveryAttempter:(id)recoveryAttempter;
{
    if (recoveryAttempter) {
		[_mutableUserInfo setObject:recoveryAttempter forKey:NSRecoveryAttempterErrorKey];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
    }
}

- (void)setUnderlyingError:(NSError*)error;
{
	if (error) {
    	[_mutableUserInfo setObject:error forKey:NSUnderlyingErrorKey];
    } else {
        [_mutableUserInfo removeObjectForKey:NSUnderlyingErrorKey];
    }
}

@end

