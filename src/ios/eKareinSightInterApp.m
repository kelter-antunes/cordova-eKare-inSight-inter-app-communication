#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "eKareinSightInterApp.h"
#import "RNEncryptor.h"

@implementation eKareinSightInterApp


- (void)open:(CDVInvokedUrlCommand*)command {
	[self.commandDelegate runInBackground:^{

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppScheme = [command.arguments objectAtIndex:1];
    NSString *kInterAppId = [command.arguments objectAtIndex:2];

    // Dictionary to be sent to inSight app which should include the hash that will be returned back
    //NSDictionary *clearDict = @{@"hash": @"43934s341049fjls348434", @"data": @"data value"};

    // Convert the NSDictionary object to NSData object
    NSData *measurementsClearData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"interapp" ofType:@"dat"]];

    //NSData *measurementsClearData = [NSKeyedArchiver archivedDataWithRootObject:clearDict];

    // Encryption password
    NSString *password = kInterAppPW;

    // Encrypt Data (AES256) using RNEncryptor library
    NSData *measurementsEncryptedData = [RNEncryptor encryptData:measurementsClearData withSettings:kRNCryptorAES256Settings password:password error:nil];
    
    // Convert encrypted data to NSString
    NSString *measurementsEncryptedString = [measurementsEncryptedData base64EncodedStringWithOptions:0];


    // Prepare the parameters to be passed in the URL
    NSString *params =  [NSString stringWithFormat:@"data=%@&source=%@", measurementsEncryptedString, NSBundle.mainBundle.bundleIdentifier];;


    // Prepare the URL string:
    NSString *scheme = kInterAppScheme;
    NSString *appId = kInterAppId;
    NSString *urlString = [NSString stringWithFormat:@"%@://%@?%@", scheme, appId, params];



    // Prepare the NSURL that will open inSight app
    NSURL *url = [NSURL URLWithString:urlString];

    NSString *nsURLString = url.absoluteString;
    result = nsURLString;

    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        NSLog(@"success : %d", success);
       
    }];

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}


- (void)readMeasurements:(CDVInvokedUrlCommand*)command {
	[self.commandDelegate runInBackground:^{

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppScheme = [command.arguments objectAtIndex:1];

    // Get the measurements data from the pasteboard
    NSData *text = [[UIPasteboard generalPasteboard] dataForPasteboardType:pastBoard];

		//UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		//NSString     *text       = [pasteboard valueForPasteboardType:@"public.text"];
		if (text == nil) {
			text = @"";
		}

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}

@end