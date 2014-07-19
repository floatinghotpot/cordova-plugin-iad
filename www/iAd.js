

var argscheck = require('cordova/argscheck'), exec = require('cordova/exec');

iAdExport = {};

iAdExport.createBannerView = function(options, successCallback, failureCallback) {
	var defaults = {
		'bannerAtTop' : false,
        'overlap': false,
	'offsetTopBar': false
	};
    
	// Merge optional settings into defaults.
	for ( var key in defaults) {
		if (typeof options[key] !== 'undefined') {
			defaults[key] = options[key];
		}
	}
	cordova.exec(successCallback,
                 failureCallback,
                 'iAd',
                 'createBannerView',
                 [ defaults['bannerAtTop'], defaults['overlap'], defaults['offsetTopBar'] ]
                 );
};

iAdExport.showAd = function( show, successCallback, failureCallback) {
	if (show === undefined) {
		show = true;
	}
    
	cordova.exec(
                 successCallback,
                 failureCallback, 
                 'iAd', 
                 'showAd', 
                 [ show ]
                 );
};

module.exports = iAdExport;
