//
//  CWJourneyDetailController.m
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

#import "FOJourneyDetailController.h"
#import "NSDate+CWExtentions.h"
#import "FOJourneyDetailCell.h"

@implementation FOJourneyDetailController

-(UITableView*)tableView;
{
	return realTableView;
}

-(id)initWithJourney:(FOJourney*)aJourney;
{
	self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        journey = [aJourney retain];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FromToTime", nil), [journey.departure localizedShortTimeString], [journey.arrival localizedShortTimeString]];
		if ([aJourney isDeviated]) {
			UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deviations_bar.png"]];
            UIBarButtonItem* warningItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
            self.navigationItem.rightBarButtonItem = warningItem;
            [imageView release];
            [warningItem release];
            [[NSBundle mainBundle] loadNibNamed:@"FOJourneyListNavigationItem" owner:self options:nil];
            self.navigationItem.titleView = _navigationItemView;
        }
    }
    return self;
}

-(void)loadView;
{
    [[NSBundle mainBundle] loadNibNamed:@"FOJourneyDetailController" owner:self options:nil];
    realTableView.allowsSelection = NO;
    fromTitleLabel.text = NSLocalizedString(@"FromTitle", nil);
    toTitleLabel.text = NSLocalizedString(@"ToTitle", nil);
    [fromTitleLabel sizeToFit];
    [toTitleLabel sizeToFit];
    CGFloat maxWidth = MAX(fromTitleLabel.bounds.size.width, toTitleLabel.bounds.size.width);
    CGRect frame = fromLabel.frame;
    CGFloat oldX = frame.origin.x;
    frame.origin.x = maxWidth + 21;
    frame.size.width -= (frame.origin.x - oldX);
    fromLabel.frame = frame;
    frame.origin.y += 19;
    toLabel.frame = frame;
}

-(void)viewDidLoad;
{
    FOPoint* from = journey.from;
    FOPoint* to = journey.to;
    fromLabel.text = from.title;
    if (from.ID <= CWPointCurrentLocationID) {
        fromLabel.textColor = [UIColor blueColor];
    }
	toLabel.text = to.title;
    if (to.ID <= CWPointCurrentLocationID) {
        toLabel.textColor = [UIColor blueColor];
    }
}

-(void)dealloc;
{
 	[journey release];
    [super dealloc];
}


#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return [journey.routeLinks count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	FORouteLink* routeLink = [journey.routeLinks objectAtIndex:indexPath.row];
    NSString* deviationsString = routeLink.deviationsAsString;
    if (deviationsString) {
        CGSize size = CGSizeMake(self.tableView.bounds.size.width - 22, 400);
        size = [deviationsString sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
 		return 110.f + size.height;
    } else {
        return 110.f;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    FOJourneyDetailCell *cell = (FOJourneyDetailCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [FOJourneyDetailCell journeyDetailCell];
    }
	FORouteLink* routeLink = [journey.routeLinks objectAtIndex:indexPath.row];
    
	[cell setRouteLink:routeLink];
    
    return cell;
}

@end

