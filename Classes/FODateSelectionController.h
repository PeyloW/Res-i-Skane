//
//  CWDateSelectionController.h
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

@protocol FODateSelectionControllerDelegate;


/*!
 * @abstract Controller responsible for managing the screen where users selects time and direction of journey.
 */
@interface FODateSelectionController : UITableViewController {
@private
    id<FODateSelectionControllerDelegate> dateSelectionDelegate;
    FOModel* sharedModel;
    IBOutlet UITableView* realTableView;
    IBOutlet UIView* pickerBackgroundView;
    IBOutlet UIView* translucentBackgroundView;
    IBOutlet UIDatePicker* datePicker;
    IBOutlet UIBarButtonItem* titleItem;
}

/*!
 * @abstract Init controller with delegate to call with user actions.
 */
-(id)initWithDelegate:(id<FODateSelectionControllerDelegate>)delegate;

-(IBAction)cancelCustomDate:(id)sender;
-(IBAction)selectCustomDate:(id)sender;

@end


/*!
 * @abstract Delegate protocol for responding to date selections.
 *
 * @discussion It is the responsibilty of the delegate to dismiss the selection controller if needed.
 */
@protocol FODateSelectionControllerDelegate <NSObject>

@required

/*!
 * @abstract User selected a new direction.
 */
-(void)dateSelectionController:(FODateSelectionController*)controller didSelectDirection:(FOJourneyDirection)direction;

/*!
 * @abstract User selected a new date.
 */
-(void)dateSelectionController:(FODateSelectionController*)controller didSelectDate:(NSDate*)date;

@end
