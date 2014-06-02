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
#import "MainViewController.h"

@interface CDViAd()

- (void) __prepare:(BOOL)atTop;
- (void) __showAd:(BOOL)show;
- (bool) __isLandscape;

@end


@implementation CDViAd

@synthesize bannerView;
@synthesize bannerIsVisible, bannerIsInitialized, bannerAtTop;

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
    if (adBannerViewClass && self.bannerView) {
        
        CGRect superViewFrame = self.webView.superview.frame;
        if([self __isLandscape]) {
            superViewFrame.size.width = self.webView.superview.frame.size.height;
            superViewFrame.size.height = self.webView.superview.frame.size.width;
        }
        
        CGRect adViewFrameNew = self.bannerView.frame;
        adViewFrameNew.size = [self.bannerView sizeThatFits:superViewFrame.size];
        self.bannerView.frame = adViewFrameNew;
        
        [self resizeViews];
    }
}

- (void) resizeViews
{
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && self.bannerView) {
        
        // If the ad is not showing or the ad is hidden, we don't want to resize anything.
        BOOL adIsShowing = [self.webView.superview.subviews containsObject:self.bannerView] &&
        (! self.bannerView.hidden);
        
        // Handle changing Smart Banner constants for the user.
        bool isLandscape = [self __isLandscape];
        
        // iOS7 Hack, handle the Statusbar
        MainViewController *mainView = (MainViewController*) self.webView.superview.window.rootViewController;
        BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7);
        CGFloat top = isIOS7 ? mainView.topLayoutGuide.length : 0.0;
        
        // Frame of the main container view that holds the Cordova webview.
        CGRect superViewFrame = self.webView.superview.frame;
        // Frame of the main Cordova webview.
        CGRect webViewFrame = self.webView.frame;
        CGRect bannerViewFrame = self.bannerView.frame;
        
        // Let's calculate the new position and size
        CGRect superViewFrameNew = superViewFrame;
        CGRect webViewFrameNew = webViewFrame;
        CGRect bannerViewFrameNew = bannerViewFrame;
        
        if( isLandscape ) {
            superViewFrameNew.size.width = superViewFrame.size.height;
            superViewFrameNew.size.height = superViewFrame.size.width;
        }
        
        if(adIsShowing) {
            if(self.bannerAtTop) {
                // move banner view to top
                bannerViewFrameNew.origin.y = top;
                // move the web view to below
                webViewFrameNew.origin.y = top + bannerViewFrame.size.height;
            } else {
                // move web view to top
                webViewFrameNew.origin.y = top;
                // move the banner view to below
                bannerViewFrameNew.origin.y = superViewFrameNew.size.height - bannerViewFrame.size.height;
            }
            
            webViewFrameNew.size.width = superViewFrameNew.size.width;
            webViewFrameNew.size.height = superViewFrameNew.size.height - bannerViewFrame.size.height - top;
            
            bannerViewFrameNew.origin.x = (superViewFrameNew.size.width - bannerViewFrameNew.size.width) * 0.5f;
            
            NSLog(@"webview: %d x %d, banner view: %d x %d",
                  (int) webViewFrameNew.size.width, (int) webViewFrameNew.size.height,
                  (int) bannerViewFrameNew.size.width, (int) bannerViewFrameNew.size.height );
            
            self.bannerView.frame = bannerViewFrameNew;
            
        } else {
            webViewFrameNew = superViewFrameNew;
            webViewFrameNew.origin.y += top;
            webViewFrameNew.size.height -= top;
            
            NSLog(@"webview: %d x %d",
                  (int) webViewFrameNew.size.width, (int) webViewFrameNew.size.height );
            
        }
        
        self.webView.frame = webViewFrameNew;
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) __prepare:(BOOL)atTop
{
	NSLog(@"CDViAd Prepare Ad, bannerAtTop: %d", atTop);
	
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && !self.bannerView) {
		self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        CGRect superViewFrame = self.webView.superview.frame;
        if([self __isLandscape]) {
            superViewFrame.size.width = self.webView.superview.frame.size.height;
            superViewFrame.size.height = self.webView.superview.frame.size.width;
        }
        
        CGRect adViewFrameNew = self.bannerView.frame;
        adViewFrameNew.size = [self.bannerView sizeThatFits:superViewFrame.size];
        self.bannerView.frame = adViewFrameNew;
        
        NSLog(@"x,y,w,h = %d,%d,%d,%d",
              (int) adViewFrameNew.origin.x, (int) adViewFrameNew.origin.y,
              (int) adViewFrameNew.size.width, (int) adViewFrameNew.size.height );
        
		self.bannerView.delegate = self;
        
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
	
	if (!(NSClassFromString(@"ADBannerView") && self.bannerView)) { // ad classes not available
		return;
	}
	
	if (show == self.bannerIsVisible) { // same state, nothing to do
        if( self.bannerIsVisible) {
            [self resizeViews];
        }
	} else if (show) {
		[[[super webView] superview] addSubview:self.bannerView];
		[[[super webView] superview] bringSubviewToFront:self.bannerView];
        [self resizeViews];
		
		self.bannerIsVisible = YES;
	} else {
		[self.bannerView removeFromSuperview];
        [self resizeViews];
		
		self.bannerIsVisible = NO;
	}
	
}

- (bool)__isLandscape {
    bool landscape = NO;
    
    //UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    //if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
    //    landscape = YES;
    //}
    // the above code cannot detect correctly if pad/phone lying flat, so we check the status bar orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            landscape = NO;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            landscape = YES;
            break;
        default:
            landscape = YES;
            break;
    }
    
    return landscape;
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
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.bannerView) {
        
        CGRect superViewFrame = self.webView.superview.frame;
        if([self __isLandscape]) {
            superViewFrame.size.width = self.webView.superview.frame.size.height;
            superViewFrame.size.height = self.webView.superview.frame.size.width;
        }
        
        CGRect adViewFrameNew = self.bannerView.frame;
        adViewFrameNew.size = [self.bannerView sizeThatFits:superViewFrame.size];
        self.bannerView.frame = adViewFrameNew;
        
        [self resizeViews];
    }
}

- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
	self.bannerView.delegate = nil;
	self.bannerView = nil;
}

@end
