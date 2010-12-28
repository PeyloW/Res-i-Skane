//
//  CWXMLParser.m
//  XmlTranslator
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

#import "CWXMLTranslator.h"
#import "CWLog.h"
#import "NSInvocation+CWVariableArguments.h"

@interface CWXMLTranslatorState : NSObject
{
@public
	NSDictionary* translationPlist;
    id currentObject;
    NSString* elementName;
    int nestingCount;
}

-(id)initWithObject:(id)object;

@end

@implementation CWXMLTranslatorState

-(id)initWithObject:(id)object;
{
    self = [super init];
    if (self) {
        elementName = @"";
		currentObject = [object retain];
    }
    return self;
}

-(void)dealloc;
{
	[currentObject release];
    [super dealloc];
}

@end


@implementation CWXMLTranslator

@synthesize delegate = _delegate;


-(void)setDelegate:(id<CWXMLTranslatorDelegate>)delegate;
{
	if (_delegate != delegate) {
    	_delegate = delegate;
        _delegateFlags.shouldTranslateObjectOfClass = [delegate respondsToSelector:@selector(xmlTranslator:shouldTranslateObjectOfClass:forKey:)];
    	_delegateFlags.objectInstanceOfClass = [delegate respondsToSelector:@selector(xmlTranslator:objectInstanceOfClass:forKey:)];
    	_delegateFlags.didTranslateObject = [delegate respondsToSelector:@selector(xmlTranslator:didTranslateObject:forKey:)];
        _delegateFlags.shouldTranslatePrimitiveObjectOfClass = [delegate respondsToSelector:@selector(xmlTranslator:shouldTranslatePrimitiveObjectOfClass:withString:forKey:)];
    	_delegateFlags.primitiveObjectInstanceOfClass = [delegate respondsToSelector:@selector(xmlTranslator:primitiveObjectInstanceOfClass:withString:forKey:)];
    	_delegateFlags.shouldSetValue = [delegate respondsToSelector:@selector(xmlTranslator:shouldAddValue:forKey:onObject:)];
    	_delegateFlags.shouldAddValue = [delegate respondsToSelector:@selector(xmlTranslator:shouldAddValue:forKey:onObject:)];
    }
}

-(id)initWithTranslationPropertyList:(NSDictionary*)translation delegate:(id<CWXMLTranslatorDelegate>)delegate;
{
	self = [self init];
    if (self) {
        translationPlist = [translation copy];
        self.delegate = delegate;
    }
    return self;
}

-(void)dealloc;
{
	[translationPlist release];
	[stateStack release];
    [currentText release];
    [super dealloc];
}


