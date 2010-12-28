//
//  CWLineDetailCell.m
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

#import "FOLineDetailCell.h"
#import "NSDate+CWExtentions.h"
#import "UIColor+CWEditableColor.h"

@implementation FOLineDetailCell

-(void)localizeTextLabels;
{
    towardsTitleLabel.text = NSLocalizedString(@"TowardsTitle", nil);
}

+(FOLineDetailCell*)lineDetailCell;
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FOLineDetailCell" owner:self options:nil];
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
        return 64.f;
    } else {
		return 64.f + deviationsLabel.frame.size.height;
    }
}

-(void)setLine:(FOLine*)line;
{
    lineTypeImageView.image = [line typeImage];
    lineLabel.text = line.fullName;
    stopPointLabel.text = [NSString stringWithFormat:NSLocalizedString([line isTrain] ? @"Platform" : @"Position", nil), line.stopPoint];
	towardsLabel.text = line.towards;
	towardsTimeLabel.text = [line.departure localizedShortTimeString];
    towardsTimeLabel.textColor = [line.departure isEqualToDate:line.actualDeparture] ? [UIColor editableColor] : [UIColor warningTextColor];
    
    NSString* deviationsString = line.deviationsAsString;
    if (deviationsString) {
        deviationsLabel.text = [deviationsString stringByAppendingString:@"\n"];
        deviationsLabel.hidden = NO;
    } else {
        deviationsLabel.hidden = YES;
    }
    [self setNeedsLayout];
}


@end
