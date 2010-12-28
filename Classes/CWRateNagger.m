//
//  CWRateNagger.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-08-22.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import "CWRateNagger.h"


@implementation CWRateNagger

-(NSString*)currentVersionCountKey;
{
	return [NSString stringWithFormat:@"CWRateNagger-%@-Count", [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey]];    
}

-(NSString*)currentVersionRatedKey;
{
	return [NSString stringWithFormat:@"CWRateNagger-%@-Rated", [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey]];    
}

-(NSUInteger)launchCount;
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:[self currentVersionCountKey]];    
}

-(void)incrementLaunchCount;
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[self launchCount] + 1 forKey:[self currentVersionCountKey]];
    [defaults synchronize];
}

-(BOOL)isCurrentVersionRated;
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:[self currentVersionRatedKey]];
}

-(void)setCurrentVersionIsRated;
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:YES forKey:[self currentVersionRatedKey]];
    [defaults synchronize];
}

+(BOOL)askUserForRatingAfterNumberOfLaunches:(NSUInteger)launches applicationId:(NSString*)appId;
{
	CWRateNagger* nagger = [[[self alloc] initWithNumberOfLaunches:launches applicationId:appId] autorelease];
    return [nagger start];
}

-(id)initWithNumberOfLaunches:(NSUInteger)launches applicationId:(NSString*)appId;
{
    self = [self init];
    if (self) {
    	_appId = [appId copy];
        _launches = launches;
    }
    return self;
}

-(void)dealloc;
{
    [_appId release];
    [_title release];
    [_message release];
    [_accept release];
    [_decline release];
	[super dealloc];
}

-(void)setTitle:(NSString*)title;
{
	[_title autorelease];
    _title = [title copy];
}

-(void)setMessage:(NSString*)message;
{
	[_message autorelease];
    _message = [message copy];
}

-(void)setButtonTitleForAccept:(NSString*)accept decline:(NSString*)decline;
{
	[_accept autorelease];
    [_decline autorelease];
    _accept = [accept copy];
    _decline = [decline copy];
}

-(BOOL)shouldShowRateNagger;
{
    if (![self isCurrentVersionRated]) {
        NSUInteger launchCount = [self launchCount];
        while (launchCount > _launches) {
            _launches += _launches * 2;
        }
        return _launches == launchCount;
    }
    return NO;
}

-(BOOL)start;
{
    [self incrementLaunchCount];
	if ([self shouldShowRateNagger]) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* appName = [[bundle infoDictionary] objectForKey:@"CFBundleDisplayName"];
        appName = [[bundle localizedStringForKey:@"CFBundleDisplayName"
                                           value:appName 
                                           table:@"InfoPlist"] copy];
		if (_title == nil) {
        	_title = [[bundle localizedStringForKey:@"CWRateNagger-Title" 
                                                value:@"Write Review" 
                                                table:nil] copy];
            _title = [_title stringByReplacingOccurrencesOfString:@"%APP_NAME%" withString:appName];
    	}
		if (_message == nil) {
        	_message = [[bundle localizedStringForKey:@"CWRateNagger-Message" 
                                                value:@"Thank you for using %APP_NAME%. Would you like to write an application review now?"
                                                table:nil] copy];
            _message = [_message stringByReplacingOccurrencesOfString:@"%APP_NAME%" withString:appName];
        }
        if (_accept == nil) {
        	_accept = [[bundle localizedStringForKey:@"CWRateNagger-Accept" value:@"Write Review" table:nil] copy];
        }
        if (_decline == nil) {
        	_decline = [[bundle localizedStringForKey:@"CWRateNagger-Decline" value:@"Not Now" table:nil] copy];
        }
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:_title 
                                                        message:_message
                                                       delegate:self 
                                              cancelButtonTitle:_decline 
                                              otherButtonTitles:_accept, nil];
        [alert show];
        [self retain];
        return YES;
    }
    return NO;
}

-(void)alertViewCancel:(UIAlertView *)alertView;
{
	[self autorelease];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    [self autorelease];
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self setCurrentVersionIsRated];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", _appId]];
        [[UIApplication sharedApplication] openURL:url];
    }
    [alertView autorelease];
}

@end
