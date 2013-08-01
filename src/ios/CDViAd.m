//
//  CDViAd.m
//  Ad Plugin for PhoneGap
//
//  Created by shazron on 10-07-12.
//  Copyright 2010 Shazron Abdullah. All rights reserved.
//  Cordova v1.5.0 Support added 2012 @RandyMcMillan
//	Cordova v3.0.0 Support added 2013 @LimingXie

#import "CDViAd.h"
#import <Cordova/CDVDebug.h>


@interface CDViAd(PrivateMethods)

- (void) __prepare:(BOOL)atBottom;
- (void) __showAd:(BOOL)show;

@end


@implementation CDViAd

@synthesize adView;
@synthesize bannerIsVisible, bannerIsInitialized, bannerIsAtBottom, isLandscape;

#pragma mark -
#pragma mark Public Methods

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
  self = (CDVAdMob *)[super initWithWebView:theWebView];
  if (self) {
    // These notifications are required for re-placing the ad on orientation
    // changes. Start listening for notifications here since we need to
    // translate the Smart Banner constants according to the orientation.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(deviceOrientationChange:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
  }
  return self;
}

- (void) prepare:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;

	NSUInteger argc = [arguments count];
	if (argc > 1) {
		return;
	}

	BOOL atBottom = NO;
	NSString* atBottomValue = [arguments objectAtIndex:0];
	if( atBottomValue ) atBottom = [atBottomValue boolValue];
	[self __prepare:atBottom];

	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) showAd:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;

	NSUInteger argc = [arguments count];
	if (argc > 1) {
		return;
	}

	BOOL show = YES;
	NSString* showValue = [arguments objectAtIndex:0];
	if( showValue ) show = [showValue boolValue];
	[self __showAd:show];

	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)deviceOrientationChange:(NSNotification *)notification {

    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.adView) {

		UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];

		if( UIInterfaceOrientationIsLandscape( currentOrientation ) ) {
			self.isLandscape = YES;
			self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		} else {
			self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		}

		[self resizeViews];
    }
}

- (void) resizeViews
{
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && self.adView) {

        CGRect webViewFrame = [super webView].frame;
        CGRect superViewFrame = [[super webView] superview].frame;
        CGRect adViewFrame = self.adView.frame;

        BOOL adIsShowing = [[[super webView] superview].subviews containsObject:self.adView];
        if (adIsShowing) {
            if (self.bannerIsAtBottom) {
                webViewFrame.origin.y = 0;
                CGRect adViewFrame = self.adView.frame;
                CGRect superViewFrame = [[super webView] superview].frame;
                adViewFrame.origin.y = (self.isLandscape ? superViewFrame.size.width : superViewFrame.size.height) - adViewFrame.size.height;
                self.adView.frame = adViewFrame;
            } else {
                webViewFrame.origin.y = adViewFrame.size.height;
            }

            webViewFrame.size.height = self.isLandscape? (superViewFrame.size.width - adViewFrame.size.height) : (superViewFrame.size.height - adViewFrame.size.height);
        } else {
            webViewFrame.size = self.isLandscape? CGSizeMake(superViewFrame.size.height, superViewFrame.size.width) : superViewFrame.size;
            webViewFrame.origin = CGPointZero;
        }

        [UIView beginAnimations:@"blah" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

        [super webView].frame = webViewFrame;

        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) __prepare:(BOOL)atBottom
{
	NSLog(@"CDViAd Prepare Ad At Bottom: %d", atBottom);
	
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && !self.adView) {
		self.adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        // we are still using these constants even though they are deprecated - if it is changed, iOS 4 devices < 4.3 will crash.
        // will need to do a run-time iOS version check	
		self.adView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];		

		self.adView.delegate = self;
        
        NSString* contentSizeId = (self.isLandscape ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait);

        self.adView.currentContentSizeIdentifier = contentSizeId;
		
		if (atBottom) {
			self.bannerIsAtBottom = YES;
		}
        
		self.bannerIsVisible = NO;
		self.bannerIsInitialized = YES;
	}
}

- (void) __showAd:(BOOL)show
{
	NSLog(@"CDViAd Show Ad: %d", show);
	
	if (!self.bannerIsInitialized){
		[self __prepare:NO];
	}
	
	if (!(NSClassFromString(@"ADBannerView") && self.adView)) { // ad classes not available
		return;
	}
	
	if (show == self.bannerIsVisible) { // same state, nothing to do
		return;
	}
	
	if (show) {
		[UIView beginAnimations:@"blah" context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

		[[[super webView] superview] addSubview:self.adView];
		[[[super webView] superview] bringSubviewToFront:self.adView];
        [self resizeViews];
		
		[UIView commitAnimations];

		self.bannerIsVisible = YES;
	} else {
		[UIView beginAnimations:@"blah" context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		[self.adView removeFromSuperview];
        [self resizeViews];
		
		[UIView commitAnimations];
		
		self.bannerIsVisible = NO;
	}
	
}

#pragma mark -
#pragma ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass) {
		[super writeJavascript:@"(function(){"
		"var e = document.createEvent('Events');"
		"e.initEvent('iAdBannerView.LoadAd');"
		"document.dispatchEvent(e);"
		"})();"];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError*)error
{
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass) {
		NSString* jsString = 
		@"(function(){"
		"var e = document.createEvent('Events');"
		"e.initEvent('iAdBannerView.FailLoadAd');"
		"e.error = '%@';"
		"document.dispatchEvent(e);"
		"})();";
		
		[super writeJavascript:[NSString stringWithFormat:jsString, [error description]]];
    }
}

- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter]
		removeObserver:self
		name:UIDeviceOrientationDidChangeNotification
		object:nil];

	self.adView.delegate = nil;
	self.adView = nil;
}

@end
