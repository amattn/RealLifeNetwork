/******************************************************************************
 * - Created 2010/10/04 by Matt Nunogawa, @amattn
 * - Copyright Matt Nunogawa 2010-2012. All rights reserved.
 * - License: This software is provided under the MIT License.
 *            Please see LICENSE file.
 *
 * Simple wrapper around NSURLConnection.  
 * Allows block-based callbacks, while still maintaining all the functionality of 
 * a true NSURLConnectionDelegate object.
 *
 * Part of RLNetwork, http://github.com/amattn/RLNetwork
 */

#import <Foundation/Foundation.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

typedef void (^RLConnectionProgressHandlerBlockType)(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^RLConnectionSuccessHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSData *data);
typedef void (^RLConnectionErrorHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSError *error);

@interface RLConnection : NSObject
{
    
}

#pragma mark ** Properties **

@property (nonatomic, strong, readonly) NSDate *requestTime;
@property (nonatomic, strong, readonly) NSDate *responseTime;
@property (nonatomic, assign, readonly) NSInteger totalBytesWritten; // PUT or POST only

#pragma mark ** Methods **

+ (NSMutableURLRequest *)httpRequestWithURL:(NSURL *)url
                                 httpMethod:(NSString *)httpMethod // GET, PUT, POST, or DELETE
                                       data:(NSData *)bodyData
                               extraHeaders:(NSDictionary *)extraHeaders;

// progressHandler is only valid for POST and PUT
- (void)startConnectionWithURLRequest:(NSURLRequest *)urlRequest
                      progressHandler:(RLConnectionProgressHandlerBlockType)progressHandlerBlock
                       successHandler:(RLConnectionSuccessHandlerBlockType)successHandlerBlock
                         errorHandler:(RLConnectionErrorHandlerBlockType)errorHandlerBlock;

@end
