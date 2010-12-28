//
//  CWGroupedController.m
//  SharedComponents
//
//  Copyright 2008-2010 Jayway. All rights reserved.
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

#import "CWGroupedController.h"


@implementation CWGroupedController

-(NSUInteger)selectedIndex;
{
	return segmentedControl.selectedSegmentIndex;
}

-(void)setSelectedIndex:(NSUInteger)index;
{
	segmentedControl.selectedSegmentIndex = index;
}

-(id)initWithViewControllers:(NSArray*)controllers title:(NSArray*)titles;
{
    self = [super init];
    if (self) {
		viewControllers = [controllers retain];
		segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segmentedControl addTarget:self action:@selector(selectController:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

-(void)selectController:(id)sender;
{
    if ([self.view.subviews count] > 1) {
        [[self.view.subviews objectAtIndex:1] removeFromSuperview];
    }
    UIView* contentView = [[viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex] view];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	CGRect frame = self.view.bounds;
    contentView.frame = frame;
    [self.view addSubview:contentView];
}

- (void)loadView;
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    view.autoresizesSubviews = YES;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem* segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    segmentedItem.width = 320 - 92;
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, segmentedItem, flexItem, nil];
    [flexItem release];
    [segmentedItem release];
    self.view = view;
    [view release];
    if (segmentedControl.selectedSegmentIndex == -1) {
        segmentedControl.selectedSegmentIndex = 0;
    } else {
        [self selectController:segmentedControl];
    }
}


- (void)dealloc {
	[viewControllers release];
    [segmentedControl release];
    [super dealloc];
}


@end
