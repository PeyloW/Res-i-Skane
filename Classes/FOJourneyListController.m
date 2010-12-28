//
//  CWJourneyListController.m
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

#import "FOJourneyListController.h"
#import "NSDate+CWExtentions.h"
#import "FOJourneyListCell.h"
#import "FOJourneyDetailController.h"
#import "FOJourneyListTableView.h"
#import "CWNetworkChecker.h"
#import "FOMapViewController.h"
#import "CWGroupedController.h"
#import <QuartzCore/QuartzCore.h>


typedef enum {
    FOFetchTypeExisting,
	FOFetchTypeInitial,
    FOFetchTypePrevious,
    FOFetchTypeNext
} FOFetchType;

@implementation FOJourneyListController

-(UITableView*)tableView;
{
	return realTableView;
}

-(CGFloat)outsideOffset;
{
    UITableView* tableView = self.tableView;
    CGFloat offset = tableView.contentOffset.y;
    if (offset < 0) {
        return offset;
    }
    CGFloat height = tableView.contentSize.height - tableView.bounds.size.height;
    return MAX(0, offset - height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    FOJourneyListTableView* tableView = (FOJourneyListTableView*)scrollView;
    tableView.beforeMoreView.hidden = ([sharedModel.currentJourneyList count] == 0 || tableView.afterMoreView.loading) && !tableView.beforeMoreView.loading || ![CWNetworkChecker isNetworkAvailable];
    tableView.afterMoreView.hidden = [sharedModel.currentJourneyList count] == 0 || tableView.beforeMoreView.loading || ![CWNetworkChecker isNetworkAvailable];
    CGFloat offset = [self outsideOffset];
    if (offset < 0) {
        FOMoreView* moreView = tableView.beforeMoreView;
        if (!moreView.loading) {
            moreView.primed = (offset < -60);
        }
    }
    if (offset > 0) {
        FOMoreView* moreView = tableView.afterMoreView;
        if (!moreView.loading) {
            moreView.primed = (offset > 60);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    FOJourneyListTableView* tableView = (FOJourneyListTableView*)scrollView;
    CGFloat offset = [self outsideOffset];
    if (offset < -60) {
        FOMoreView* moreView = tableView.beforeMoreView;
        if (!(moreView.loading || tableView.afterMoreView.loading)) {
            moreView.loading = YES;
			tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
            reverseButton.enabled = NO;
            reloadButton.enabled = NO;
            [self performSelectorInBackground:@selector(fetchPreviousJourneyList) withObject:nil];
        }
    }
    if (offset > 60) {
        FOMoreView* moreView = tableView.afterMoreView;
        if (!(moreView.loading || tableView.beforeMoreView.loading)) {
            moreView.loading = YES;
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
            reverseButton.enabled = NO;
            reloadButton.enabled = NO;
            [self performSelectorInBackground:@selector(fetchNextJourneyList) withObject:nil];
        }
    }
}

-(id)init;
{
	self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        sharedModel = [FOModel sharedModel];
        self.title = NSLocalizedString(@"Trips", nil);
        UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(closeJourneyList:)];
		self.navigationItem.leftBarButtonItem = closeButton;
        [closeButton release];
        reverseButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"swap.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reverseJourney:)];
        bookmarkButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectAction:)];
		bookmarkButton.enabled = ![sharedModel.bookmarkedJourneys containsObject:sharedModel.currentBookmark];
        reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadJourney:)];
        UIBarButtonItem* flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
        self.toolbarItems = [NSArray arrayWithObjects:reverseButton, flex, bookmarkButton, flex, reloadButton, nil];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:self];
        controller.toolbarHidden = NO;
        [[NSBundle mainBundle] loadNibNamed:@"FOJourneyListNavigationItem" owner:self options:nil];
        self.navigationItem.titleView = _navigationItemView;
        [self release];
		return controller;
    }
    return nil;
}

-(void)selectAction:(id)sender;
{
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil /*NSLocalizedString(@"TripActions", nil)*/ delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Bookmark", nil), nil]; //NSLocalizedString(@"ShareText", nil), [MFMailComposeViewController canSendMail] ? NSLocalizedString(@"ShareEmail", nil) : nil, nil];
	[sheet showInView:self.view.window];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex == 0) {
        [sharedModel.bookmarkedJourneys insertObject:sharedModel.currentBookmark atIndex:0];
        bookmarkButton.enabled = NO;
    }
}


-(void)closeJourneyList:(id)sender;
{
    [sharedModel clearJourneys];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)loadView;
{
	[[NSBundle mainBundle] loadNibNamed:@"FOJourneyListController" owner:self options:nil];
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
    if (![CWNetworkChecker isNetworkAvailable]) {
        reverseButton.enabled = NO;
        reloadButton.enabled = NO;
    }
}

