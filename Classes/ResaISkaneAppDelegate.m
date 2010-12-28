//
//  ResaISkaneAppDelegate.m
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

#import "ResaISkaneAppDelegate.h"
#import "FOModel.h"
#import "FOPoint.h"
#import "FOJourney.h"
#import "FOJourneySearchController.h"
#import "FOJourneyListController.h"
#import "CWNetworkChecker.h"
#import "CWTranslatedString.h"
#import "CWRateNagger.h"

#define APP_ID (@"305963116")

@implementation ResaISkaneAppDelegate

@synthesize window, mainViewController;

-(void)displayInformationIfNeeded;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if ([CWNetworkChecker isNetworkAvailable]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		NSArray* infoItems = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"InfoURL"]]];
        for (NSDictionary* infoItem in infoItems) {
			NSString* itemId = [infoItem objectForKey:@"id"];
            if ([defaults boolForKey:itemId] == NO) {
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:CWTranslatedString([infoItem objectForKey:@"title"], @"sv")
                                                                message:CWTranslatedString([infoItem objectForKey:@"message"], @"sv")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                [alert release];
                [defaults setBool:YES forKey:itemId];
            }
        }
        [defaults synchronize];
    }
    [pool release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	[CWNetworkChecker setDefaultHost:[[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"ServerURL"]] host]];

    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
    
    if ([FOModel sharedModel].currentJourneyList != nil) {
        UIViewController* controller = [[FOJourneyListController alloc] init];
        [mainViewController presentModalViewController:controller animated:NO];
        [controller release];
    }
    if ([UIDevice isPhone]) {
        UIImage* backImage = [UIImage imageNamed:@"Default.png"];
        UIView* backView = [[UIImageView alloc] initWithImage:backImage];
        backView.frame = window.bounds;
        [window addSubview:backView];
        [UIView beginAnimations:@"FOFadeIn" context:(void*)backView];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:
         @selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.5f];
        backView.alpha = 0;
        [UIView commitAnimations];
    }
    [self performSelectorInBackground:@selector(displayInformationIfNeeded) withObject:nil];
}

-(void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    UIView* backView = (UIView*)context;
    [backView removeFromSuperview];
    [backView release];
    [CWRateNagger askUserForRatingAfterNumberOfLaunches:5 applicationId:APP_ID];
}

static BOOL cw_didEnterForground = NO;

-(void)applicationDidBecomeActive:(UIApplication *)application;
{
	if (cw_didEnterForground) {
        cw_didEnterForground = NO;
        [CWRateNagger askUserForRatingAfterNumberOfLaunches:5 applicationId:APP_ID];
    }
}

-(void)applicationWillEnterForeground:(UIApplication *)application;
{
	cw_didEnterForground = YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application;
{
	[[FOModel sharedModel] persistToStorage];
}

-(void)applicationWillTerminate:(UIApplication *)application;
{
	[[FOModel sharedModel] persistToStorage];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
