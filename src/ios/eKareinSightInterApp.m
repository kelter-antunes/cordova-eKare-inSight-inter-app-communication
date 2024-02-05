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

    NSString *kInterAppId = [command.arguments objectAtIndex:0];
    NSString *kInterAppPW = [command.arguments objectAtIndex:1];
    NSString *kInterAppMeasurementScheme = [command.arguments objectAtIndex:2];
    NSString *kInterAppCallbackScheme = [command.arguments objectAtIndex:3];
    NSString *kInterAppPasteBoardName = [command.arguments objectAtIndex:4];


    // Prepare the parameters to be passed in the URL
    NSString *params = [NSString stringWithFormat:@"source=%@&pasteboard_name=%@&wound_id=-1&callback_scheme=%@",  kInterAppId, kInterAppPasteBoardName, kInterAppCallbackScheme];
    
    // Prepare the URL string:
    NSString *urlString = [NSString stringWithFormat:@"%@://%@?%@", kInterAppMeasurementScheme, kInterAppId, params];

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

    // This function is called when inSight calls back the external app

    NSString *result = nil;

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppPasteBoardName = [command.arguments objectAtIndex:1];

    // Get the measurements data from the pasteboard
    //UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:kInterAppPasteBoardName create:NO];


    // Get the measurements data from the pasteboard
    // UIPasteboard *pasteBoard = [[UIPasteboard generalPasteboard] dataForPasteboardType:kInterAppPasteBoardName];


// Access the general pasteboard
UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];

// Retrieve the encrypted data from the pasteboard items
NSData *encryptedData = nil;
for (NSDictionary *item in [pasteBoard items]) {
    if ([item objectForKey:@"encrypted_data"] && [[item objectForKey:@"encrypted_data"] isKindOfClass:[NSData class]]) {
        encryptedData = [item objectForKey:@"encrypted_data"];
        break;
    }
}

if (!encryptedData) {
    NSLog(@"No valid encrypted data found on the pasteboard.");
    result = @"No valid encrypted data found on the pasteboard.";
} else {
    // The password to be shared with an external system separately
    NSString *password = kInterAppPW;

    // Decrypt the measurements data
    NSError *decryptError = nil;
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                       withSettings:kRNCryptorAES256Settings
                                           password:password
                                              error:&decryptError];

    if (decryptError) {
        NSLog(@"Error decrypting data: %@", decryptError.localizedDescription);
        result = [NSString stringWithFormat:@"Error decrypting data: %@", decryptError.localizedDescription];
    } else {
        // Convert the decrypted NSData to a NSDictionary
        NSDictionary *measurementDict = nil;
        @try {
            measurementDict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];

            // Filter out non-JSOn-serializable values if needed
            NSMutableDictionary *serializableDict = [NSMutableDictionary dictionary];
            for (NSString *key in measurementDict) {
                id value = measurementDict[key];
                if ([NSJSONSerialization isValidJSONObject:value]) {
                    serializableDict[key] = value;
                }
            }

            // Check if "files" key is present in measurementDict
            if ([measurementDict objectForKey:@"files"] && [[measurementDict objectForKey:@"files"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *filesDict = [measurementDict objectForKey:@"files"];

                NSMutableDictionary *base64Files = [NSMutableDictionary dictionary];

                // Iterate through filesDict to convert images to base64
                for (NSString *fileName in filesDict.allKeys) {
                    NSData *fileData = [filesDict objectForKey:fileName];

                    if ([fileName.pathExtension isEqualToString:@"png"] || [fileName.pathExtension isEqualToString:@"jpg"] || [fileName.pathExtension isEqualToString:@"jpeg"]) {
                        // Convert image data to base64 string
                        NSString *base64String = [fileData base64EncodedStringWithOptions:0];
                        base64Files[fileName] = base64String;
                    }
                }

                // Add the base64 image information to the result
                result = @{@"measurement": serializableDict, @"files": base64Files};
            } else {
                // No "files" key found in measurementDict
                NSLog(@"No 'files' key found in measurementDict.");
                result = @{@"measurement": serializableDict, @"files": @"No 'files' key found in measurementDict."};
            }
        } @catch (NSException *exception) {
            NSLog(@"Error unarchiving decrypted data: %@", exception.reason);
            result = [NSString stringWithFormat:@"Error unarchiving decrypted data: %@", exception.reason];
        }
    }
}








    // interapp scheme to be shared with external system separately
    //NSString *pasteBoardName = kInterAppScheme;

    // This function is called when inSight calls back the external app

    // interapp scheme to be shared with external system separately
    // Clean the the systemwide general pasteboard
    //NSString *pasteBoardName = NSBundle.mainBundle.bundleIdentifier;
    //NSString *pasteBoardName = kInterAppPasteBoardName;
    //UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:pasteBoardName create:NO];




    // .OLD Get the measurements data from the pasteboard
    //NSData *rawData = [[UIPasteboard generalPasteboard] dataForPasteboardType:pasteBoardName];


    // Get the measurements data from the pasteboard
    //NSData *rawData;
    //for (NSDictionary *item in [pasteBoard items]) {
    //    if ([item objectForKey:@"encrypted_data"]) {
    //        rawData = [item objectForKey:@"encrypted_data"];
    //    }
    //}

  /*
    //if (rawData.length > 0) {
        
        // The password to be shared with external system separately
        NSString *password = kInterAppPW;
      
        // Decrypt the measurements data
        NSData *data = [RNDecryptor decryptData: rawData
                                  withSettings:kRNCryptorAES256Settings
                                      password:password
                                        error:nil];
      
        // Convert the NSData to NSDictionary
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        

        NSString *measurementJSON = dict[@"measurement"][@"measurements"];

        result = measurementJSON;


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
          
    
    
    //} 

    if (result == nil) {
			result = @"";
		}*/

    // Clean the the systemwide general pasteboard
    //[pasteBoard setItems:[NSArray array]];

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}

@end