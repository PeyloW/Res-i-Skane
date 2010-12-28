//
//  CWLineDetailController.m
//  ResaISkane
//
//  Copyright 2010 Fredrik Olsson. All rights reserved.
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

#import "FOLineDetailController.h"
#import "FOLineDetailCell.h"
#import "NSDate+CWExtentions.h"

@implementation FOLineDetailController

-(UITableView*)tableView;
{
	return realTableView;
}

-(id)initWithPoint:(FOPoint*)aPoint;
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        sharedModel = [FOModel sharedModel];
        point = [aPoint retain];
        self.title = point.title;
    }
    return self;
}

-(void)dealloc;
{
    sharedModel.currentLineList = nil;
	[point release];
    [super dealloc];
}

-(void)loadView;
{
	[[NSBundle mainBundle] loadNibNamed:@"FOLineDetailController" owner:self options:nil];
    searchBar.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"All", nil),
                                   NSLocalizedString(@"Busses", nil),
                                   NSLocalizedString(@"Trains", nil), nil];
    searchBar.selectedScopeButtonIndex = sharedModel.lineTypeFilter;
    loadingLabel.text = NSLocalizedString(@"LoadingDepartures", nil);
	self.tableView.allowsSelection = NO;
	[self performSelectorInBackground:@selector(reloadLines) withObject:nil];
}


-(void)reloadLines;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSArray* lines = [FOLine linesFromPoint:point at:[NSDate date]];
    if (lines == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([sectionedList count] > 0) {
            [self performSelectorOnMainThread:@selector(deleteSections) withObject:nil waitUntilDone:YES];
        }
        sharedModel.currentLineList = lines;
        [self performSelectorOnMainThread:@selector(splitLinesIntoSections) withObject:nil waitUntilDone:NO];
	}
    [pool release];
}

-(void)deleteSections;
{
    NSIndexSet* sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [sectionedList count])];
	[sectionedList release];
    sectionedList = nil;
    [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationTop];
    if (!loadingView.hidden) {
        CGRect frame = loadingView.frame;
        frame.origin.y -= 60;
        [UIView beginAnimations:@"RemoveLoading" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        loadingView.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    loadingView.hidden = YES;
}

-(void)splitLinesIntoSections;
{
    [self deleteSections];
    sectionedList = [NSMutableArray new];
	NSMutableArray* currentSection = nil;
    NSString* dateString = nil;
    for (FOLine* line in sharedModel.currentLineList) {
        switch (sharedModel.lineTypeFilter) {
            case FOLineTypeFilterBuses:
                if (![line isBus]) {
                    continue;
                }
                break;
            case FOLineTypeFilterTraines:
                if (![line isTrain]) {
                    continue;
                }
                break;
        }
		NSString* newDateString = [line.departure localizedShortDateString];
        if (![newDateString isEqualToString:dateString]) {
            currentSection = [NSMutableArray array];
            [sectionedList addObject:currentSection];
        }
        [currentSection addObject:line];
        dateString = newDateString;
    }
	[self.tableView reloadData];
}


-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope;
{
    sharedModel.lineTypeFilter = selectedScope;
    [self splitLinesIntoSections];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [sectionedList count] + 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (sectionedList != nil && section > 0) {
		return [[[[sectionedList objectAtIndex:section - 1] objectAtIndex:0] departure] localizedShortDateString];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section > 0) {
        return [[sectionedList objectAtIndex:section - 1] count];
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	FOLine* line = [[sectionedList objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
    NSString* deviationsString = line.deviationsAsString;
    if (deviationsString) {
        CGSize size = CGSizeMake(self.tableView.bounds.size.width - 22, 400);
        size = [deviationsString sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
 		return 66.f + size.height;
    } else {
        return 66.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    FOLineDetailCell *cell = (FOLineDetailCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [FOLineDetailCell lineDetailCell];
        NSLog(@"Created: %@", cell.reuseIdentifier);
    } else {
        NSLog(@"Reused: %@", cell.reuseIdentifier);
    }
    
	FOLine* line = [[sectionedList objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
	[cell setLine:line];
    
    return cell;
}

@end

