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
    NSString *pastBoard = kInterAppScheme;

    // Get the measurements data from the pasteboard
    NSData *rawData = [[UIPasteboard generalPasteboard] dataForPasteboardType:pastBoard];
  
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
    

/*
    NSString *jsonString = [NSString stringWithFormat:
                              @"{\"area\":\"%@\",\"avg_depth\":\"%@\",\"maximum_depth\":\"%@\",\"volume\":\"%@\",\"slough\":\"%@\",\"eschar\":\"%@\",\"granulation\":\"%@\"}",
                              measurement[@"area"],
                              measurement[@"avg_depth"],
                              measurement[@"maximum_depth"],
                              measurement[@"volume"],
                              measurement[@"slough"],
                              measurement[@"eschar"],
                              measurement[@"granulation"]
                           ];
*/
NSString *jsonString = [NSString stringWithFormat:
                            @"Image: %@\ntissue: %@\noutline: %@",
                              dict[@"main_measurement"][@"image"],
                              dict[@"main_measurement"][@"tissue"],
                              dict[@"main_measurement"][@"_outline"]
                           ];

    result = jsonString;


    
    //[self.woundImgView setImage:self.dataDictionary[@"main_measurement"][@"image"]];
    //[self.classificationImgView setImage:self.dataDictionary[@"main_measurement"][@"tissue"]];
    //[self.outlineImgView setImage:self.dataDictionary[@"main_measurement"][@"_outline"]];


    if (result == nil) {
			result = @"";
		}

    // Clean the the systemwide general pasteboard
    [[UIPasteboard generalPasteboard] setData:[NSData data] forPasteboardType:pastBoard];

		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}

@end