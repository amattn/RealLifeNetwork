/******************************************************************************
 * - Created 2010/10/04 by Matt Nunogawa, @amattn
 * - Copyright Matt Nunogawa 2010-2012. All rights reserved.
 * - License: This software is provided under the MIT License.
 *            Please see LICENSE file.
 *
 * Part of RLNetwork, http://github.com/amattn/RLNetwork
 */

#import <Foundation/Foundation.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

typedef void (^RLConnectionManagerSuccessHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSData *responseData);
typedef void (^RLConnectionManagerProgressHandlerBlockType)(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^RLConnectionManagerErrorHandlerBlockType)(NSURLRequest *request, NSError *error);

@interface RLConnectionManager : NSObject
{
    
}

#pragma mark ** Singleton Accessors **
+ (RLConnectionManager *)singleton;

#pragma mark ** Properties **
@property (nonatomic, readonly) NSUInteger activeConnectionsCount;

#pragma mark ** Generic Request **

- (void)startURLRequest:(NSURLRequest *)urlRequest
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandler
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;

#pragma mark ** HTTP Convenience Methods **

- (void)getRequestToURL:(NSURL *)url
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

- (void)postRequestToURL:(NSURL *)url
                    data:(NSData *)postData
         progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
          successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
            errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

- (void)putRequestToURL:(NSURL *)url
                   data:(NSData *)putData
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;

@end
