# Cordova iAd Plugin #

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
    		            'bannerAtTop': true
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
    	alert( ret.error );
    }

## Related ##

It's for iOS only. If you are writing App for Android/iOS, may try this cordova plugin:

    https://github.com/floatinghotpot/cordova-plugin-admob.git
    
    
