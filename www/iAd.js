
var argscheck = require('cordova/argscheck'),
    exec = require('cordova/exec');

iAdExport = {};

iAdExport.prepare = function(atBottom, successCallback, failedCallback) {
	cordova.exec(successCallback, failedCallback, 'iAd', 'prepare', [ atBottom ] );
};

iAdExport.showAd = function(show, successCallback, failedCallback) {
	cordova.exec(successCallback, failedCallback, 'iAd', 'showAd', [ show ] );
};

iAdExport.orientationChanged = functio(successCallback, failedCallback) {
	cordova.exec(sucessCallback, failedCallback, 'iAd', 'orientationChanged', [ window.orientation ] );
};

module.exports = iAdExport;
