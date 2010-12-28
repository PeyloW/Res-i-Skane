//
//  CWTranslatedString.m
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

#import "CWTranslatedString.h"


NSString* CWCurrentLanguageIdentifier() {
    static NSString* currentLanguage = nil;
    if (currentLanguage == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
        currentLanguage = [[languages objectAtIndex:0] retain];
    }
    return currentLanguage;
}

NSString* CWTranslatedString(NSString* string, NSString* sourceLanguageIdentifier) {
    static NSString* queryURL = @"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%@&langpair=%@%%7C%@";
    if (sourceLanguageIdentifier == nil) {
        sourceLanguageIdentifier = @"en";
    }
    if ([sourceLanguageIdentifier isEqual:CWCurrentLanguageIdentifier()] || string == nil) {
        return string;
    }
    NSString* escapedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* query = [NSString stringWithFormat:queryURL,
                       escapedString, sourceLanguageIdentifier, CWCurrentLanguageIdentifier()];
    NSString* response = [NSString stringWithContentsOfURL:[NSURL URLWithString:query]
                                                  encoding:NSUTF8StringEncoding error:NULL];
    if (response == nil) {
        return string;
    }
    NSScanner* scanner = [NSScanner scannerWithString:response];
    if (![scanner scanUpToString:@"\"translatedText\":\"" intoString:NULL]) {
        return string;
    }
    if (![scanner scanString:@"\"translatedText\":\"" intoString:NULL]) {
        return string;
    }
    NSString* result = nil;
    if (![scanner scanUpToString:@"\"}" intoString:&result]) {
        return string;
    }
    return result;
}