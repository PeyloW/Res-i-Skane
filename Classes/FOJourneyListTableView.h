//
//  CWJournetListTableView.h
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
 * @abstract The special view used for fetching previous and next by fragging and dropping.
 */
@interface FOMoreView : UIView {
@private
    IBOutlet UIView* contentView;
    IBOutlet UIImageView* arrowImageView;
    IBOutlet UIActivityIndicatorView* activityIndicatorView;
    IBOutlet UILabel* titleLabel;
    BOOL _before;
    BOOL _loading;
    BOOL _primed;
    CGAffineTransform targetTransform;
}

@property(nonatomic, assign) BOOL before;       //! YES if this is the top view for fetching previous.
@property(nonatomic, assign) BOOL primed;       //! YES if the scroll view is dragged far enough to trigger a fech by drop.
@property(nonatomic, assign) BOOL loading;      //! YES if the application is currently fecthing more data.

/*!
 * @abstract Return a cell using CWMoreView.nib.
 */
+(FOMoreView*)moreViewForBefore:(BOOL)before;

@end

/*!
 * @abstract A UITableView subclass that can display Tweetie 2 like drg and drop to load views.
 */
@interface FOJourneyListTableView : UITableView {
@private
    FOMoreView* beforeMoreView;
    FOMoreView* afterMoreView;
}

@property(nonatomic, readonly) FOMoreView* beforeMoreView;  //! More view to fetch previous.
@property(nonatomic, readonly) FOMoreView* afterMoreView;   //! More view to fetch next.

@end
