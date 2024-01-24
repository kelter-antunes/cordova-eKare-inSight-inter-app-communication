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
 * @param {String}   kInterAppId
 * @param {String}   kInterAppPW      
 * @param {String}   kInterAppMeasurementScheme
 * @param {String}   kInterAppCallbackScheme
 * @param {String}   kInterAppPasteBoardName
 * @param {Function} onSuccess The function to call in case of success (takes the copied text as argument)
 * @param {Function} onFail    The function to call in case of error
 */
eKareinSightInterApp.prototype.open = function (kInterAppId, kInterAppPW, kInterAppMeasurementScheme, kInterAppCallbackScheme, kInterAppPasteBoardName, onSuccess, onFail) {
  if (typeof kInterAppId === "undefined" || kInterAppId === null){
    kInterAppId = ""
  }
  if (typeof kInterAppPW === "undefined" || kInterAppPW === null){
    kInterAppPW = ""
  }
  if (typeof kInterAppMeasurementScheme === "undefined" || kInterAppMeasurementScheme === null){
    kInterAppMeasurementScheme = ""
  }
  if (typeof kInterAppCallbackScheme === "undefined" || kInterAppCallbackScheme === null){
    kInterAppCallbackScheme = ""
  }
  if (typeof kInterAppPasteBoardName === "undefined" || kInterAppPasteBoardName === null){
    kInterAppPasteBoardName = ""
  }
  cordova.exec(onSuccess, onFail, PLUGIN_NAME, "open", [kInterAppId, kInterAppPW, kInterAppMeasurementScheme, kInterAppCallbackScheme, kInterAppPasteBoardName]);
};


/**
 * Gets the measurments data from the clipboard content
 *
 * @param {String}   kInterAppPW      
 * @param {String}   kInterAppPasteBoardName
 * @param {Function} onSuccess The function to call in case of success
 * @param {Function} onFail    The function to call in case of error
 */
eKareinSightInterApp.prototype.readMeasurements = function (kInterAppPW, kInterAppPasteBoardName, onSuccess, onFail) {
  if (typeof kInterAppPW === "undefined" || kInterAppPW === null){
    kInterAppPW = ""
  }
  if (typeof kInterAppPasteBoardName === "undefined" || kInterAppPasteBoardName === null){
    kInterAppPasteBoardName = ""
  }

	cordova.exec(onSuccess, onFail, PLUGIN_NAME, "readMeasurements", [kInterAppPW, kInterAppPasteBoardName]);
};


// Register the plugin
var eKareinSightInterApp = new eKareinSightInterApp();
module.exports = eKareinSightInterApp;