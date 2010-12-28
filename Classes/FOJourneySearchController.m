//
//  CWJourneySearchController.m
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

#import "FOJourneySearchController.h"
#import "FOJourneyListController.h"
#import "NSDate+CWExtentions.h"
#import "UITableViewCell+FOActionTextLabel.h"
#import "CWNetworkChecker.h"
#import "UIColor+CWEditableColor.h"
#import "CWTranslatedString.h"
#import "UIWindow+VisualMoveQue.h"
#import "FOLocationIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FOJourneySearchController

-(UITableView*)tableView;
{
	return realTableView;
}

-(void)primitiveInit;
{
    forcedNumberOfRows = -1;
    sharedModel = [FOModel sharedModel];
    self.title = NSLocalizedString(@"AppName", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointStatusDidChangeNotification:) name:FOPointStatusDidChangeNotification object:nil];
}

-(id)init;
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self primitiveInit];
    }
    return self;
}

-(void)awakeFromNib;
{
    [self primitiveInit];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	return [UIDevice isPad] || [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(void)updateBookmarkButton;
{
    actionButton.enabled = ![sharedModel.bookmarkedJourneys containsObject:sharedModel.currentBookmark] && sharedModel.from != nil && sharedModel.to != nil && ![sharedModel.from isEqual:sharedModel.to];
}

-(void)loadView;
{
	[[NSBundle mainBundle] loadNibNamed:@"FOJourneySearchController" owner:self options:nil];
	[self updateBookmarkButton];
}

-(void)viewWillAppear:(BOOL)animated;
{
	if (animated) {
        [self.tableView reloadData];
    }
    [self updateBookmarkButton];
    [super viewWillAppear:animated];
}

-(IBAction)bookmarkJourney:(id)sender;
{
    [sharedModel.bookmarkedJourneys insertObject:sharedModel.currentBookmark atIndex:0];
    actionButton.enabled = NO;
    
	CGRect fromRect = [self.tableView rectForSection:1];
    fromRect.origin.y += (fromRect.size.height - 44*2);
    fromRect.size.height = 44*2;
    fromRect = [self.tableView convertRect:fromRect toView:nil];
    CGRect toRect = self.tableView.window.frame;
    toRect = CGRectMake(toRect.size.width - 44, toRect.size.height - 44, 44, 44);
    
	UIGraphicsBeginImageContext(fromRect.size);
    self.tableView.backgroundColor = [UIColor clearColor];
    for (int i = 0; i < 2; i++) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, cell.bounds.size.height * i);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    fromRect = CGRectInset(fromRect, -16, -16);
    
	UIGraphicsBeginImageContext(fromRect.size);
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, -2), 12, [UIColor blackColor].CGColor);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(16, -16, image.size.width, -image.size.height), image.CGImage);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    fromRect.origin.y -= 16;
    
	[self.tableView.window displayVisualQueForMovingImage:image fromRect:fromRect toRect:toRect];
}

-(BOOL)canSearchTrip;
{
	return [sharedModel.from isReady] && [sharedModel.to isReady] && ![sharedModel.from isEqual:sharedModel.to];
}

