//
//  CWJourneyListController.h
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
#import <MessageUI/MessageUI.h>

/*!
 * @abstract Controller responsible for fetching and displaying a list of journeys matching a search.
 */
@interface FOJourneyListController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
@private
	FOModel* sharedModel;
    IBOutlet UITableView* realTableView;
    IBOutlet UIView* _navigationItemView;
    IBOutlet UILabel* fromTitleLabel;
    IBOutlet UILabel* fromLabel;
    IBOutlet UILabel* toTitleLabel;
    IBOutlet UILabel* toLabel;
    UIBarButtonItem* reverseButton;
	UIBarButtonItem* bookmarkButton;
    UIBarButtonItem* reloadButton;
    NSMutableArray* sectionedList;
}

+ (UIViewController*)controllerForJourney:(FOJourney*)journey;

/*!
 * @abstract Init controller.
 *
 * @discussion Contoller will display previous search result if present in shared model, otherwise a new search will be
 *             done suing the choices in the shared model.
 */
-(id)init;

-(IBAction)reverseJourney:(id)sender;

@end
