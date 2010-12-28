//
//  CWJourneyDetailCell.h
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

/*!
 * @discussion Table view cell for dipsplaying one route link.
 */
@interface FOJourneyDetailCell : UITableViewCell {
@private
    IBOutlet UIImageView* lineTypeImageView;
    IBOutlet UILabel* lineLabel;
	IBOutlet UILabel* stopPointLabel;
	IBOutlet UILabel* fromTitleLabel;
    IBOutlet UILabel* fromLabel;
    IBOutlet UILabel* fromTimeLabel;
	IBOutlet UILabel* toTitleLabel;
    IBOutlet UILabel* toLabel;
    IBOutlet UILabel* toTimeLabel;
    IBOutlet UILabel* towardsTitleLabel;
    IBOutlet UILabel* towardsLabel;
    IBOutlet UILabel* deviationsLabel;
}

/*!
 * @abstract Return a cell using CWJourneyDetail.nib.
 */
+(FOJourneyDetailCell*)journeyDetailCell;

/*!
 * @abstract Update cell with information from route link.
 */
-(void)setRouteLink:(FORouteLink*)routeLink;

/*!
 * @abstract Get the height required for displaing the cell, including all deviation information.
 */
-(CGFloat)rowHeight;


@end
