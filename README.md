# cordova-plugin-iad #
---------------------------
This is the Cordova Plugin to support Apple iAd on iOS. It provides a way to request ads natively from JavaScript. 

## See Also ##
---------------------------
Besides using Apple iAd, you have some other options, all working on cordova:
* [cordova-plugin-flurry](https://github.com/floatinghotpot/cordova-plugin-flurry), Flurry Ad service. 
* [cordova-plugin-admob](https://github.com/floatinghotpot/cordova-plugin-admob), Google AdMob service.

## How to use ##

Use Cordova/Phonegap command line tool:

    cordova create testiad com.rjfun.testiAd testiAd
    cd testiad
    cordova platform add ios
    cordova plugin add https://github.com/floatinghotpot/cordova-plugin-iad.git
    ...

## Weak Linking the iAd Framework ##

1. In your project, under "Targets", double click on the Target item
2. Go to the "General" Tab, under "Linked Libraries" 
3. For the iAd Framework, change the value from "Required" to "Weak"

## How to use it in javascript ##

    document.addEventListener("deviceready", onDeviceReady, false);

   	document.addEventListener("onClickAd", onClickAd, false);
  	document.addEventListener("onReceiveAd", onReceiveAd, false);
 	document.addEventListener("onFailedToReceiveAd", onFailedToReceiveAd, false);

    function onDeviceReady() {
    	if ( window.plugins && window.plugins.iAd ) {
    	    window.plugins.iAd.createBannerView( 
    	    		{
    		            'bannerAtTop': false,
			    'overlap': false
    	            }, function() {
    	            	window.plugins.iAd.showAd( true );
    	            }, function(){
    	            	alert( "failed to create ad view" );
    	            });
    	} else {
    		alert('iAd plugin not available/ready.');
    	}
    }
    function onClickAd() {
	// count click    	
    }
    function onReceiveAd() {
    	// do whatever you want 
    }
    function onFailedToReceiveAd( ret ) {
    	// alert( ret.error ); 
        // no need to handle it, sometimes ad just not loaded in time, but iad will try reload, 
        // once it's loaded, it will be displayed.
    }

## Donate ##
----------------------------------------------
You can use this cordova plugin for free. 

To support this project, donation is welcome.

Donation can be accepted via Paypal:
* [Donate directly via Paypal](http://floatinghotpot.github.io/#donate)


