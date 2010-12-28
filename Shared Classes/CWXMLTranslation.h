//
//  CWXMLTranslationPlist.h
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

extern NSString * const CWXMLTranslationPlistErrorDomain;
extern NSString * const CWXMLTranslationFileExtension;

typedef enum {
    CWXMLTranslationPlistErrorMissingFile = 0, 
	CWXMLTranslationPlistErrorMissingRequiredToken = 1,
    CWXMLTranslationPlistErrorMissingRequiredSymbol = 2
} CWXMLTranslationPlistErrorCode;


/*!
 * @abstract Helper class for reading translation definitions for CWXMLTranslator.
 *
 * @discussion A translation definition is a property list. The internal format for
 *			   the property is complex and undocumented.
 *			   A human readable text-format should instead be used, by loading text files
 *			   using the standard xml translation file extension: .xmltranslation.
 *
 *			   XML Translation format in Backus-Naur Form:
 *					translation ::= statement |							# A translation is one or more statement
 *									"{" statement* "}"
 *					statement 	::= { "." } SYMBOL action { ";" }		# A statement is an XML symbol with an action (prefix . is attributes).
 *					action 		::= "->" translation |					# -> Is a required tag to descend into, but take no action on.
 *									assignment target { ":" type }		# All other actions are assignment to a target, with optional type (NSString is used for untyped actions)
 *					assignment 	::= ">>" |								# Assign to target using setValue:forKey:
 *									"+>"								# Append to target using addValue:forKey:
 *					target 		::= "@root" |							# Target is the array of root objects to return.
 *									SYMBOL								# Target is a named property accessable using setValue:forKey:
 *					type 		::= SYMBOL								# Type is a known Objective-C class (NSNumber, NSDate, NSURL)
 *									SYMBOL translation |				# Type is an Objective-C class with  inline translation definition
 *								"@" SYMBOL								# Type is an Objective-C class with translation defiition in external class
 *
 *			   Exmaple for translation this XML;
 *				 	<Node>
 *						<Id>12</Id>
 *						<Url>http://www.foo.com"</Url>
 *						<Type name="bar" date="2010-10-28"/>
 *					</Node>
 *				To fit these Objective-C classes:
 *					@interface CWNodeType : NSObject {
 *					}
 *					@property(copy) NSString* name;
 *					@property(retain) NSDate* date;
 *					@end
 *					@interface CWNode : NSObject {
 *					}
 *					@property(assign) NSInteger nodeID;
 *					@property(copy) NSURL* url;
 *					@property(retain) CWNodeType* type;
 *					@end
 *				Usr this translation definition
 *					Node +> @root : CWNote {			# Node tag shoudl be added as root object of class CWNode
 *						Id >> nodeID : NSNumber;			#Set Id tag content to nodeID property typed as a NSNumber
 *						Url >> url : NSURL;					# Set Url tag content to url property typed as a NSURL
 *						Type >> type : CWNodeType {			# Type tag sets a the type property to a new instance of CWNodeType class
 *							.name >> name;						# Set name attribute content to name property as a string
 *							.date >> date : NSDate; 			# Set date attribute content to date property typed as a NSDate
 *						}
 *					}
 *		
 *
 */
@interface CWXMLTranslation : NSObject {
@private
	NSMutableArray* _nameStack;
}

/*!
 * @abstract Deserialize a translation definition for a resource name.
 *
 * @discussion Resource is fetched using normal bundle resource rules.
 *			   A file with path extension .xmltranslation is parsed according to rules
 *			   detailed in the class description.
 *			   
 *             Any other file is deserialized as a property list.
 *
 * @param name Name of translation, should NOT include path extension.
 * @param error An out error, localizedFailureReason will include file name and line:column location.
 */
+(NSDictionary*)translationPropertyListNamed:(NSString*)name error:(NSError**)error;

/*!
 * @abstract Deserialize a translation definition from an string.
 */
+(NSDictionary*)translationPropertyListWithDSLInString:(NSString*)dslString error:(NSError**)error;

@end
