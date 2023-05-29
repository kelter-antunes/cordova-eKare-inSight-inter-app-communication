#import "eKareinSightInterApp.h"

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
- (void)encrypt:(CDVInvokedUrlCommand *)command {

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
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];

    

    result = [textData base64EncodedStringWithOptions:0];
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