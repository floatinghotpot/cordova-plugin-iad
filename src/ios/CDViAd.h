//
//  SAiOSAdPlugin.h
//  ADPlugin for PhoneGap/Cordova
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
	BOOL bannerIsAtBottom;
}

@property (nonatomic, retain)	ADBannerView* adView;
@property (assign)				BOOL bannerIsVisible;
@property (assign)				BOOL bannerIsInitialized;
@property (assign)				BOOL bannerIsAtBottom;
@property (assign)				BOOL isLandscape;


- (void) prepare:(CDVInvokedUrlCommand *)command
- (void) showAd:(CDVInvokedUrlCommand *)command
- (void) orientationChanged:(CDVInvokedUrlCommand *)command

@end
