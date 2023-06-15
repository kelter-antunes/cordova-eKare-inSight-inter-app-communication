#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface eKareinSightInterApp : CDVPlugin {}

- (void)open:(CDVInvokedUrlCommand *)command;
- (void)readMeasurements:(CDVInvokedUrlCommand*)command;

@end