//
//  CWStopSelectionController.h
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

@protocol FOPointSelectionControllerDelegate;

/*!
 * @abstract Type of point selection.
 */
typedef enum {
    FOPointSelectionTypeFrom,  //! From point.
    FOPointSelectionTypeTo     //! To point.
} FOPointSelectionType;

/*!
 * @abstract Controller responsible for selecting a point to travek from or to, including as -you-type search.
 *
 * @discussion The controller will add selected point as a known point to the shred model if it is not previosule known.
 */
@interface FOPointSelectionController : UITableViewController <UISearchDisplayDelegate> {
@private
    FOModel* sharedModel;
	id<FOPointSelectionControllerDelegate> pointSelectionDelegate;
	BOOL searchOnly;
	FOPointSelectionType _pointType;
	NSOperationQueue* queue;
    NSArray* _searchResultPoints;
}

@property(nonatomic, readonly, assign) FOPointSelectionType pointType; //! Type of point selection.
@property(nonatomic, assign) BOOL searchOnly;                          //! YES if controller should start in search mode.

/*!
 * @abstract Get a UIViewController that can display more information about this point.
 */
+(UIViewController*)controllerForPoint:(FOPoint*)point;

/*!
 * @abstract Iit controller with delegate to call for user actions.
 */
-(id)initWithPointSelectionType:(FOPointSelectionType)pointType delegate:(id<FOPointSelectionControllerDelegate>)delegate;

@end


/*!
 * @abstract Delegate protocol for responding to user actions.
 */
@protocol FOPointSelectionControllerDelegate <NSObject>

/*!
 * @abstract User selected a point.
 *
 * @discussion It is the responsiblity of the delegate to dismiss the controller if needed.
 */
-(void)pointSelectionController:(FOPointSelectionController*)controller didSelectPoint:(FOPoint*)point;

@end
