//
//  CWBookmarksController.m
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

#import "FOBookmarksController.h"


@implementation FOBookmarksController


-(id)initWithDelegate:(id<FOBookmarksDelegate>)delegate;
{
	self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        bookmarksDelegate = delegate;
        sharedModel = [FOModel sharedModel];
        self.title = NSLocalizedString(@"Bookmarks", nil);
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBookmarkSelection:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
		self.navigationItem.rightBarButtonItem = [self editButtonItem];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:self];
        [self release];
        return controller;
    }
	return nil;
}

-(void)viewDidLoad;
{
 	self.tableView.rowHeight = 60;
    if (![sharedModel.bookmarkedJourneys count]) {
        CGRect frame = self.tableView.bounds;
        frame.origin.y = 120;
        frame.size.height = 60;
		UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = NSLocalizedString(@"NoBookmarks", nil);
        [self.tableView addSubview:titleLabel];
        [titleLabel release];
    }
}

-(void)cancelBookmarkSelection:(id)sender;
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [sharedModel.bookmarkedJourneys count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSArray* bookmark = [sharedModel.bookmarkedJourneys objectAtIndex:indexPath.row];
    FOPoint* pointA = [bookmark objectAtIndex:0];
    FOPoint* pointB = [bookmark objectAtIndex:1];
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PointAPointB", nil), pointA.title, pointB.title];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSArray* bookmark = [sharedModel.bookmarkedJourneys objectAtIndex:indexPath.row];
    [bookmarksDelegate bookmarksController:self didSelectBookmark:bookmark];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[sharedModel.bookmarkedJourneys removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[sharedModel.bookmarkedJourneys exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}


@end

