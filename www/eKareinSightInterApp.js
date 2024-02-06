import { exec } from 'cordova';
const PLUGIN_NAME = 'eKareinSightInterApp';

class eKareinSightInterApp {
  constructor() { }
  open(kInterAppId = "",
    kInterAppPW = "",
    kInterAppMeasurementScheme = "",
    kInterAppCallbackScheme = "",
    kInterAppPasteBoardName = "",
    onSuccess,
    onFail) {
    exec(onSuccess, onFail, PLUGIN_NAME, "open", [kInterAppId, kInterAppPW, kInterAppMeasurementScheme, kInterAppCallbackScheme, kInterAppPasteBoardName]);
  }
  readMeasurements(kInterAppPW = "",
    kInterAppPasteBoardName = "",
    onSuccess,
    onFail) {
    exec(onSuccess, onFail, PLUGIN_NAME, "readMeasurements", [kInterAppPW, kInterAppPasteBoardName]);
  }
  clearPasteboard(onSuccess, onFail) {
    exec(onSuccess, onFail, PLUGIN_NAME, "clearPasteboard");
  }
}

let eKareinSightInterAppInstance = new eKareinSightInterApp();
export default eKareinSightInterAppInstance;