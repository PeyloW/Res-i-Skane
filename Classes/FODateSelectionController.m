//
//  CWDateSelectionController.m
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

#import "FODateSelectionController.h"
#import "UIColor+CWEditableColor.h"
#import "NSDate+CWExtentions.h"

@implementation FODateSelectionController

-(UITableView*)tableView;
{
	return realTableView;
}

-(void)loadView;
{
	[[NSBundle mainBundle] loadNibNamed:@"FODateSelectionController" owner:self options:nil];
}

-(void)viewDidLoad;
{
	datePicker.locale = [NSLocale currentLocale];
    [datePicker setDate:sharedModel.date animated:NO];
}

-(id)initWithDelegate:(id<FODateSelectionControllerDelegate>)delegate;
{
	self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
		dateSelectionDelegate = delegate;
        sharedModel = [FOModel sharedModel];
        self.title = NSLocalizedString(@"TravelTimeTitle", nil);
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
	return 2;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	switch(section) {
        case 0:
            return 2;
        default:
            return 5;
    }
}

-(void)setupDirectionCell:(UITableViewCell*)cell forRow:(NSInteger)row;
{
	cell.textLabel.text = NSLocalizedString(row == 0 ? @"Departure" : @"Arrival", nil);
    if (sharedModel.direction == row) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor editableColor];
    } else {
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
}

-(void)setupDateCell:(UITableViewCell*)cell forRow:(NSInteger)row;
{
    BOOL isRelative = [sharedModel.date isRelativeDate];
    BOOL isSelected = NO;
    NSTimeInterval sinceNow = [sharedModel.date timeIntervalSinceNow];
	switch (row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Now", nil);
            isSelected = isRelative && sinceNow == 0;
            break;
        case 1:
			cell.textLabel.text = NSLocalizedString(@"QuarterHour", nil);
            isSelected = isRelative && sinceNow == 15 * 60;
            break;
        case 2:
			cell.textLabel.text = NSLocalizedString(@"HalfHour", nil);
            isSelected = isRelative && sinceNow == 30 * 60;
            break;
        case 3:
			cell.textLabel.text = NSLocalizedString(@"Hour", nil);
            isSelected = isRelative && sinceNow == 60 * 60;
            break;
        default:
            cell.textLabel.text = isRelative ? NSLocalizedString(@"OtherDate", nil) : [sharedModel.date localizedShortString];
            isSelected = !isRelative;
            break;
    }
    if (isSelected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor editableColor];
    } else {
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString* cellId = @"cellId";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    if (indexPath.section == 0) {
		[self setupDirectionCell:cell forRow:indexPath.row];
    } else {
        [self setupDateCell:cell forRow:indexPath.row];
    }
    return cell;
}

-(IBAction)cancelCustomDate:(id)sender;
{
    [UIView beginAnimations:@"customDatePickerOut" context:nil];
	translucentBackgroundView.alpha = 0.0f;
    CGRect frame = pickerBackgroundView.frame;
	frame.origin.y += frame.size.height;
	pickerBackgroundView.frame = frame;
    [UIView commitAnimations];
}

-(IBAction)selectCustomDate:(id)sender;
{
    [self cancelCustomDate:self];
	[dateSelectionDelegate dateSelectionController:self didSelectDate:datePicker.date];
}

-(void)showCustomDatePicker;
{
    [UIView beginAnimations:@"customDatePickerIn" context:nil];
    titleItem.title = NSLocalizedString(sharedModel.direction == FOJourneyDirectionArrival ? @"ArriveAt" : @"DepartAt", nil);
	translucentBackgroundView.alpha = 1.0f;
    CGRect frame = pickerBackgroundView.frame;
	frame.origin.y -= frame.size.height;
	pickerBackgroundView.frame = frame;
    [UIView commitAnimations];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [dateSelectionDelegate dateSelectionController:self didSelectDirection:indexPath.row];
		for (int row = 0; row < 2; row++) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            [self setupDirectionCell:cell forRow:row];
        }
    } else if (indexPath.row < 4) {
		NSDate* date = [NSDate relativeDateWithTimeIntervalSinceNow:(int[]){0,15,30,60}[indexPath.row] * 60];
        [dateSelectionDelegate dateSelectionController:self didSelectDate:date];
		for (int row = 0; row < 5; row++) {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
            [self setupDateCell:cell forRow:row];
        }
    } else {
        [self showCustomDatePicker];
    }
}

@end
