/**
 * eKareinSightInterApp.js
 *
 * @overview eKareinSightInterApp file operations for Cordova.
 * @author Miguel 'Kelter' Antunes
 * @license MIT
*/
var exec = require('cordova/exec');

var PLUGIN_NAME = 'eKareinSightInterApp';

var eKareinSightInterApp = {
  open: function (kInterAppPW, kInterAppScheme, kInterAppId, success, error) {

    exec(success, error, PLUGIN_NAME, 'open', [kInterAppPW, kInterAppScheme, kInterAppId]);
  }, 
};

module.exports = eKareinSightInterApp;
