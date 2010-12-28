//
//  CWJourneyDetailCell.m
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

#import "FOJourneyDetailCell.h"
#import "NSDate+CWExtentions.h"
#import "UIColor+CWEditableColor.h"

@implementation FOJourneyDetailCell

-(void)localizeTextLabels;
{
    fromTitleLabel.text = NSLocalizedString(@"FromTitle", nil);
    toTitleLabel.text = NSLocalizedString(@"ToTitle", nil);
    [fromTitleLabel sizeToFit];
    [toTitleLabel sizeToFit];
    CGFloat maxTitleWidth = MAX(fromTitleLabel.bounds.size.width, toTitleLabel.bounds.size.width);
    CGRect bounds = fromTitleLabel.bounds;
    bounds.size.width = maxTitleWidth;
    fromTitleLabel.bounds = bounds;
    bounds = toTitleLabel.bounds;
    bounds.size.width = maxTitleWidth;
    toTitleLabel.bounds = bounds;
    towardsTitleLabel.text = NSLocalizedString(@"TowardsTitle", nil);
}

+(FOJourneyDetailCell*)journeyDetailCell;
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FOJourneyDetailCell" owner:self options:nil];
    for (id object in objects) {
        if ([object tag] == 1) {
			[object localizeTextLabels];
			return object;
        }
    }
    return nil;
}


-(CGFloat)rowHeight;
{
	if (deviationsLabel.hidden) {
        return 108.f;
    } else {
		return 108.f + deviationsLabel.frame.size.height;
    }
}

-(void)setRouteLink:(FORouteLink*)routeLink;
{
    lineTypeImageView.image = [routeLink.line typeImage];
    NSString* line = routeLink.line.fullName;
    lineLabel.text = line;
    stopPointLabel.text = [NSString stringWithFormat:NSLocalizedString([routeLink.line isTrain] ? @"Platform" : @"Position", nil), routeLink.from.stopPoint];
	fromLabel.text = routeLink.from.title;
    fromLabel.textColor = routeLink.from.ID <= CWPointCurrentLocationID ? [UIColor blueColor] : towardsLabel.textColor;
    toLabel.text = routeLink.to.title;
    toLabel.textColor = routeLink.to.ID <= CWPointCurrentLocationID ? [UIColor blueColor] : towardsLabel.textColor;
	fromTimeLabel.text = [routeLink.departure localizedShortTimeString];
    fromTimeLabel.textColor = [routeLink.departure isEqualToDate:routeLink.actualDeparture] ? [UIColor editableColor] : [UIColor warningTextColor];
	toTimeLabel.text = [routeLink.arrival localizedShortTimeString];
    toTimeLabel.textColor = [routeLink.arrival isEqualToDate:routeLink.actualArrival] ? [UIColor editableColor] : [UIColor warningTextColor];
	towardsLabel.text = routeLink.line.towards;
    NSString* deviationsString = routeLink.deviationsAsString;
    if (deviationsString) {
        deviationsLabel.text = [deviationsString stringByAppendingString:@"\n"];
        deviationsLabel.hidden = NO;
    } else {
        deviationsLabel.hidden = YES;
    }
    [self setNeedsLayout];
}


@end
