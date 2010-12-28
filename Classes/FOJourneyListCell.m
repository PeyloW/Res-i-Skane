//
//  CWJourneyListCell.m
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

#import "FOJourneyListCell.h"
#import "FOModel.h"
#import "NSDate+CWExtentions.h"
#import "UIColor+CWEditableColor.h"
#import "NSString+CWLocalizedFormats.h"

@implementation FOJourneyListCell

+(FOJourneyListCell*)journeyListCell;
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FOJourneyListCell" owner:self options:nil];
    for (id object in objects) {
        if ([object tag] == 1) {
			return object;
        }
    }
    return nil;
}

-(void)setJourney:(FOJourney*)journey;
{
    departureArrivalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FromToTime", nil), [journey.departure localizedShortTimeString], [journey.arrival localizedShortTimeString]];
	departureArrivalLabel.textColor = [journey isDeviated] ? [UIColor warningTextColor] : [UIColor darkTextColor];
    NSInteger travelTimeMin = (int)([journey.arrival timeIntervalSinceReferenceDate] - [journey.departure timeIntervalSinceReferenceDate]) / 60;
    travelTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TravelTime", nil), [NSString stringWithInteger:travelTimeMin]];
	FOLine* firstLine = [[journey.routeLinks objectAtIndex:0] line];
    lineTypeImageView.image = [firstLine typeImage];
    NSString* line = firstLine.fullName;
    BOOL hasTextDeviations = NO;
    for (FORouteLink* link in journey.routeLinks) {
        if ([link.deviations count] > 0) {
            hasTextDeviations = YES;
            break;
        }
    }
    deviationsImageView.image = hasTextDeviations ? [UIImage imageNamed:@"deviations.png"] : nil;
    if (journey.numberOfChanges > 0) {
		line = [NSString stringWithFormat:NSLocalizedString(@"LineWithChanges", nil), line, [NSString stringWithInteger:journey.numberOfChanges]];
    } else {
		line = [NSString stringWithFormat:NSLocalizedString(@"LineNoChanges", nil), line];
    }
    lineLabel.text = line;
    CGFloat oldWidth = travelTimeLabel.bounds.size.width;
    [travelTimeLabel sizeToFit];
    CGRect frame = travelTimeLabel.frame;
    CGFloat deltaSize = frame.size.width - oldWidth;
    frame.origin.x -= deltaSize;
    travelTimeLabel.frame = frame;
	frame = departureArrivalLabel.frame;
    frame.size.width -= deltaSize;
    departureArrivalLabel.frame = frame;
}

@end
