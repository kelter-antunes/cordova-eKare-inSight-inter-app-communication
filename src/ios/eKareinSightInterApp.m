#import "eKareinSightInterApp.h"
#import "RNEncryptor.h"

@implementation eKareinSightInterApp


NSString *const PREFIX_ERROR = @"ERR: ";

- (NSString *)_asError:(NSString *)msg {

	return [PREFIX_ERROR stringByAppendingString:msg];
}

/**
 *  open
 *
 *  @param command An array of arguments passed from javascript
 */
- (void)open:(CDVInvokedUrlCommand *)command {

  [self.commandDelegate
  	sendPluginResult:[self openApp:@"open" command:command]
  	callbackId:command.callbackId];
}


/**
 *  opens eKare inSight app.
 *
 *
 *  @param action  operation
 *  @param command Cordova arguments
 *
 *  @return result of operation
 */
- (CDVPluginResult*)openApp:(NSString *)action command:(CDVInvokedUrlCommand *)command {

  NSString *kInterAppPW = [command.arguments objectAtIndex:0];
  NSString *kInterAppScheme = [command.arguments objectAtIndex:1];
  NSString *kInterAppId = [command.arguments objectAtIndex:2];


  if(kInterAppPW == nil || [kInterAppPW length] == 0)
  	return [CDVPluginResult
  						resultWithStatus:CDVCommandStatus_ERROR
  						messageAsString:[self _asError: @"Empty argument"]];

  if(kInterAppScheme == nil || [kInterAppScheme length] == 0)
  	return [CDVPluginResult
  						resultWithStatus:CDVCommandStatus_ERROR
  						messageAsString:[self _asError: @"Empty argument"]];

  if(kInterAppId == nil || [kInterAppId length] == 0)
  	return [CDVPluginResult
  						resultWithStatus:CDVCommandStatus_ERROR
  						messageAsString:[self _asError: @"Empty argument"]];


  NSError *error;
  NSString *result = nil;

  if ([action isEqualToString:@"open"])
  {
    
     // Dictionary to be sent to inSight app which should include the hash that will be returned back
    NSDictionary *clearDict = @{@"hash": @"43934s341049fjls348434", @"data": @"data value"};

    // Convert the NSDictionary object to NSData object
    //NSData *measurementsClearData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"interapp" ofType:@"dat"]];

    NSData *measurementsClearData = [NSKeyedArchiver archivedDataWithRootObject:clearDict];

    // Encryption password
    NSString *password = kInterAppPW;

    // Encrypt Data (AES256) using RNEncryptor library
    NSData *measurementsEncryptedData = [RNEncryptor encryptData:measurementsClearData withSettings:kRNCryptorAES256Settings password:password error:nil];
    
    // Convert encrypted data to NSString
    NSString *measurementsEncryptedString = [measurementsEncryptedData base64EncodedStringWithOptions:0];

    // Prepare the parameters to be passed in the URL
    NSString *params = [NSString stringWithFormat:@"data=%@", measurementsEncryptedString];


    // Prepare the URL string:
    NSString *scheme = kInterAppScheme;
    NSString *appId = kInterAppId;
    NSString *urlString = [NSString stringWithFormat:@"%@://%@?%@", scheme, appId, params];


    // Prepare the NSURL that will open inSight app
    NSURL *url = [NSURL URLWithString:urlString];

    result = [url base64EncodedStringWithOptions:0];



    }
	else
	{
		return [CDVPluginResult
  						resultWithStatus:CDVCommandStatus_ERROR
  						messageAsString:[self _asError: @"Action not 'open'"]];
	}


  if(error != nil)
  {
		return [CDVPluginResult
  						resultWithStatus:CDVCommandStatus_ERROR
  						messageAsString:[self _asError: [error localizedDescription]]];
  }


	return [CDVPluginResult
						resultWithStatus:CDVCommandStatus_OK
						messageAsString:result];
}

@end