-(NSArray*)translateContentsOfData:(NSData*)data error:(NSError**)error;
{
    BOOL result = NO;
    didAbort = NO;
    rootObjects = [NSMutableArray array];
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    if (xmlParser) {
        [xmlParser setDelegate:(id)self];
        CWXMLTranslatorState* state = [[CWXMLTranslatorState alloc] init];
        state->translationPlist = translationPlist;
        stateStack = [[NSMutableArray alloc] initWithObjects:state, nil];
        [state release];
        result = [xmlParser parse];
        if (!result) {
            if (didAbort) {
                result = YES;
            } else {
                *error = [xmlParser parserError];          
            }
        }
        [stateStack release];
        stateStack = nil;
        [xmlParser release];
        xmlParser = nil;
    }
    if (result == NO) {
        CWLogError(@"Unparsable data: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        rootObjects = nil;
    }
	return [[rootObjects copy] autorelease];
    
}

-(NSArray*)translateContentsOfURL:(NSURL*)url error:(NSError**)error;
{
    NSError* tmpError = nil;
    if (error == NULL) {
        error = &tmpError;
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:error];
    if (data != nil) {
        return [self translateContentsOfData:data error:error];
    }
    return nil;
}

-(id)currentObject;
{
	CWXMLTranslatorState* state = [stateStack lastObject];
	return state->currentObject;
}

-(void)replaceCurrentObjectWithObject:(id)object;
{
	CWXMLTranslatorState* state = [stateStack lastObject];
	[state->currentObject autorelease];
    state->currentObject= [object retain];
}

-(void)abortTranslation;
{
    didAbort = YES;
    [xmlParser abortParsing];
}

-(BOOL)shouldTranslatePrimitiveObjectOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
{
    BOOL result = YES;
	if (_delegateFlags.shouldTranslatePrimitiveObjectOfClass) {
    	result = [_delegate xmlTranslator:self shouldTranslatePrimitiveObjectOfClass:aClass withString:aString forKey:key]; 
    }
    if (!result) {
    	CWLogInfo(@"Skipping primitive object of class %@ for '%@'",
                   NSStringFromClass(aClass), key);
    }
    return result;
}

-(NSDateFormatter*)dateFormatter;
{
	static NSDateFormatter* formatter = nil;
    if (formatter == nil) {
    	formatter = [[NSDateFormatter alloc] init];
        [formatter setLenient:YES];
    }
    return formatter;
}

-(id)primitiveObjectInstanceOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
{
    id result = nil;
    if ([self shouldTranslatePrimitiveObjectOfClass:aClass withString:aString forKey:key]) {
        if (_delegateFlags.primitiveObjectInstanceOfClass) {
            result = [_delegate xmlTranslator:self primitiveObjectInstanceOfClass:aClass withString:aString forKey:key];
        }
        if (result == nil) {
            if (aClass == [NSString class]) {
                return aString;
            } else if (aClass == [NSNumber class]) {
                result = [NSDecimalNumber decimalNumberWithString:aString];
            } else if (aClass == [NSDate class]) {
                result = [[self dateFormatter] dateFromString:aString];
            } else {
                result = [[[aClass alloc] initWithString:aString] autorelease];
            }
        }
    }
    CWLogInfo(@"Did instantiate primitive object of class %@ for '%@' (expected %@)", 
               NSStringFromClass([result class]), key, NSStringFromClass(aClass));
	return result;
}

-(BOOL)shouldSetValue:(id)value forKey:(NSString*)key onObject:(id)anObject;
{
	BOOL result = YES;
    if (_delegateFlags.shouldSetValue) {
    	result = [_delegate xmlTranslator:self shouldSetValue:value forKey:key onObject:anObject];
    }
    if (!result) {
        CWLogInfo(@"Skipping set value %@ for '%@'", value, key);
    }
    return result;
}

-(BOOL)shouldAddValue:(id)value forKey:(NSString*)key onObject:(id)anObject;
{
	BOOL result = YES;
    if (_delegateFlags.shouldAddValue) {
        result = [_delegate xmlTranslator:self shouldAddValue:value forKey:key onObject:anObject];
    }
    if (!result) {
        CWLogInfo(@"Skipping add value %@ for '%@'", value, key);
    }
    return result;
}

-(void)setValue:(id)value forKey:(id)key onObject:(id)target;
{
    if ([key isKindOfClass:[NSArray class]]) {
        value = [self primitiveObjectInstanceOfClass:NSClassFromString([key objectAtIndex:1]) withString:value forKey:[key objectAtIndex:0]];
        key = [key objectAtIndex:0];
    } else {
        value = [self primitiveObjectInstanceOfClass:[NSString class] withString:value forKey:key];
    }
    if (value) {
        if ([key hasPrefix:@"+"]) {
            key = [key substringFromIndex:1];
            if ([self shouldAddValue:value forKey:key onObject:target]) {
                if ([target isKindOfClass:NSClassFromString(@"NSManagedObject")]) {
                    [[target mutableSetValueForKey:key] addObject:value];
                } else {
                    [[target mutableArrayValueForKey:key] addObject:value];
                }
                CWLogInfo(@"Did add value %@ for '%@'", value, key);
            }
        } else if ([self shouldSetValue:value forKey:key onObject:target]) {
            [target setValue:value forKey:key];
            CWLogInfo(@"Did set value %@ for '%@'", value, key);
        }
    }
}

-(BOOL)shouldTranslateObjectOfClass:(Class)aClass forKey:(NSString*)key;
{
    BOOL result = YES;
    if (_delegateFlags.shouldTranslateObjectOfClass) {
        result = [_delegate xmlTranslator:self shouldTranslateObjectOfClass:aClass forKey:key];
    }
    if (!result) {
    	CWLogInfo(@"Skipping object of class %@ for '%@'",
                   NSStringFromClass(aClass), key);
    }
    return result;
}


-(id)objectInstanceOfClass:(Class)aClass forKey:(NSString*)key;
{
    id result = nil;
    if (_delegateFlags.objectInstanceOfClass) {
        result = [_delegate xmlTranslator:self objectInstanceOfClass:aClass forKey:key];
    }
    if (result == nil) {
        result = [[[aClass alloc] init] autorelease];
    }
    CWLogInfo(@"Did instantiate object of class %@ for '%@' (expected %@)", 
               NSStringFromClass([result class]), key, NSStringFromClass(aClass));
    return result;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
{
    CWXMLTranslatorState* state = [stateStack lastObject];
    NSDictionary* currentTranslationPlist = ((CWXMLTranslatorState*)[stateStack lastObject])->translationPlist;
    for (NSString* key in currentTranslationPlist) {
        if ([key isEqualToString:elementName]) {
            CWLogInfo(@"Will handle tag key: %@", key);
            id target = [currentTranslationPlist objectForKey:key];
			if ([target isKindOfClass:[NSDictionary class]]) {
                id currentObject = nil;
                if (![[target objectForKey:@"@dummy"] boolValue]) {
                    Class aClass = NSClassFromString([target objectForKey:@"@class"]);
                    if ([self shouldTranslateObjectOfClass:aClass forKey:elementName]) {
	                    currentObject = [self objectInstanceOfClass:aClass forKey:elementName];
                        for (NSString* attrKey in target) {
                        	if ([attrKey hasPrefix:@"."]) {
                                CWLogInfo(@"Will handle attribute key: %@", attrKey);
                                NSString* value = [attributeDict objectForKey:[attrKey substringFromIndex:1]];
                                id key = [target objectForKey:attrKey];
                                [self setValue:value forKey:key onObject:currentObject];
                            }
                        }                        
                    } else {
                    	target = nil;
                    }
                }
                CWXMLTranslatorState* state = [[CWXMLTranslatorState alloc] initWithObject:currentObject];
                state->elementName = elementName;
                state->translationPlist = target;
                [stateStack addObject:state];
                [state release];
            } else if ([target isKindOfClass:[NSArray class]]) {
                currentText = [[NSMutableString alloc] init];
                CWXMLTranslatorState* state = [[CWXMLTranslatorState alloc] initWithObject:nil];
                state->elementName = elementName;
                state->translationPlist = target;
                [stateStack addObject:state];
                [state release];
            } else if ([target isEqual:@"@object"]) {
                currentText = [[NSMutableString alloc] init];
                CWXMLTranslatorState* state = [[CWXMLTranslatorState alloc] initWithObject:currentText];
                state->elementName = elementName;
                state->translationPlist = nil;
                [stateStack addObject:state];
                [state release];
            } else {
                if ([state->elementName isEqualToString:elementName]) {
                    state->nestingCount++;
                }
                currentText = [[NSMutableString alloc] init];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
	[currentText appendString:string];
}

-(id)didTranslateObject:(id)anObject forKey:(NSString*)key;
{
    if (_delegateFlags.didTranslateObject) {
        anObject = [_delegate xmlTranslator:self didTranslateObject:anObject forKey:key];
    }
	return anObject;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
	CWXMLTranslatorState* state = [stateStack lastObject];
    if ([state->elementName isEqualToString:elementName]) {
        if (state->nestingCount > 0) {
            state->nestingCount--;
        } else {
            NSString* key = nil;
            id currentObject = state->currentObject;
            if ([state->translationPlist isKindOfClass:[NSDictionary class]]) {
                key = [state->translationPlist objectForKey:@"@key"];
            } else  if ([state->translationPlist isKindOfClass:[NSArray class]]) {
            	key = [(id)state->translationPlist objectAtIndex:0];
                if ([key isEqualToString:@"@object"]) {
                	key = nil;
                }
                Class aClass = NSClassFromString([(id)state->translationPlist objectAtIndex:1]);
                currentObject = [self primitiveObjectInstanceOfClass:aClass withString:currentText forKey:elementName];
            }
            if (key) {
				CWXMLTranslatorState* prevState = nil;
                for (int i = 2; YES; i++) {
                    prevState = [stateStack objectAtIndex:[stateStack count] - i];
                    if (prevState->currentObject) {
                        break;
                    }
                }
                [self setValue:currentObject forKey:key onObject:prevState->currentObject];
            } else if (currentObject) {
                id object = [self didTranslateObject:currentObject forKey:elementName];
                if (object != nil) {
                    [rootObjects addObject:object];
                    CWLogInfo(@"Did add root object %@ for '%@'", object, elementName);
                }
            }
            [stateStack removeLastObject];
        }
    } else {
        for (NSString* tag in state->translationPlist) {
            if ([tag isEqualToString:elementName]) {
                id key = [state->translationPlist objectForKey:tag];
                [self setValue:currentText forKey:key onObject:state->currentObject];
            }
        }
    }
    [currentText release];
    currentText = nil;
}

@end
