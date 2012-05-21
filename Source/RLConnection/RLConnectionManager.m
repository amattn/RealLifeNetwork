/******************************************************************************
 * - Created 2010/10/04 by Matt Nunogawa, @amattn
 * - Copyright Matt Nunogawa 2010-2012. All rights reserved.
 * - License: This software is provided under the MIT License.
 *            Please see LICENSE file.
 *
 * Part of RLNetwork, http://github.com/amattn/RLNetwork
 */

#import "RLConnectionManager.h"
#import "RLConnection.h"

@interface RLConnectionManager ()
@property (nonatomic, retain) NSMutableDictionary *activeConnections;
@end

@implementation RLConnectionManager

#pragma mark ** Synthesis **
@synthesize activeConnections = _activeConnections;

#pragma mark ** Static Variables **
static RLConnectionManager *__sharedRLNetworkManager = nil;

#pragma mark ** Singleton **
+ (RLConnectionManager *)singleton;
{
    static dispatch_once_t createSingletonPredicate;
    dispatch_once(&createSingletonPredicate, ^
                  {
                      __sharedRLNetworkManager = [[RLConnectionManager alloc] init];
                  });
    return __sharedRLNetworkManager;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Lifecyle & Memory Management **

- (id)init;
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Utilities **

/*********************************************************************/
#pragma mark -
#pragma mark ** Generic Request **

- (void)startURLRequest:(NSURLRequest *)urlRequest
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)outerProgressHandler
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)outerSuccessHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)outerErrorHandlerBlock;
{
    RLConnection *connection = [[RLConnection alloc] init];
    NSValue *valueKey = [NSValue valueWithPointer:&connection];
    
    // Progress is used to track progress of POST and PUT requests
    RLConnectionManagerProgressHandlerBlockType progressHandler = nil;
    
    if ([urlRequest.HTTPMethod isEqualToString:@"POST"] || [urlRequest.HTTPMethod isEqualToString:@"PUT"])
    {
        if (outerProgressHandler)
        {
            progressHandler = ^(NSURLRequest *request, NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite)
            {
                outerProgressHandler(request, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            };
        }
    }
    
    // If we succeed, do this
    RLConnectionSuccessHandlerBlockType successHandler = nil;
    if (outerSuccessHandlerBlock)
    {
        successHandler = ^(NSURLRequest *request, NSURLResponse *response, NSData *responseData)
        {
            //remove this connection from "in-flight" status
            [self.activeConnections removeObjectForKey:valueKey];
            outerSuccessHandlerBlock(request, response, responseData);
        };
    }
    
    
    // If we fail, do this
    RLConnectionErrorHandlerBlockType errorHandler = nil;
    if (outerErrorHandlerBlock)
    {
        errorHandler = ^(NSURLRequest *request, NSURLResponse *response, NSError *error)
        {
            //remove this connection from "in-flight" status
            [self.activeConnections removeObjectForKey:valueKey];       
            outerErrorHandlerBlock(request, error);
        };
    };
    
    // remember which requests are "in-flight"
    [self.activeConnections setObject:connection forKey:valueKey];
    
    // Launch the request
    [connection startConnectionWithURLRequest:urlRequest
                              progressHandler:progressHandler
                               successHandler:successHandler
                                 errorHandler:errorHandler];
}

/*********************************************************************/
#pragma mark -
#pragma mark ** HTTP Convenience Methods **

- (void)getRequestToURL:(NSURL *)url
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"GET"
                                                                  data:nil
                                                          extraHeaders:nil];
    
    [self startURLRequest:urlRequest
          progressHandler:nil
           successHandler:successHandlerBlock
             errorHandler:errorHandlerBlock];
}

- (void)postRequestToURL:(NSURL *)url
                    data:(NSData *)postData
         progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
          successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
            errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"POST"
                                                                  data:postData
                                                          extraHeaders:nil];
    
    [self startURLRequest:urlRequest
          progressHandler:progressHandlerBlock
           successHandler:successHandlerBlock
             errorHandler:errorHandlerBlock];
}

- (void)putRequestToURL:(NSURL *)url
                   data:(NSData *)putData
        progressHandler:(RLConnectionManagerProgressHandlerBlockType)progressHandlerBlock
         successHandler:(RLConnectionManagerSuccessHandlerBlockType)successHandlerBlock
           errorHandler:(RLConnectionManagerErrorHandlerBlockType)errorHandlerBlock;
{
    NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
                                                            httpMethod:@"PUT"
                                                                  data:putData
                                                          extraHeaders:nil];
    
    [self startURLRequest:urlRequest
          progressHandler:progressHandlerBlock
           successHandler:successHandlerBlock
             errorHandler:errorHandlerBlock];
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Accesssors **

- (NSMutableDictionary *)activeConnections;
{
    // Lazy load
    if (_activeConnections == nil)
        _activeConnections = [NSMutableDictionary dictionary];
    
    return _activeConnections;
}

- (NSUInteger)activeConnectionsCount;
{
    return [self.activeConnections count];
}

@end
