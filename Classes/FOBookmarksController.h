//
//  CWBookmarksController.h
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
#import "FOModel.h"

@protocol FOBookmarksDelegate;


/*!
 * @abstract Controller responsible for selectinga bookmark.
 */
@interface FOBookmarksController : UITableViewController {
@private
    id<FOBookmarksDelegate> bookmarksDelegate;
	FOModel* sharedModel;
}

/*!
 * @abstract Init controller with delegate to call for user actions.
 */
-(id)initWithDelegate:(id<FOBookmarksDelegate>)delegate;

@end

/*!
 * @abstract Delegate protocol for responding to user actions.
 */
@protocol FOBookmarksDelegate <NSObject>

/*!
 * @abstract User selected a bookmark.
 *
 * @discussion It is the responsiblity of the delegate to dismiss the controller if needed.
 */
-(void)bookmarksController:(FOBookmarksController*)controller didSelectBookmark:(NSArray*)bookmark;

@end
