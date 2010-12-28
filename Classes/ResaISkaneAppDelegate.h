//
//  ResaISkaneAppDelegate.h
//  ResaISkane
//
//  Copyright 2009-2010 Fredrik Olsson. All rights reserved.
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

#import <UIKit/UIKit.h>

/*!
 * @abstract Application delegate for Resa i Skane.
 *
 * @discussion Responsibloe for unarchiving model at launch, and archiving model and shutdown. The app delegte must also
 *             reconstruct the state of the previous launch as closely as possible.
 */
@interface ResaISkaneAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
    UINavigationController* mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

