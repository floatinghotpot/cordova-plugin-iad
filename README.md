# cordova-plugin-iad #
---------------------------
Present Apple iAd in Mobile App/Games natively from JavaScript. 

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

```javascript
    document.addEventListener("deviceready", onDeviceReady, false);

   	document.addEventListener("onClickAd", onClickAd, false);
  	document.addEventListener("onReceiveAd", onReceiveAd, false);
 	document.addEventListener("onFailedToReceiveAd", onFailedToReceiveAd, false);

    function onDeviceReady() {
    	if ( window.plugins && window.plugins.iAd ) {
    	    window.plugins.iAd.createBannerView({
    		            'bannerAtTop': false,
    		            'overlap': false,
    		            'offsetTopBar' : false
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
```

## See Also ##

Cordova/PhoneGap plugins for the world leading Mobile Ad services:

* [AdMob Plugin Pro](https://github.com/floatinghotpot/cordova-admob-pro), enhanced Google AdMob plugin, easy API and more features.
* [mMedia Plugin Pro](https://github.com/floatinghotpot/cordova-plugin-mmedia), enhanced mMedia plugin, support impressive video Ad.
* [iAd Plugin](https://github.com/floatinghotpot/cordova-plugin-iad), Apple iAd service. 
* [FlurryAds Plugin](https://github.com/floatinghotpot/cordova-plugin-flurry), Yahoo Flurry Ads service.
* [MoPub Plugin Pro](https://github.com/floatinghotpot/cordova-plugin-mopub), MobPub Ads service.
* [MobFox Plugin Pro](https://github.com/floatinghotpot/cordova-mobfox-pro), enhanced MobFox plugin, support video Ad and many other Ad network with server-side integration.

More Cordova/PhoneGap plugins by Raymond Xie, [click here](http://floatinghotpot.github.io/).

Project outsourcing and consulting service is also available. Please [contact us](http://floatinghotpot.github.io) if you have the business needs.

