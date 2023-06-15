/**
 * eKareinSightInterApp.js
 *
 * @overview eKareinSightInterApp operations for Cordova.
 * @author Miguel 'Kelter' Antunes
 * @license MIT
*/

var cordova = require('cordova');

var PLUGIN_NAME = 'eKareinSightInterApp';


/**
 * eKareinSightInterApp plugin for Cordova
 * 
 * @constructor
 */
function eKareinSightInterApp () {}


/**
 * Opens eKareinSight app and stores measurments in the clipboard content
 *
 * @param {String}   kInterAppPW      
 * @param {String}   kInterAppScheme
 * @param {String}   kInterAppId
 * @param {Function} onSuccess The function to call in case of success (takes the copied text as argument)
 * @param {Function} onFail    The function to call in case of error
 */
eKareinSightInterApp.prototype.open = function (kInterAppPW, kInterAppScheme, kInterAppId, onSuccess, onFail) {
  if (typeof kInterAppPW === "undefined" || kInterAppPW === null){
    kInterAppPW = ""
  }
  if (typeof kInterAppScheme === "undefined" || kInterAppScheme === null){
    kInterAppScheme = ""
  }
  if (typeof kInterAppId === "undefined" || kInterAppId === null){
    kInterAppId = ""
  }
  cordova.exec(onSuccess, onFail, PLUGIN_NAME, "open", [kInterAppPW, kInterAppScheme, kInterAppId]);
};


/**
 * Gets the measurments data from the clipboard content
 *
 * @param {String}   kInterAppPW      
 * @param {String}   kInterAppScheme
 * @param {Function} onSuccess The function to call in case of success
 * @param {Function} onFail    The function to call in case of error
 */
eKareinSightInterApp.prototype.readMeasurements = function (kInterAppPW, kInterAppScheme, onSuccess, onFail) {
  if (typeof kInterAppPW === "undefined" || kInterAppPW === null){
    kInterAppPW = ""
  }
  if (typeof kInterAppScheme === "undefined" || kInterAppScheme === null){
    kInterAppScheme = ""
  }

	cordova.exec(onSuccess, onFail, PLUGIN_NAME, "readMeasurements", [kInterAppPW, kInterAppScheme]);
};


// Register the plugin
var eKareinSightInterApp = new eKareinSightInterApp();
module.exports = eKareinSightInterApp;