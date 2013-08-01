//
//  CDViAd.h
//  iAd Plugin for PhoneGap/Cordova
//
//  Created by shazron on 10-07-12.
//  Copyright 2010 Shazron Abdullah. All rights reserved.
//  Cordova v1.5.0 Support added 2012 @RandyMcMillan
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <iAd/iAd.h>

@interface CDViAd : CDVPlugin <ADBannerViewDelegate> {

}

@property (nonatomic, retain) ADBannerView* adView;
@property (assign) BOOL bannerIsVisible;
@property (assign) BOOL bannerIsInitialized;
@property (assign) BOOL bannerAtTop;
@property (assign) BOOL isLandscape;

- (void) createBannerView:(CDVInvokedUrlCommand *)command;
- (void) showAd:(CDVInvokedUrlCommand *)command;

@end