-(void)insertNewSectionsAndRowsWithOldSectionedList:(NSArray*)oldSectionedList;
{
    [self.tableView beginUpdates];
	if ([[oldSectionedList objectAtIndex:0] count] == 0 || [[[oldSectionedList objectAtIndex:0] objectAtIndex:0] isEqual:[[sectionedList objectAtIndex:0] objectAtIndex:0]]) {
        // Insert at end
        UITableViewRowAnimation animation = UITableViewRowAnimationTop;
        int lastOldSection = [oldSectionedList count] - 1;
        int oldLastSectionRowCount = [[oldSectionedList objectAtIndex:lastOldSection] count];
        int sections = [sectionedList count] - [oldSectionedList count];
        int rows = [[sectionedList objectAtIndex:lastOldSection] count] - oldLastSectionRowCount;
		if (rows != 0) {
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < rows; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i + oldLastSectionRowCount inSection:lastOldSection]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        }
        if (sections != 0) {
            NSMutableIndexSet* sectionSet = [NSMutableIndexSet indexSet];
            for (int i = 1; i <= sections; i++) {
                [sectionSet addIndex:i + lastOldSection];
            }
            [self.tableView insertSections:sectionSet withRowAnimation:animation];
        }
    } else {
        // Insert at beginning
        UITableViewRowAnimation animation = UITableViewRowAnimationBottom;
		int sections = [sectionedList count] - [oldSectionedList count];
        int rows = [[sectionedList objectAtIndex:sections] count] - [[oldSectionedList objectAtIndex:0] count];
        if (sections != 0) {
            NSMutableIndexSet* sectionSet = [NSMutableIndexSet indexSet];
            for (int i = 0; i < sections; i++) {
                [sectionSet addIndex:i];
            }
            [self.tableView insertSections:sectionSet withRowAnimation:animation];
        }
        if (rows != 0) {
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = 0; i < rows; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:sections]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        }
    }
    [self.tableView endUpdates];
}

-(void)splitJourneysIntoSections:(NSNumber*)aFetchType;
{
    reverseButton.enabled = YES;
    reloadButton.enabled = YES;
    FOFetchType fetchType = [aFetchType intValue];
    FOJourneyListTableView* tableView = (FOJourneyListTableView*)self.tableView;
    tableView.beforeMoreView.loading = NO;
    tableView.afterMoreView.loading = NO;
    if (fetchType == FOFetchTypeInitial) {
        [UIView beginAnimations:@"animateMoreViews" context:NULL];
        tableView.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
    } else {
        tableView.contentInset = UIEdgeInsetsZero;
    }
    NSMutableArray* oldSectionedList = (sectionedList != nil) ? [[sectionedList copy] autorelease] : [NSArray arrayWithObject:[NSArray array]];
	[sectionedList release];
    sectionedList = [NSMutableArray new];
	NSMutableArray* currentSection = nil;
    NSString* dateString = nil;
    for (FOJourney* journey in sharedModel.currentJourneyList) {
		NSString* newDateString = [journey.departure localizedShortDateString];
        if (![newDateString isEqualToString:dateString]) {
            currentSection = [NSMutableArray array];
            [sectionedList addObject:currentSection];
        }
        [currentSection addObject:journey];
        dateString = newDateString;
    }
    if (fetchType == FOFetchTypeInitial) {
        [self insertNewSectionsAndRowsWithOldSectionedList:oldSectionedList];
    } else {
        CGFloat oldContentOffset = self.tableView.contentOffset.y;
        CGFloat oldOffsetFromBottom = self.tableView.contentSize.height - oldContentOffset;
        [tableView reloadData];
        if (fetchType == FOFetchTypePrevious) {
			tableView.contentOffset = CGPointMake(0, (tableView.contentSize.height - oldOffsetFromBottom) - 60);
        } else if (fetchType == FOFetchTypeNext) {
            tableView.contentOffset = CGPointMake(0, oldContentOffset + 60);
        }
    }
}

-(void)viewDidLoad;
{
    FOPoint* from = sharedModel.from;
    FOPoint* to = sharedModel.to;
    if ([sharedModel.currentJourneyList count] > 0) {
        FOJourney* journey = [sharedModel.currentJourneyList objectAtIndex:0];
        from = journey.from;
        to = journey.to;
    }
    fromLabel.text = from.title;
    if (sharedModel.from.ID <= CWPointCurrentLocationID) {
        fromLabel.textColor = [UIColor blueColor];
    }
	toLabel.text = to.title;
    if (sharedModel.to.ID <= CWPointCurrentLocationID) {
        toLabel.textColor = [UIColor blueColor];
    }
    if (sharedModel.currentJourneyList == nil) {
        FOJourneyListTableView* tableView = (FOJourneyListTableView*)self.tableView;
        tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        tableView.beforeMoreView.loading = YES;
        [self scrollViewDidScroll:self.tableView];
        reverseButton.enabled = NO;
        reloadButton.enabled = NO;
        [self performSelectorInBackground:@selector(fetchInitialJourneyList) withObject:nil];
    } else if (sectionedList == nil) {
        [self splitJourneysIntoSections:[NSNumber numberWithInt:FOFetchTypeExisting]];
    }
}

