#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import <Foundation/Foundation.h>
#import "RNDecryptor.h"
#import "RNEncryptor.h"
#import "eKareinSightInterApp.h"

@implementation eKareinSightInterApp

- (void)open:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    NSString *result = nil;

    NSString *kInterAppId = [command.arguments objectAtIndex:0];
    NSString *kInterAppPW = [command.arguments objectAtIndex:1];
    NSString *kInterAppMeasurementScheme = [command.arguments objectAtIndex:2];
    NSString *kInterAppCallbackScheme = [command.arguments objectAtIndex:3];
    NSString *kInterAppPasteBoardName = [command.arguments objectAtIndex:4];

    // Prepare the parameters to be passed in the URL
    NSString *params = [NSString
        stringWithFormat:
            @"source=%@&pasteboard_name=%@&wound_id=-1&callback_scheme=%@",
            kInterAppId, kInterAppPasteBoardName, kInterAppCallbackScheme];

    // Prepare the URL string:
    NSString *urlString =
        [NSString stringWithFormat:@"%@://%@?%@", kInterAppMeasurementScheme,
                                   kInterAppId, params];

    // Prepare the NSURL that will open inSight app
    NSURL *url = [NSURL URLWithString:urlString];

    NSString *nsURLString = url.absoluteString;
    result = nsURLString;

    [[UIApplication sharedApplication] openURL:url
        options:@{}
        completionHandler:^(BOOL success) {
          NSLog(@"success : %d", success);
        }];

    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
  }];
}

- (void)readMeasurements:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    // This function is called when inSight calls back the external app

    NSString *result = nil;

    NSString *kInterAppPW = [command.arguments objectAtIndex:0];
    NSString *kInterAppPasteBoardName = [command.arguments objectAtIndex:1];

    // Get the measurements data from the pasteboard
    // UIPasteboard *pasteBoard = [UIPasteboard
    // pasteboardWithName:kInterAppPasteBoardName create:NO];

    // Get the measurements data from the pasteboard
    // UIPasteboard *pasteBoard = [[UIPasteboard generalPasteboard]
    // dataForPasteboardType:kInterAppPasteBoardName];

    // Access the general pasteboard
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];

    // Retrieve the encrypted data from the pasteboard items
    NSData *encryptedData = nil;
    for (NSDictionary *item in [pasteBoard items]) {
      if ([item objectForKey:@"encrypted_data"] &&
          [[item objectForKey:@"encrypted_data"]
              isKindOfClass:[NSData class]]) {
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
        result = [NSString stringWithFormat:@"Error decrypting data: %@",
                                            decryptError.localizedDescription];
      } else {
        // Convert the decrypted NSData to a NSMutableDictionary
        NSMutableDictionary *measurementDict = nil;
        @try {
          measurementDict = (NSMutableDictionary *)[NSKeyedUnarchiver
              unarchiveObjectWithData:decryptedData];

          // Filter out non-JSON-serializable values if needed
          NSMutableDictionary *serializableDict =
              [NSMutableDictionary dictionary];
          for (NSString *key in measurementDict) {
            id value = measurementDict[key];
            if ([NSJSONSerialization isValidJSONObject:value]) {
              serializableDict[key] = value;
            }
          }

          // Check if "files" key is present in measurementDict
          if ([measurementDict objectForKey:@"files"] &&
              [[measurementDict objectForKey:@"files"]
                  isKindOfClass:[NSDictionary class]]) {
            NSDictionary *filesDict = [measurementDict objectForKey:@"files"];

            // Declare variables for each image type
            NSData *depthData = nil;
            NSData *webPImageData = nil;
            NSData *mergedImageData = nil;
            NSData *outlineImageData = nil;
            NSData *classificationImageData = nil;

            // Declare variables to store base64 strings
            NSString *depthBase64 = nil;
            NSString *webPImageBase64 = nil;
            NSString *mergedImageBase64 = nil;
            NSString *outlineImageBase64 = nil;
            NSString *classificationImageBase64 = nil;

            // Iterate through filesDict to assign values to variables
            for (NSString *fileName in filesDict.allKeys) {
              NSData *fileData = [filesDict objectForKey:fileName];

              if ([fileName.pathExtension isEqualToString:@"zip"]) {
                depthData = fileData;
                depthBase64 = [depthData base64EncodedStringWithOptions:0];
              } else if ([fileName.pathExtension isEqualToString:@"webp"]) {
                webPImageData = fileData;
                webPImageBase64 =
                    [webPImageData base64EncodedStringWithOptions:0];
              } else if ([fileName hasSuffix:@"_merged.png"]) {
                mergedImageData = fileData;
                mergedImageBase64 =
                    [mergedImageData base64EncodedStringWithOptions:0];
              } else if ([fileName hasSuffix:@"_outline.png"]) {
                outlineImageData = fileData;
                outlineImageBase64 =
                    [outlineImageData base64EncodedStringWithOptions:0];
              } else {
                classificationImageData = fileData;
                classificationImageBase64 =
                    [classificationImageData base64EncodedStringWithOptions:0];
              }
            }

            // Add the base64 strings to the "files" dictionary within the
            // "measurement" element
            [measurementDict setObject:@{
              @"depthData" : depthBase64 ?: [NSNull null],
              @"webPImageData" : webPImageBase64 ?: [NSNull null],
              @"mergedImageData" : mergedImageBase64 ?: [NSNull null],
              @"outlineImageData" : outlineImageBase64 ?: [NSNull null],
              @"classificationImageData" : classificationImageBase64
                  ?: [NSNull null]
            }
                                forKey:@"files"];

            // Add the updated "measurement" element to the result
            result = @{@"measurement" : measurementDict};
          } else {
            // No "files" key found in measurementDict
            NSLog(@"No 'files' key found in measurementDict.");
            result = @{
              @"measurement" : serializableDict,
              @"files" : @"No 'files' key found in measurementDict."
            };
          }
        } @catch (NSException *exception) {
          NSLog(@"Error unarchiving decrypted data: %@", exception.reason);
          result = [NSString
              stringWithFormat:@"Error unarchiving decrypted data: %@",
                               exception.reason];
        }
      }
    }

    // Clean the the systemwide general pasteboard
    [pasteBoard setItems:[NSArray array]];

    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
  }];
}

@end