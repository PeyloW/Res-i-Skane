//
//  CWJourneySearchController.h
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
#import "FODateSelectionController.h"
#import "FOPointSelectionController.h"
#import "FOBookmarksController.h"


/*!
 * @abstract Controller responsible for managing the main journey search screen.
 */
@interface FOJourneySearchController : UITableViewController <FOBookmarksDelegate, FODateSelectionControllerDelegate, FOPointSelectionControllerDelegate, UIActionSheetDelegate> {
@private
    FOModel* sharedModel;
    IBOutlet UITableView* realTableView;
    IBOutlet UIBarButtonItem* actionButton;
    int forcedNumberOfRows;
}

-(id)init;

-(IBAction)swapFromAndTo:(id)sender;
-(IBAction)bookmarkJourney:(id)sender;
-(IBAction)showBookmarks:(id)sender;


@end