-(void)currentLocationAccessoryTapped:(id)sender;
{
    FOPoint* point = [FOPoint currentLocationPoint];
	FOPointStatus pointStatus = [point pointStatus];
    if (pointStatus != FOPointStatusPending && pointStatus != FOPointStatusError) {
        UIViewController* controller = [FOPointSelectionController controllerForPoint:[FOPoint currentLocationPoint]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
	if (indexPath.section == 1) {
        FOPoint* point = nil;
        switch (indexPath.row) {
			case 0:
                point = sharedModel.from;
                break;
            case 1:
                point = sharedModel.to;
                break;
        }
		UIViewController* controller = [FOPointSelectionController controllerForPoint:point];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)setupTableViewCell:(UITableViewCell*)cell forStopAtRow:(NSUInteger)row;
{
    FOPoint* point = row == 0 ? sharedModel.from : sharedModel.to;
    if (point == nil && [CWNetworkChecker isNetworkAvailable]) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = (int)row;
        [button addTarget:self action:@selector(didTapSearchAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"search_accessory.png"] forState:UIControlStateNormal];
        [button sizeToFit];
        cell.accessoryView = button;
    } else if (point.pointStatus == FOPointStatusPending || point.pointStatus == FOPointStatusInitial) {
		UIView* view = [[FOLocationIndicatorView alloc] init];
        cell.accessoryView = view;
        [view release];
    } else if ([CWNetworkChecker isNetworkAvailable]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (row == 0) {
        cell.textLabel.text = NSLocalizedString(@"From", nil);
    } else {
        cell.textLabel.text = NSLocalizedString(@"To", nil);
    }
    cell.detailTextLabel.text = point.title;
    if (cell.detailTextLabel.text) {
        UIColor* color = [UIColor editableColor];
        switch (point.pointStatus) {
            case FOPointStatusKnown:
            case FOPointStatusInitial:
            case FOPointStatusPending:
                color = [UIColor blueColor];
                break;
            case FOPointStatusError:
                color = [UIColor warningTextColor];
                break;
        }
		cell.detailTextLabel.textColor = color;
    } else {
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = NSLocalizedString(@"Choose", nil);
    }
    [cell setTextLabelTarget:self action:@selector(swapFromAndTo:)];
}

-(void)updateStopAndSearchRows;
{
	BOOL couldSearch = [self.tableView numberOfRowsInSection:2] > 0;
	BOOL canSearch = [self canSearchTrip];
    if (couldSearch != canSearch) {
        NSArray* indexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]];
        if (canSearch) {
            [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        } else {
            [self.tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    [self setupTableViewCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] forStopAtRow:0];
    [self setupTableViewCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] forStopAtRow:1];
	[self updateBookmarkButton];
}

-(void)pointStatusDidChangeNotification:(NSNotification*)notification;
{
	[self updateStopAndSearchRows];
}

-(IBAction)showBookmarks:(id)sender;
{
	FOBookmarksController* controller = [[FOBookmarksController alloc] initWithDelegate:self];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)bookmarksController:(FOBookmarksController *)controller didSelectBookmark:(NSArray *)bookmark;
{
	sharedModel.from = [bookmark objectAtIndex:0];
    sharedModel.to = [bookmark objectAtIndex:1];
	[self updateStopAndSearchRows];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)directionLabelDidFade:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
	UITableViewCell* cell = (UITableViewCell*)context;
	cell.textLabel.text = NSLocalizedString(sharedModel.direction == FOJourneyDirectionArrival ? @"Arrival" : @"Departure", nil);
	[cell setNeedsLayout];
	[UIView beginAnimations:@"fadeInDirectionLabel" context:cell];
	cell.textLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)swapDirections:(id)sender;
{
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    sharedModel.direction = sharedModel.direction == FOJourneyDirectionArrival ? FOJourneyDirectionDeparture : FOJourneyDirectionArrival;
    [UIView beginAnimations:@"fadeOutDirectionLabel" context:cell];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(directionLabelDidFade:finished:context:)];
	cell.textLabel.alpha = 0;
    [UIView commitAnimations];
}

-(IBAction)swapFromAndTo:(id)sender;
{
    FOPoint* tempPoint = sharedModel.from;
    sharedModel.from = sharedModel.to;
    sharedModel.to = tempPoint;
    forcedNumberOfRows = [self.tableView numberOfRowsInSection:2];
	[self.tableView beginUpdates];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"To", nil);
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    forcedNumberOfRows = -1;
	[self updateBookmarkButton];
}

-(void)toggleTranslateTexts:(UISwitch*)translateSwitch;
{
	sharedModel.translateTexts = translateSwitch.on;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
	return [CWCurrentLanguageIdentifier() isEqualToString:@"sv"] ? 3 : 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return indexPath.section == 3 ? 66 : 44;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (indexPath.section == 3) {
        return nil;
    }
    return indexPath;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	switch(section) {
        case 0:
            return 1;
        case 1:
            return 2;
		case 2:
            return forcedNumberOfRows >= 0 ? forcedNumberOfRows : ([self canSearchTrip] ? 1 : 0);
		default:
            return 1;
    }
}

-(UITableViewCell*)cellForDateSelectionInTableView:(UITableView*)tableView;
{
	static NSString* cellId = @"dateId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setTextLabelTarget:self action:@selector(swapDirections:)];
    }
    cell.textLabel.text = NSLocalizedString(sharedModel.direction == FOJourneyDirectionArrival ? @"Arrival" : @"Departure", nil);
    cell.detailTextLabel.text = [sharedModel.date localizedShortString];
    return cell;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForStopAtRow:(NSUInteger)row;
{
	static NSString* cellId = @"stopId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId] autorelease];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
	[self setupTableViewCell:cell forStopAtRow:row];
    return cell;
}

-(UITableViewCell*)cellForSearchButtonInTableView:(UITableView*)tableView;
{
	static NSString* cellId = @"buttonId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor editableColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    }
    cell.textLabel.text = NSLocalizedString(@"SearchTrips", nil);
    return cell;
}

