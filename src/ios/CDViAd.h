//
//  CDViAd.h
//  iAd Plugin for PhoneGap/Cordova
//
//  Created by shazron on 10-07-12.
//  Copyright 2010 Shazron Abdullah. All rights reserved.
//  Cordova v1.5.0 Support added 2012 @RandyMcMillan
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import <Cordova/CDVPlugin.h>
#import "CDViAd.h"

@interface CDViAd : CDVPlugin <ADBannerViewDelegate> {
	ADBannerView* adView;
	BOOL bannerIsVisible;
	BOOL bannerIsInitialized;

	// Value set by the javascript to indicate whether the ad is to be positioned
	// at the top or bottom of the screen.
	BOOL bannerAtTop;
}

@property (nonatomic, retain) ADBannerView* adView;
@property (assign) BOOL bannerIsVisible;
@property (assign) BOOL bannerIsInitialized;
@property (assign) BOOL bannerAtTop;
@property (assign) BOOL isLandscape;

- (void) createBannerView:(CDVInvokedUrlCommand *)command
- (void) showAd:(CDVInvokedUrlCommand *)command

@end
