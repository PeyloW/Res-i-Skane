//
//  CWXMLTranslationPlist.m
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

#import "CWXMLTranslation.h"
#import "NSError+CWAdditions.h"

NSString * const CWXMLTranslationPlistErrorDomain = @"CWXMLTranslationPlistErrorDomain";
NSString * const CWXMLTranslationFileExtension = @"xmltranslation";

@interface NSCharacterSet (CWXMLTranslation)

+(NSCharacterSet*)validSymbolChararactersSet;
+(NSCharacterSet*)validXMLSymbolChararactersSet;

@end


@interface CWXMLTranslation ()

-(NSDictionary*)parseTranslationFromScanner:(NSScanner*)scanner error:(NSError**)error;
-(NSDictionary*)translationPropertyListNamed:(NSString*)name error:(NSError**)error;

@end


@implementation CWXMLTranslation

#pragma mark --- Object life cycle

-(id)init;
{
	self = [super init];
    if (self) {
    	_nameStack = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

-(void)dealloc;
{
	[_nameStack release];
    [super dealloc];
}

#pragma mark --- Private helpers

-(NSScanner*)scannerWithTranslationNamed:(NSString*)name error:(NSError**)error;
{
	NSString* type = [name pathExtension];
    if ([type length] == 0) {
    	type = CWXMLTranslationFileExtension;
    }
    name = [name stringByDeletingPathExtension];
	NSString* path = [[NSBundle mainBundle] pathForResource:name 
                                                     ofType:type];
    if (path == nil && error != nil) {
        *error = [NSError errorWithDomain:CWXMLTranslationPlistErrorDomain
                                     code:CWXMLTranslationPlistErrorMissingFile
                     localizedDescription:NSLocalizedStringFromTable(@"MissingTranslationFile", @"CWFoundationAdditions", nil)
                          localizedReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"MissingTranslationFileFormat", 
                                                                                                @"CWFoundationAdditions", 
                                                                                                nil), name]
              localizedRecoverySuggestion:NSLocalizedStringFromTable(@"ContactDeveloper", @"CWFoundationAdditions", nil) 
                        recoveryAttempter:nil 
                 localizedRecoveryOptions:nil];
    } else if (path) {
        NSString* string = [NSString stringWithContentsOfFile:path 
                                                     encoding:NSUTF8StringEncoding 
                                                        error:error];
        if (string) {
            NSScanner* scanner = [NSScanner scannerWithString:string];
            [scanner setCharactersToBeSkipped:nil];
            return scanner;
        }
    }
    return nil;
}

-(NSString*)stringWithLocationInScanner:(NSScanner*)scanner;
{
	NSString* string = [[scanner string] substringToIndex:[scanner scanLocation]];
    NSArray* temp = [string componentsSeparatedByString:@"\n"];
    int line = [temp count];
    int col = [[temp lastObject] length];
    NSLog(@"line %d character %d in %@", line, col, [_nameStack lastObject]);
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"LocationFormat", @"CWFoundationAdditions", nil), line, col, [_nameStack lastObject]];
}

-(void)skipShiteSpaceAndCommentsInScanner:(NSScanner*)scanner;
{
	[scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        intoString:NULL];
    while ([scanner scanString:@"#" intoString:NULL]) {
    	[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    }
}

-(BOOL)tryString:(NSString*)string fromScanner:(NSScanner*)scanner;
{
    [self skipShiteSpaceAndCommentsInScanner:scanner];
	return [scanner scanString:string intoString:NULL];
}

-(BOOL)takeString:(NSString*)string fromScanner:(NSScanner*)scanner error:(NSError**)error;
{
	BOOL result = [self tryString:string fromScanner:scanner];
    if (error && !result) {
        *error = [NSError errorWithDomain:CWXMLTranslationPlistErrorDomain
                                     code:CWXMLTranslationPlistErrorMissingRequiredToken
                     localizedDescription:NSLocalizedStringFromTable(@"MissingToken", @"CWFoundationAdditions", nil)
                          localizedReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"MissingTokenFormat", @"CWFoundationAdditions", nil), string, [self stringWithLocationInScanner:scanner]]
              localizedRecoverySuggestion:NSLocalizedStringFromTable(@"ContactDeveloper", @"CWFoundationAdditions", nil) 
                        recoveryAttempter:nil 
                 localizedRecoveryOptions:nil];
    }
    return result;
}