-(UITableViewCell*)cellForTranslationOptionInTableView:(UITableView*)tableView;
{
	static NSString* cellId = @"buttonId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
        UISwitch* accessorySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        accessorySwitch.on = sharedModel.translateTexts;
        [accessorySwitch addTarget:self action:@selector(toggleTranslateTexts:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = accessorySwitch;
        [accessorySwitch release];
		UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.opaque = NO;
        backgroundView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backgroundView;
        [backgroundView release];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.textColor = [UIColor groupedLabelTextColor];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor groupedLabelTextColor];
        cell.detailTextLabel.shadowColor = [UIColor whiteColor];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.textLabel.text = NSLocalizedString(@"TranslateText", nil);
    cell.detailTextLabel.text = NSLocalizedString(@"TranslateTextDisclaimer", nil);
    
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.section) {
        case 0:
            return [self cellForDateSelectionInTableView:tableView];
        case 1:
            return [self tableView:tableView cellForStopAtRow:indexPath.row];
        case 2:
            return [self cellForSearchButtonInTableView:tableView];
        case 3:
            return [self cellForTranslationOptionInTableView:tableView];
    }
    return nil;
}

-(void)displayDateSelectionController;
{
	FODateSelectionController* controller = [[FODateSelectionController alloc] initWithDelegate:self];
    if ([UIDevice isPhone]) {
	    [self.navigationController pushViewController:controller animated:YES];
    } else {
    	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.stackController popToRootViewControllerAnimated:YES];
        [self.stackController pushViewController:navController animated:YES];
        [navController release];
    }
    [controller release];
}

-(void)displayPointSelectionControllerForRow:(NSInteger)row search:(BOOL)search;
{
    FOPointSelectionType type = row == 0 ? FOPointSelectionTypeFrom : FOPointSelectionTypeTo;
    FOPointSelectionController* controller = [[FOPointSelectionController alloc] initWithPointSelectionType:type delegate:self];
    if ([UIDevice isPhone]) {
	    [self.navigationController pushViewController:controller animated:YES];
    } else {
    	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.stackController popToRootViewControllerAnimated:YES];
        [self.stackController pushViewController:navController animated:YES];
        [navController release];
    }
    if (search) {
        controller.searchOnly = YES;
        controller.searchDisplayController.active = YES;
        [controller.searchDisplayController.searchBar becomeFirstResponder];
    }
    [controller release];
}

-(void)displayJourneyListController;
{
    if ([CWNetworkChecker isNetworkAvailable]) {
        UIViewController* controller = [[FOJourneyListController alloc] init];
        if ([UIDevice isPhone]) {
            [self presentModalViewController:controller animated:YES];
        } else {
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self.stackController popToRootViewControllerAnimated:YES];
            [self.stackController pushViewController:navController animated:YES];
            [navController release];
        }
        [controller release];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoNetwork", nil) message:NSLocalizedString(@"NoNetworkTrips", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)didTapSearchAccessoryButton:(id)sender;
{
    [self displayPointSelectionControllerForRow:[sender tag] search:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([UIDevice isPhone]) {
	    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
	switch (indexPath.section) {
        case 0:
            [self displayDateSelectionController];
            break;
        case 1:
            [self displayPointSelectionControllerForRow:indexPath.row search:NO];
            break;
        default:
            [self displayJourneyListController];
            break;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
	switch (indexPath.section) {
        case 0:
            return ![sharedModel.date isEqualToDate:[NSDate relativeDateWithTimeIntervalSinceNow:0]];
        case 1:
			return (indexPath.row == 0 ? sharedModel.from : sharedModel.to) != nil;
        default:
            return NO;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	switch (indexPath.section) {
        case 0:
            return NSLocalizedString(@"Now", nil);
        case 1:
            return NSLocalizedString(@"Clear", nil);
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		switch (indexPath.section) {
            case 0:
                sharedModel.date = [NSDate relativeDateWithTimeIntervalSinceNow:0];
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        sharedModel.from = nil;
                        break;
                    case 1:
                        sharedModel.to = nil;
                        break;
                }
                [self updateStopAndSearchRows];
                break;
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
	if (section == 1) {
        return NSLocalizedString(@"TravelRoute", nil);
    } else {
        return nil;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
	if (section == 2) {
        return @" ";
    } else {
        return nil;
    }
}

-(void)dateSelectionController:(FODateSelectionController *)controller didSelectDirection:(FOJourneyDirection)direction;
{
	sharedModel.direction = direction;
    [self.tableView reloadData];
}

-(void)dateSelectionController:(FODateSelectionController *)controller didSelectDate:(NSDate *)date;
{
	sharedModel.date = date;
    if ([UIDevice isPhone]) {
        [self.navigationController popToViewController:self animated:YES];
    } else {
        [self.stackController popToRootViewControllerAnimated:YES];
    }
    [self.tableView reloadData];
}

-(void)pointSelectionController:(FOPointSelectionController*)controller didSelectPoint:(FOPoint*)point;
{
	if (controller.pointType == FOPointSelectionTypeFrom) {
        sharedModel.from = point;
    } else {
        sharedModel.to = point;
    }
	[self updateStopAndSearchRows];
    if ([UIDevice isPhone]) {
        [self.navigationController popToViewController:self animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [self.stackController popToRootViewControllerAnimated:YES];
    }
}

@end