-(CAKeyframeAnimation*)ballisticAnimationFrom:(CGPoint)from to:(CGPoint)to tiltLeft:(BOOL)tiltLeft;
{
    CGMutablePathRef ballisticPath = CGPathCreateMutable();
    CGPathMoveToPoint(ballisticPath, NULL, from.x, from.y);
    CGPathAddQuadCurveToPoint(ballisticPath, NULL, (from.x + to.x) / 2 - (tiltLeft ? 10 : -10), (from.y + to.y) / 2, to.x, to.y);
    CAKeyframeAnimation* keyFrame = [CAKeyframeAnimation animation];
    keyFrame.keyPath = @"position";
    keyFrame.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil];
    keyFrame.path = ballisticPath;
    keyFrame.duration = 0.2f;
    keyFrame.calculationMode = kCAAnimationLinear;
    keyFrame.fillMode = @"frozen";
    keyFrame.removedOnCompletion = NO;
    keyFrame.delegate = self;
    CGPathRelease(ballisticPath);
	return keyFrame;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
    static int count = 0;
    count = (count + 1) & 1;
    if (count == 0) {
		[fromLabel.layer removeAllAnimations];
		[toLabel.layer removeAllAnimations];
        [self viewDidLoad];
    }
}

-(IBAction)reloadJourney:(id)sender;
{
    reverseButton.enabled = NO;
    reloadButton.enabled = NO;
    [sectionedList release];
    sectionedList = nil;
	[sharedModel clearJourneys];
	[self.tableView reloadData];
    [self viewDidLoad];
}

-(IBAction)reverseJourney:(id)sender;
{
    reverseButton.enabled = NO;
    reloadButton.enabled = NO;
    [sectionedList release];
    sectionedList = nil;
	[sharedModel clearJourneys];
	[self.tableView reloadData];
    id temp = sharedModel.to;
    sharedModel.to = sharedModel.from;
    sharedModel.from = temp;
	[fromLabel.layer addAnimation:[self ballisticAnimationFrom:fromLabel.center to:toLabel.center tiltLeft:NO] forKey:@"position"];
	[toLabel.layer addAnimation:[self ballisticAnimationFrom:toLabel.center to:fromLabel.center tiltLeft:YES] forKey:@"position"];
}

-(void)fetchInitialJourneyList;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSArray* journeys = [FOJourney journeysFrom:sharedModel.from to:sharedModel.to at:sharedModel.date inDirection:sharedModel.direction];
    if (journeys == nil) {
        [self performSelectorOnMainThread:@selector(closeJourneyList:) withObject:nil waitUntilDone:false];
    } else {
        [sharedModel addJourneys:journeys];
        [self performSelectorOnMainThread:@selector(splitJourneysIntoSections:) withObject:[NSNumber numberWithInt:FOFetchTypeInitial] waitUntilDone:NO];
	}
    [pool release];
}

-(void)fetchPreviousJourneyList;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    reverseButton.enabled = NO;
    NSArray* journeys = [FOJourney journeysBefore:[sharedModel.currentJourneyList objectAtIndex:0]];
    if (journeys == nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [sharedModel addJourneys:journeys];
        [self performSelectorOnMainThread:@selector(splitJourneysIntoSections:) withObject:[NSNumber numberWithInt:FOFetchTypePrevious] waitUntilDone:YES];
	}
    [pool release];
}

-(void)fetchNextJourneyList;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSArray* journeys = [FOJourney journeysAfter:[sharedModel.currentJourneyList lastObject]];
    if (journeys == nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [sharedModel addJourneys:journeys];
        [self performSelectorOnMainThread:@selector(splitJourneysIntoSections:) withObject:[NSNumber numberWithInt:FOFetchTypeNext] waitUntilDone:NO];
    }
    [pool release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MAX([sectionedList count], 1);
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (sectionedList != nil) {
		return [[[[sectionedList objectAtIndex:section] objectAtIndex:0] departure] localizedShortDateString];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return [[sectionedList objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    FOJourneyListCell *cell = (FOJourneyListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [FOJourneyListCell journeyListCell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	FOJourney* journey = [[sectionedList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[cell setJourney:journey];
    
    return cell;
}


+ (UIViewController*)controllerForJourney:(FOJourney*)journey;
{
    FOJourneyDetailController* detailController = [[FOJourneyDetailController alloc] initWithJourney:journey];
    if ([CWNetworkChecker isNetworkAvailable]) {
        FOMapViewController* mapController = [[FOMapViewController alloc] initWithJourney:journey];
        CWGroupedController* controller = [[CWGroupedController alloc] initWithViewControllers:[NSArray arrayWithObjects:detailController, mapController, nil]
                                                                                         title:[NSArray arrayWithObjects:NSLocalizedString(@"Details", nil), NSLocalizedString(@"Map", nil), nil]];
        [detailController release];
        [mapController release];
        controller.navigationItem.titleView = detailController.navigationItem.titleView;
        return [controller autorelease];
    } else {
        return [detailController autorelease];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    FOJourney* journey = [[sectionedList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UIViewController* controller = [FOJourneyListController controllerForJourney:journey];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end

