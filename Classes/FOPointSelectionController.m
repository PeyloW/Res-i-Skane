//
//  CWStopSelectionController.m
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

#import "FOPointSelectionController.h"
#import "CWNetworkChecker.h"
#import "UIColor+CWEditableColor.h"
#import "FOMapViewController.h"
#import "FOLineDetailController.h"
#import "CWGroupedController.h"

@interface FOPointSelectionController ()

@property(nonatomic, retain) NSArray* searchResultPoints;

@end


@implementation FOPointSelectionController

@synthesize pointType = _pointType;
@synthesize searchResultPoints = _searchResultPoints;
@synthesize searchOnly = searchOnly;

+(UIViewController*)controllerForPoint:(FOPoint*)point;
{
    FOMapViewController* mapController = [[FOMapViewController alloc] initWithPoint:point];
	if (point.type == FOPointTypeStopArea) {
        FOLineDetailController* lineController = [[FOLineDetailController alloc] initWithPoint:point];
        CWGroupedController* controller = [[CWGroupedController alloc] initWithViewControllers:[NSArray arrayWithObjects:lineController, mapController, nil]
                                                                                         title:[NSArray arrayWithObjects:NSLocalizedString(@"Departures", nil), NSLocalizedString(@"Map", nil), nil]];
        [lineController release];
        [mapController release];
        controller.title = point.title;
        return [controller autorelease];
    } else {
        return [mapController autorelease];
    }
}

-(id)initWithPointSelectionType:(FOPointSelectionType)pointType delegate:(id<FOPointSelectionControllerDelegate>)delegate;
{
    self = [self initWithNibName:@"FOPointSelectionController" bundle:nil];
	if (self) {
        _pointType = pointType;
        pointSelectionDelegate = delegate;
        sharedModel = [FOModel sharedModel];
    }
    return self;
}

-(void)viewDidLoad;
{
    self.title = NSLocalizedString(_pointType == FOPointSelectionTypeFrom ? @"From" : @"To", nil);
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
    [self.tableView reloadData];
}

-(void)dealloc;
{
    [_searchResultPoints release];
    [queue release];
	[super dealloc];
}

-(BOOL)tableView:(UITableView*)tableView canSelectPointAtIndex:(NSInteger)index;
{
    FOPoint* point;
	if (tableView != self.searchDisplayController.searchResultsTableView) {
        point = [sharedModel.knownPoints objectAtIndex:index];
    } else {
        point = [self.searchResultPoints objectAtIndex:index];
    }
    return ![point isEqual:self.pointType == FOPointSelectionTypeFrom ? sharedModel.to : sharedModel.from];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
	if (![CWNetworkChecker isNetworkAvailable]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoNetwork", nil) message:NSLocalizedString(@"NoNetworkStops", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
{
	if (queue == nil) {
		queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
    }
    [queue cancelAllOperations];
    NSOperation* op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performSearchWithString:) object:searchString];
    [queue addOperation:op];
    [op release];
    return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
{
	if (searchOnly) {
		[self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)performSearchWithString:(NSString*)searchString;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSArray* searchResults = [FOPoint pointsMatchingString:searchString];
    self.searchResultPoints = searchResults;
    [self.searchDisplayController.searchResultsTableView reloadData];
    [pool release];
}


#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        return [sharedModel.knownPoints count];
    } else {
        return [self.searchResultPoints count];
    }
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    FOPoint* point = nil;
	if (tableView != self.searchDisplayController.searchResultsTableView) {
		point = [sharedModel.knownPoints objectAtIndex:indexPath.row];
    } else {
        point = [self.searchResultPoints objectAtIndex:indexPath.row];
    }
    BOOL selected = NO;
    if ([self tableView:tableView canSelectPointAtIndex:indexPath.row]) {
        FOPoint* otherPoint = _pointType == FOPointSelectionTypeFrom ? sharedModel.from : sharedModel.to;
        if ([point isEqual:otherPoint]) {
            selected = YES;
            cell.textLabel.textColor = point.ID <= CWPointCurrentLocationID ? [UIColor blueColor] : [UIColor editableColor];
        } else {
            cell.textLabel.textColor = point.ID <= CWPointCurrentLocationID ? [UIColor editableColor] : [UIColor darkTextColor];
        }
    } else {
        cell.textLabel.textColor = [UIColor grayColor];
    }
    FOPointStatus pointStatus = [point pointStatus];
    if (pointStatus == FOPointStatusPending || pointStatus == FOPointStatusError || ![CWNetworkChecker isNetworkAvailable]) {
        cell.accessoryView = nil;
        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        if (selected) {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = (int)indexPath.row;
            [button addTarget:self action:@selector(didTapAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:@"selected_accessory.png"] forState:UIControlStateNormal];
            [button sizeToFit];
            cell.accessoryView = button;
        } else {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    
    cell.textLabel.text = point.title;
    cell.imageView.image = [point imageForType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    FOPoint* point;
    if (tableView != self.searchDisplayController.searchResultsTableView) {
		point = [sharedModel.knownPoints objectAtIndex:indexPath.row];
    } else {
        point = [self.searchResultPoints objectAtIndex:indexPath.row];
    }
    UIViewController* controller = [FOPointSelectionController controllerForPoint:point];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didTapAccessoryButton:(UIButton*)button;
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    if (self.searchDisplayController.active) {
        [self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    } else {
        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView != self.searchDisplayController.searchResultsTableView) {
		FOPoint* point = [sharedModel.knownPoints objectAtIndex:indexPath.row];
        [pointSelectionDelegate pointSelectionController:self didSelectPoint:point];
    } else {
        FOPoint* point = [self.searchResultPoints objectAtIndex:indexPath.row];
		NSInteger index = [sharedModel.knownPoints indexOfObject:point];
        if (index != NSNotFound) {
            point = [sharedModel.knownPoints objectAtIndex:index];
        } else {
            [sharedModel.knownPoints insertObject:point atIndex:1];
        }
        [pointSelectionDelegate pointSelectionController:self didSelectPoint:point];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return tableView != self.searchDisplayController.searchResultsTableView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (tableView != self.searchDisplayController.searchResultsTableView && indexPath.row > 0) {
		return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	[sharedModel.knownPoints removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return tableView != self.searchDisplayController.searchResultsTableView && indexPath.row > 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
{
	if (proposedDestinationIndexPath.row == 0) {
        return [NSIndexPath indexPathForRow:1 inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
{
	[sharedModel.knownPoints exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}


@end

