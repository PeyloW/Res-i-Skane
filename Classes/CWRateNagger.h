//
//  CWRateNagger.h
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-08-22.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CWRateNagger : NSObject <UIAlertViewDelegate> {
@private
    NSString* _appId;
    NSUInteger _launches;
    NSString* _title;
    NSString* _message;
    NSString* _accept;
    NSString* _decline;
}

+(BOOL)askUserForRatingAfterNumberOfLaunches:(NSUInteger)launches applicationId:(NSString*)appId;

-(id)initWithNumberOfLaunches:(NSUInteger)launches applicationId:(NSString*)appId;

-(NSUInteger)launchCount;
-(BOOL)isCurrentVersionRated;

-(void)setTitle:(NSString*)title;
-(void)setMessage:(NSString*)message;
-(void)setButtonTitleForAccept:(NSString*)accept decline:(NSString*)decline;

-(BOOL)start;

@end
