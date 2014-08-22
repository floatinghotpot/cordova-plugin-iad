//
//  CDViAd.m
//  Ad Plugin for PhoneGap
//
//  Created by shazron on 10-07-12.
//  Copyright 2010 Shazron Abdullah. All rights reserved.
//  Cordova v1.5.0 Support added 2012 @RandyMcMillan
//	Cordova v3.0.0 Support added 2013 @LimingXie

#import "CDViAd.h"

@interface CDViAd()

- (void) __prepare:(BOOL)atTop overlap:(BOOL)isOverlap offsetTopBar:(BOOL)isOffset;
- (void) __showAd:(BOOL)show;

@end


@implementation CDViAd

@synthesize bannerView;
@synthesize bannerIsVisible, bannerIsInitialized, bannerAtTop, bannerOverlap, offsetTopBar;

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
	if (argc >= 2) {
        NSString* atTopValue = [arguments objectAtIndex:0];
        BOOL atTop = atTopValue ? [atTopValue boolValue] : NO;
        
        NSString* overlapValue = [arguments objectAtIndex:1];
        BOOL isOverlap = overlapValue ? [overlapValue boolValue] : NO;
        
        NSString* offsetValue = [arguments objectAtIndex:2];
        BOOL isOffset = offsetValue ? [offsetValue boolValue] : NO;
        
        [self __prepare:atTop overlap:isOverlap offsetTopBar:isOffset];
        
        // set background color to black
        //self.webView.superview.backgroundColor = [UIColor blackColor];
        //self.webView.superview.tintColor = [UIColor whiteColor];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) showAd:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;

	NSUInteger argc = [arguments count];
	if (argc >= 1) {
        NSString* showValue = [arguments objectAtIndex:0];
        BOOL show = showValue ? [showValue boolValue] : YES;
        [self __showAd:show];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.bannerView) {
        
        CGRect bf = self.bannerView.frame;
        bf.size = [self.bannerView sizeThatFits:self.webView.superview.bounds.size];
        self.bannerView.frame = bf;
        
        [self resizeViews];
    }
}

- (void) resizeViews
{
    // Frame of the main container view that holds the Cordova webview.
    CGRect pr = self.webView.superview.bounds, wf = pr;
    //NSLog(@"super view: %d x %d", (int)pr.size.width, (int)pr.size.height);
    
    // iOS7 Hack, handle the Statusbar
    BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7);
    CGRect sf = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat top = isIOS7 ? MIN(sf.size.height, sf.size.width) : 0.0;
    
    if(! self.offsetTopBar) top = 0.0;
    
    wf.origin.y = top;
    wf.size.height = pr.size.height - top;
    
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && self.bannerView) {
        CGRect bf = bannerView.frame;
        
        // If the ad is not showing or the ad is hidden, we don't want to resize anything.
        UIView* parentView = self.bannerOverlap ? self.webView : [self.webView superview];
        BOOL adIsShowing = ([self.bannerView isDescendantOfView:parentView]) && (! self.bannerView.hidden);
        
        if( adIsShowing ) {
            NSLog( @"banner visible" );
            if( bannerAtTop ) {
                if(bannerOverlap) {
                    wf.origin.y = top;
                    bf.origin.y = 0;
                } else {
                    bf.origin.y = top;
                    wf.origin.y = bf.origin.y + bf.size.height;
                }
                wf.size.height = pr.size.height - wf.origin.y;
                
            } else {
                // move webview to top
                wf.origin.y = top;
                
                if( bannerOverlap ) {
                    bf.origin.y = wf.size.height - bf.size.height;
                } else {
                    bf.origin.y = pr.size.height - bf.size.height;
                    wf.size.height = bf.origin.y;
                }
            }
            
            bf.origin.x = (pr.size.width - bf.size.width) * 0.5f;
            
            self.bannerView.frame = bf;
            
            //NSLog(@"x,y,w,h = %d,%d,%d,%d", (int) bf.origin.x, (int) bf.origin.y, (int) bf.size.width, (int) bf.size.height );
        }
    }
    
    self.webView.frame = wf;

    //NSLog(@"superview: %d x %d, webview: %d x %d", (int) pr.size.width, (int) pr.size.height, (int) wf.size.width, (int) wf.size.height );
}

#pragma mark -
#pragma mark Private Methods

- (void) __prepare:(BOOL)atTop overlap:(BOOL)isOverlap offsetTopBar:(BOOL)isOffset
{
	NSLog(@"CDViAd Prepare Ad, bannerAtTop: %d", atTop);
	
	Class adBannerViewClass = NSClassFromString(@"ADBannerView");
	if (adBannerViewClass && !self.bannerView) {
		self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        CGRect bf = self.bannerView.frame;
        bf.size = [self.bannerView sizeThatFits:self.webView.superview.bounds.size];
        self.bannerView.frame = bf;
        
		self.bannerView.delegate = self;
        
		self.bannerAtTop = atTop;
        self.bannerOverlap = isOverlap;
        self.offsetTopBar = isOffset;
		self.bannerIsInitialized = YES;
		self.bannerIsVisible = NO;
        
        [self resizeViews];
	}
}

- (void) __showAd:(BOOL)show
{
	NSLog(@"CDViAd Show Ad: %d", show);
	
	if (!self.bannerIsInitialized){
		[self __prepare:NO overlap:NO offsetTopBar:NO];
	}
	
	if (!(NSClassFromString(@"ADBannerView") && self.bannerView)) { // ad classes not available
		return;
	}
	
	if (show == self.bannerIsVisible) { // same state, nothing to do
        if( self.bannerIsVisible) {
            [self resizeViews];
        }
	} else if (show) {
        UIView* parentView = bannerOverlap ? self.webView : self.webView.superview;
        [parentView addSubview:self.bannerView];
        [parentView bringSubviewToFront:self.bannerView];
        [self resizeViews];
		
		self.bannerIsVisible = YES;
	} else {
		[self.bannerView removeFromSuperview];
        [self resizeViews];
		
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
		if ( self.bannerIsVisible ) {
			[self __showAd:NO];
		}

		NSString *jsString =
			@"cordova.fireDocumentEvent('onFailedToReceiveAd',"
			@"{ 'error': '%@' });";
		[self writeJavascript:[NSString stringWithFormat:jsString, [error description]]];
    }
}

- (void)deviceOrientationChange:(NSNotification *)notification
{
    Class adBannerViewClass = NSClassFromString(@"ADBannerView");
    if (adBannerViewClass && self.bannerView) {

        CGRect bf = self.bannerView.frame;
        bf.size = [self.bannerView sizeThatFits:self.webView.superview.bounds.size];
        self.bannerView.frame = bf;

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
