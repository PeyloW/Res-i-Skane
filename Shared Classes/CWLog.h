//
//  CWLog.h
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



#ifdef __OPTIMIZE__ 
	#define CWLog(...)
	#define CWLogDebug(...)
	#define CWLogInfo(...)
#else
	#define CWLog(...) NSLog(__VA_ARGS__)
	#define CWLogDebug( s, ... ) NSLog( @"DEBUG <%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
	#ifndef LOG_INFO
		#define CWLogInfo(...)
	#else
		#define CWLogInfo( s, ... ) NSLog( @"INFO <%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
	#endif
#endif
#define CWLogWarning( s, ... ) NSLog( @"WARNING <%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define CWLogError( s, ... ) NSLog( @"ERROR <%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
