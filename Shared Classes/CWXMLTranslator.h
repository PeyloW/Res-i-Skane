//
//  CWXMLParser.h
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

#import <Foundation/Foundation.h>


@protocol CWXMLTranslatorDelegate;

/*!
 * @abstract A utility class for traslating a XML document into an object graph.
 *
 * @discussion The translation to apply is defined in a property list. Objects to create must be KVC-complient for the
 *             properties to translate. The root objects will be sent to the delegate, and all other objects int he graph
 *             will be set as properties on their parent.
 *             Translation is a blocking call, and should be called from a background thread.
 *             PLIST FORMAT IS NOT DOCUMENTED AND CAN/WILL CHANGE.
 *
 *			   Core Data support should be implemented by using the thread local managed object 
 *			   context fron the CWCoreData dependency.
 */
@interface CWXMLTranslator : NSObject
/*
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
<NSXMLParserDelegate>
#endif 
*/
{
@private
	id<CWXMLTranslatorDelegate> _delegate;
    struct {
    	unsigned int shouldTranslateObjectOfClass:1;
    	unsigned int objectInstanceOfClass:1;
    	unsigned int didTranslateObject:1;
        unsigned int shouldTranslatePrimitiveObjectOfClass:1;
    	unsigned int primitiveObjectInstanceOfClass:1;
    	unsigned int shouldSetValue:1;
    	unsigned int shouldAddValue:1;
    } _delegateFlags;
// Super private!
	NSDictionary* translationPlist;
	NSMutableArray* stateStack;
	NSMutableString* currentText;
	NSMutableArray* rootObjects;
	NSXMLParser* xmlParser;
	BOOL didAbort;
}

/*!
 * @abstract The translation delegate.
 * @discussion The delegate methods are always called on the same thread that the translation was started from.
 */
@property(nonatomic, assign) id<CWXMLTranslatorDelegate> delegate;

/*!
 * @abstract Init translator with delegate to send created root objects to.
 */
-(id)initWithTranslationPropertyList:(NSDictionary*)translationPlist delegate:(id<CWXMLTranslatorDelegate>)delegate;

/*!
 * @abstract Translate the XML document in data using a delegate and an optional out error argument.
 */
-(NSArray*)translateContentsOfData:(NSData*)data error:(NSError**)error;

/*!
 * @abstract Translate the XML document referenced by an URL using a default delegate and an optional out error argument.
 */
-(NSArray*)translateContentsOfURL:(NSURL*)url error:(NSError**)error;

/*!
 * @abstract fetch the currently parsed object.
 */
-(id)currentObject;

/*!
 * @abstract Replace the currently parsed object with another object.
 *
 * @discussion Replace with nil to cancel the parsing on the current object.
 */
-(void)replaceCurrentObjectWithObject:(id)object;

/*!
 * @abstract Abort the translation, should be called on the translator from a delegate callback method. 
 */
-(void)abortTranslation;

@end


/*!
 * @abstract Delegate for handling he result of a XML transltion.
 */
@protocol CWXMLTranslatorDelegate <NSObject>

@optional

/*!
 * @abstract Query if translator should translate an object of a class for a key.
 */
-(BOOL)xmlTranslator:(CWXMLTranslator*)translator shouldTranslateObjectOfClass:(Class)aClass forKey:(NSString*)key;

/*!
 * @abstract Implement for custom instantiation of an object of a given class.
 *
 * @discussion Return an autoreleased and initialized object if you need a custom object initialization.
 *             Otherwise return nil, to let the translator instantiate using [[aClass alloc] init].
 */
-(id)xmlTranslator:(CWXMLTranslator*)translator objectInstanceOfClass:(Class)aClass forKey:(NSString*)key;

/*!
 * @abstract Translator did translate an obejct for a specified key.
 *
 * @discussion Called before assigning to the target. Delegate may replace the object, or return nil if the object
 *             should not be added to the root object array.
 */
-(id)xmlTranslator:(CWXMLTranslator*)translator didTranslateObject:(id)anObject forKey:(NSString*)key;

/*!
 * @abstract Query of translator should translate a specified value for a key.
 */
-(BOOL)xmlTranslator:(CWXMLTranslator*)translator shouldTranslatePrimitiveObjectOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;

/*!
 * @abstract Implement custom instansiation of a value object of a given class.
 *
 * @discussion Return an autoreleased and initialized object if you need a custom object initialization.
 *             Otherwise return nil, to let the translator instantiate using [[aClass alloc] initWithString:].
 */
-(id)xmlTranslator:(CWXMLTranslator*)translator primitiveObjectInstanceOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;

/*!
 * @abstract Query if translator should set object for key on current object.
 *
 * @discussion Is always called on main thread, so can be used for thread safety on Core Data managed objects.
 */
-(BOOL)xmlTranslator:(CWXMLTranslator*)translator shouldSetValue:(id)value forKey:(NSString*)key onObject:(id)anObject;

/*!
 * @abstract Query if translator should set object for key on current object.
 *
 * @discussion Is always called on main thread, so can be used for thread safety on Core Data managed objects.
 */
-(BOOL)xmlTranslator:(CWXMLTranslator*)translator shouldAddValue:(id)value forKey:(NSString*)key onObject:(id)anObject;

@end

