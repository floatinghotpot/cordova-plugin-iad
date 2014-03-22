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


@interface CDViAd()

- (void) __prepare:(BOOL)atTop;
- (void) __showAd:(BOOL)show;

@end


@implementation CDViAd

@synthesize adView;
@synthesize bannerIsVisible, bannerIsInitialized, bannerAtTop, isLandscape;

#pragma mark -
#pragma mark Public Methods

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
  self = (CDViAd *)[super initWithWebView:theWebView];
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

- (void) createBannerView:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;

	NSUInteger argc = [arguments count];
	if (argc > 1) {
		return;
	}

	BOOL atTop = NO;
	NSString* atTopValue = [arguments objectAtIndex:0];
	if( atTopValue ) atTop = [atTopValue boolValue];
	[self __prepare:atTop];

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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.adView) {

		if( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) ) {
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
            if (self.bannerAtTop) {
                webViewFrame.origin.y = adViewFrame.size.height;
            } else {
                webViewFrame.origin.y = 0;
                CGRect adViewFrame = self.adView.frame;
                CGRect superViewFrame = [[super webView] superview].frame;
                adViewFrame.origin.y = (self.isLandscape ? superViewFrame.size.width : superViewFrame.size.height) - adViewFrame.size.height;
                self.adView.frame = adViewFrame;
            }

            webViewFrame.size.height = self.isLandscape? (superViewFrame.size.width - adViewFrame.size.height) : (superViewFrame.size.height - adViewFrame.size.height);
        } else {
            webViewFrame.size = self.isLandscape? CGSizeMake(superViewFrame.size.height, superViewFrame.size.width) : superViewFrame.size;
            webViewFrame.origin = CGPointZero;
        }

        //[UIView beginAnimations:@"blah" context:NULL];
        //[UIView setAnimationDuration:0.5];
        //[self.adView setAlpha:1.0];
        //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

        [super webView].frame = webViewFrame;

        //[UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) __prepare:(BOOL)atTop
{
	NSLog(@"CDViAd Prepare Ad, bannerAtTop: %d", atTop);
	
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && !self.adView) {
		self.adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		self.adView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];		

		UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
		if( UIInterfaceOrientationIsLandscape( currentOrientation ) ) {
			self.isLandscape = YES;
	        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		} else {
			self.isLandscape = NO;
	        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		}

		self.adView.delegate = self;
        self.adView.backgroundColor = [UIColor blackColor];
		//[self.webView.superview addSubview:self.adView];

        self.webView.superview.backgroundColor = [UIColor blackColor];
        
		self.bannerAtTop = atTop;
		self.bannerIsVisible = NO;
		self.bannerIsInitialized = YES;
        
        [self resizeViews];
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
		//[UIView beginAnimations:@"blah" context:NULL];
        //[UIView setAnimationDuration:0.5];
        //[self.adView setAlpha:1.0];
		//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

		[[[super webView] superview] addSubview:self.adView];
		[[[super webView] superview] bringSubviewToFront:self.adView];
        [self resizeViews];
		
		//[UIView commitAnimations];

		self.bannerIsVisible = YES;
	} else {
		//[UIView beginAnimations:@"blah" context:NULL];
        //[UIView setAnimationDuration:0.5];
        //[self.adView setAlpha:0.0];
        //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		[self.adView removeFromSuperview];
        [self resizeViews];
		
		//[UIView commitAnimations];
		
		self.bannerIsVisible = NO;
	}
	
}

#pragma mark -
#pragma ADBannerViewDelegate

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view begining action");

    [self writeJavascript:@"cordova.fireDocumentEvent('onClickAd');"];
    if (!willLeave) {
        
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"Banner view finished action");
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"Banner Ad loaded");
    
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass) {
		if (!self.bannerIsVisible) {
			[self __showAd:YES];
		}

		[self writeJavascript:@"cordova.fireDocumentEvent('onReceiveAd');"];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError*)error
{
    NSLog(@"Banner failed to load Ad");

	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass) {
		//if ( self.bannerIsVisible ) {
		//	[self __showAd:NO];
		//}

		NSString *jsString =
			@"cordova.fireDocumentEvent('onFailedToReceiveAd',"
			@"{ 'error': '%@' });";
		[self writeJavascript:[NSString stringWithFormat:jsString, [error description]]];
    }
}

- (void)deviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.adView) {

        if( UIInterfaceOrientationIsLandscape( currentOrientation ) ) {
            self.isLandscape = YES;
            self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        } else {
            self.isLandscape = NO;
            self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        }

        [self resizeViews];
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
