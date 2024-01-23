#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "eKareinSightInterApp.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@implementation eKareinSightInterApp


- (void)open:(CDVInvokedUrlCommand*)command {
	[self.commandDelegate runInBackground:^{

    NSString *result = nil;

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppScheme = [command.arguments objectAtIndex:1];
    NSString *kInterAppId = [command.arguments objectAtIndex:2];


    NSString *pasteBoardName = [NSBundle mainBundle].bundleIdentifier;
    // Prepare the parameters to be passed in the URL
    NSString *params = [NSString stringWithFormat:@"source=%@&pasteboard_name=%@&wound_id=-1&callback_scheme=%@",  NSBundle.mainBundle.bundleIdentifier, pasteBoardName, @"measure-demo"];
    

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

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}


- (void)readMeasurements:(CDVInvokedUrlCommand*)command {
	[self.commandDelegate runInBackground:^{

    NSString *result = nil;

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppScheme = [command.arguments objectAtIndex:1];

    // interapp scheme to be shared with external system separately
    //NSString *pasteBoardName = kInterAppScheme;

    // This function is called when inSight calls back the external app

    // interapp scheme to be shared with external system separately
    // Clean the the systemwide general pasteboard
    NSString *pasteBoardName = NSBundle.mainBundle.bundleIdentifier;
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:pasteBoardName create:NO];


    // Get the measurements data from the pasteboard
    NSData *rawData;
    for (NSDictionary *item in [pasteBoard items]) {
        if ([item objectForKey:@"encrypted_data"]) {
            rawData = [item objectForKey:@"encrypted_data"];
        }
    }

  
    if (rawData.length > 0) {
        
        // The password to be shared with external system separately
        NSString *password = kInterAppPW;
      
        // Decrypt the measurements data
        NSData *data = [RNDecryptor decryptData: rawData
                                  withSettings:kRNCryptorAES256Settings
                                      password:password
                                        error:nil];
      
        // Convert the NSData to NSDictionary
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSDictionary *measurement = dict[@"main_measurement"][@"measurements"];

        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:measurement];
        
        //Convert UIImages to jpeg base64
        NSString *woundImgBase64 = [UIImageJPEGRepresentation(dict[@"main_measurement"][@"image"], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *classificationImgBase64 = [UIImageJPEGRepresentation(dict[@"main_measurement"][@"tissue"], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *outlineImgBase64 = [UIImageJPEGRepresentation(dict[@"main_measurement"][@"_outline"], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

        // Add image nodes to the JSON
        [mutableDictionary setObject:woundImgBase64 forKey:@"woundImg"];
        [mutableDictionary setObject:classificationImgBase64 forKey:@"classificationImg"];
        [mutableDictionary setObject:outlineImgBase64 forKey:@"outlineImg"];

        // Iterate over dictionary and convert null values to empty strings
        for (NSString *key in [mutableDictionary allKeys]) {
            id value = [mutableDictionary objectForKey:key];
            if ([value isKindOfClass:[NSNull class]]) {
                [mutableDictionary setObject:@"" forKey:key];
            }
        }

        NSError *error;
        // Convert back to JSON string
        NSData *newJsonData = [NSJSONSerialization dataWithJSONObject:mutableDictionary options:NSJSONWritingPrettyPrinted error:&error];

        if (error) {
          NSLog(@"Error converting to JSON: %@", error.localizedDescription);
          result = error;  
        }else {

          NSString *newJsonString = [[NSString alloc] initWithData:newJsonData encoding:NSUTF8StringEncoding];
          NSLog(@"%@", newJsonString);

          result = newJsonString;

        }
        
    } 

    if (result == nil) {
			result = @"";
		}

    // Clean the the systemwide general pasteboard
    [pasteBoard setItems:[NSArray array]];

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}

@end