-(NSString*)takeSymbolFromScanner:(NSScanner*)scanner error:(NSError**)error;
{
	[self skipShiteSpaceAndCommentsInScanner:scanner];
    NSString* symbol = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet validSymbolChararactersSet] intoString:&symbol];
    if ([symbol length] == 0) {
        symbol = nil;
        if (error) {
            *error = [NSError errorWithDomain:CWXMLTranslationPlistErrorDomain
                                         code:CWXMLTranslationPlistErrorMissingRequiredSymbol
                         localizedDescription:NSLocalizedStringFromTable(@"MissingSymbol", @"CWFoundationAdditions", nil)
                              localizedReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"MissingSymbolFormat", @"CWFoundationAdditions", nil), [self stringWithLocationInScanner:scanner]]
                  localizedRecoverySuggestion:NSLocalizedStringFromTable(@"ContactDeveloper", @"CWFoundationAdditions", nil) 
                            recoveryAttempter:nil 
                     localizedRecoveryOptions:nil];
        }
    }
    return symbol;
}

-(NSString*)takeXMLSymbolFromScanner:(NSScanner*)scanner error:(NSError**)error;
{
	[self skipShiteSpaceAndCommentsInScanner:scanner];
    NSString* symbol = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet validXMLSymbolChararactersSet] intoString:&symbol];
    if ([symbol length] == 0) {
        symbol = nil;
        if (error) {
            *error = [NSError errorWithDomain:CWXMLTranslationPlistErrorDomain
                                         code:CWXMLTranslationPlistErrorMissingRequiredSymbol
                         localizedDescription:NSLocalizedStringFromTable(@"MissingSymbol", @"CWFoundationAdditions", nil)
                              localizedReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"MissingSymbolFormat", @"CWFoundationAdditions", nil), [self stringWithLocationInScanner:scanner]]
                  localizedRecoverySuggestion:NSLocalizedStringFromTable(@"ContactDeveloper", @"CWFoundationAdditions", nil) 
                            recoveryAttempter:nil 
                     localizedRecoveryOptions:nil];
        }
    }
    return symbol;
}

#pragma mark --- Parse methods

/*
 * type 	::= SYMBOL								# Type is a known Objective-C class (NSNumber, NSDate, NSURL)
 *				SYMBOL translation |				# Type is an Objective-C class with  inline translation definition
 *		 		"@" SYMBOL							# Type is an Objective-C class with translation defiition in external class
 */
-(id)parseTypedAssignActionFromScanner:(NSScanner*)scanner withTarget:(NSString*)target error:(NSError**)error;
{
    NSDictionary* translation = nil;
    NSString* type = nil;
	if ([self tryString:@"@" fromScanner:scanner]) {
		type = [self takeSymbolFromScanner:scanner error:error];
        if (type) {
            translation = [self translationPropertyListNamed:type error:error];
        }
    } else {
		type = [self takeSymbolFromScanner:scanner error:error];
        if ([self tryString:@"{" fromScanner:scanner]) {
            [scanner setScanLocation:[scanner scanLocation] - 1];
            translation = [self parseTranslationFromScanner:scanner error:error];
        } else {
        	return [NSArray arrayWithObjects:target, type, nil];
        }
    }
    if (translation) {
    	NSMutableDictionary* action = [NSMutableDictionary dictionaryWithDictionary:translation];
        [action setValue:type forKey:@"@class"];
        if (![target isEqualToString:@"@object"]) {
        	[action setValue:target forKey:@"@key"];
        }
        return [NSDictionary dictionaryWithDictionary:action];
    }
    return nil;
}

/*
 *	target 		::= "@root" |							# Target is the array of root objects to return.
 *					SYMBOL								# Target is a named property accessable using setValue:forKey:
 */
-(id)parseAssignActionFromScanner:(NSScanner*)scanner isAppend:(BOOL)isAppend error:(NSError**)error;
{
    NSString* target = [self tryString:@"@root" fromScanner:scanner] ? @"@object" : nil;
    if (target == nil) {
        target = [self takeSymbolFromScanner:scanner error:error];
        if (isAppend) {
        	target = [@"+" stringByAppendingString:target];
        }
    }
    if (target) {
        if ([self tryString:@":" fromScanner:scanner]) {
            return [self parseTypedAssignActionFromScanner:scanner withTarget:target error:error];
        } else {
            return target;
        }
    }
    return nil;
}

/*
 *	assignment 	::= ">>" |								# Assign to target using setValue:forKey:
 *					"+>"								# Append to target using addValue:forKey:
 */
-(BOOL)parseAssignmentFromScanner:(NSScanner*)scanner isAppend:(BOOL*)isAppend error:(NSError**)error;
{
    BOOL result = [self tryString:@"+>" fromScanner:scanner];
    if (!result) {
        if (![self takeString:@">>" fromScanner:scanner error:error]) {
            return NO;
        }
    }
    *isAppend = result;
    return YES;
}

/*
 *	action 		::= "->" translation |					# -> Is a required tag to descend into, but take no action on.
 *					assignment target { ":" type }		# All other actions are assignment to a target, with optional type (NSString is used for untyped actions)
 */
-(id)parseActionFromScanner:(NSScanner*)scanner error:(NSError**)error;
{
	if ([self tryString:@"->" fromScanner:scanner]) {
        NSDictionary* subTranslation = [self parseTranslationFromScanner:scanner error:error];
        if (subTranslation) {
			NSMutableDictionary* action = [NSMutableDictionary dictionaryWithDictionary:subTranslation];
            [action setObject:[NSNumber numberWithBool:YES] forKey:@"@dummy"];
            return [NSDictionary dictionaryWithDictionary:action];
        }
    } else {
		BOOL isAppend = NO;
        if ([self parseAssignmentFromScanner:scanner isAppend:&isAppend error:error]) {
	        return [self parseAssignActionFromScanner:scanner isAppend:isAppend error:error];
        }
    }
    return nil;
}

/*
 *	statement 	::= { "." } SYMBOL action { ";" }		# A statement is an XML symbol with an action (prefix . is attributes).
 */
 -(BOOL)parseStatementFromScanner:(NSScanner*)scanner intoTranslation:(NSMutableDictionary*)translation error:(NSError**)error;
{
	BOOL sourceIsAttribute = [self tryString:@"." fromScanner:scanner];
    NSString* symbol = [self takeXMLSymbolFromScanner:scanner error:error];
    if (symbol) {
        id action = [self parseActionFromScanner:scanner error:error];
		if (action) {
        	[self tryString:@";" fromScanner:scanner];
            if (sourceIsAttribute) {
            	symbol = [@"." stringByAppendingString:symbol];
            }
            [translation setValue:action forKey:symbol];
            return YES;
        }
    }
    return NO;
}

/*
 *	translation ::= statement |							# A translation is one or more statement
 *					"{" statement* "}"
 */
-(NSDictionary*)parseTranslationFromScanner:(NSScanner*)scanner error:(NSError**)error;
{
    NSMutableDictionary* translation = [NSMutableDictionary dictionaryWithCapacity:8];
    if ([self tryString:@"{" fromScanner:scanner]) {
		while (![self tryString:@"}" fromScanner:scanner]) {
            if (![self parseStatementFromScanner:scanner intoTranslation:translation error:error]) {
            	translation = nil;
                break;
            }
    	}
    } else {
    	if (![self parseStatementFromScanner:scanner intoTranslation:translation error:error]) {
            translation = nil;
 	   	}
    }
	if (translation) {
    	return [NSDictionary dictionaryWithDictionary:translation];
    }
    return nil;
}

#pragma mark --- Top level type entry point.

-(NSDictionary*)translationPropertyListNamed:(NSString*)name error:(NSError**)error;
{
    static NSMutableDictionary* translationCache = nil;
    NSDictionary* result = [translationCache objectForKey:name];
    if (result == nil) {
        NSString* pathExtension = [name pathExtension];
        if ([pathExtension length] == 0 || [pathExtension isEqualToString:CWXMLTranslationFileExtension]) {
            NSScanner* scanner = [self scannerWithTranslationNamed:name error:error];
            [_nameStack addObject:name];
            if (scanner) {
                result = [self parseTranslationFromScanner:scanner error:error];
            }
            [_nameStack removeLastObject];
        } else {
            NSString* path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension]
                                                             ofType:[name pathExtension]];
            result = [NSDictionary dictionaryWithContentsOfFile:path];
        }
        if (result) {
        	if (translationCache == nil) {
            	translationCache = [[NSMutableDictionary alloc] initWithCapacity:8];
            }
            [translationCache setObject:result forKey:name];
        }
    }
    return result;
}

#pragma mark --- Public API

+(NSDictionary*)translationPropertyListNamed:(NSString*)name error:(NSError**)error;
{
    CWXMLTranslation* temp = [[[self alloc] init] autorelease];
    return [temp translationPropertyListNamed:name error:error];
}

+(NSDictionary*)translationPropertyListWithDSLInString:(NSString*)dslString error:(NSError**)error;
{
    CWXMLTranslation* temp = [[[self alloc] init] autorelease];
	NSScanner* scanner = [NSScanner scannerWithString:dslString];
    [scanner setCharactersToBeSkipped:nil];
    return [temp parseTranslationFromScanner:scanner error:error];
}

@end


@implementation NSCharacterSet (CWXMLTranslation)

+(NSCharacterSet*)validSymbolChararactersSet;
{
	static NSCharacterSet* characterSet = nil;
    if (characterSet == nil) {
    	NSMutableCharacterSet* cs = [NSMutableCharacterSet alphanumericCharacterSet];
        [cs addCharactersInString:@"-_"];
        characterSet = [cs copy];
    }
    return characterSet;
}

+(NSCharacterSet*)validXMLSymbolChararactersSet;
{
	static NSCharacterSet* characterSet = nil;
    if (characterSet == nil) {
    	NSMutableCharacterSet* cs = [NSMutableCharacterSet alphanumericCharacterSet];
        [cs addCharactersInString:@"-_:"];
        characterSet = [cs copy];
    }
    return characterSet;
}


@end
