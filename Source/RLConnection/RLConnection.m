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

#import "RLConnection.h"

#define DEFAULT_TIMEOUT 300

@interface RLConnection ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLResponse *urlResponse;
@property (nonatomic, copy) RLConnectionProgressHandlerBlockType progressHandler;
@property (nonatomic, copy) RLConnectionSuccessHandlerBlockType sucesssHandler;
@property (nonatomic, copy) RLConnectionErrorHandlerBlockType errorHandler;
@property (nonatomic, strong, readwrite) NSDate *requestTime;
@property (nonatomic, strong, readwrite) NSDate *responseTime;
@property (nonatomic, assign, readwrite) NSInteger totalBytesWritten; // PUT or POST only
@end

@implementation RLConnection
#pragma mark ** Synthesis **

@synthesize receivedData = _receivedData;
@synthesize connection = _connection;
@synthesize urlRequest = _urlRequest;
@synthesize urlResponse = _urlResponse;
@synthesize progressHandler = _progressHandler;
@synthesize sucesssHandler = _sucesssHandler;
@synthesize errorHandler = _errorHandler;
@synthesize requestTime = _requestTime;
@synthesize responseTime = _responseTime;
@synthesize totalBytesWritten = _totalBytesWritten;

/*********************************************************************/
#pragma mark -
#pragma mark ** Lifecycle & Memory Mangement **

// none, ARC will take care of everything for us

/*********************************************************************/
#pragma mark -
#pragma mark ** Actions **

+ (NSMutableURLRequest *)httpRequestWithURL:(NSURL *)url
                                 httpMethod:(NSString *)httpMethod // GET, PUT or POST
                                       data:(NSData *)bodyData
                               extraHeaders:(NSDictionary *)extraHeaders;
{
    NSMutableURLRequest *urlRequest;
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                          timeoutInterval:DEFAULT_TIMEOUT];
    [urlRequest setHTTPMethod:httpMethod];
    [urlRequest setHTTPShouldHandleCookies:NO];
    if (bodyData)
        [urlRequest setHTTPBody:bodyData];
    if (extraHeaders)
        [urlRequest setAllHTTPHeaderFields:extraHeaders];
    return urlRequest;
}

- (void)startConnectionWithURLRequest:(NSURLRequest *)urlRequest
                      progressHandler:(RLConnectionProgressHandlerBlockType)progressHandlerBlock
                       successHandler:(RLConnectionSuccessHandlerBlockType)successHandlerBlock
                         errorHandler:(RLConnectionErrorHandlerBlockType)errorHandlerBlock;
{
    self.urlRequest = urlRequest;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];

    if (connection)
    {
        self.requestTime = [NSDate date];
        self.connection = connection;
        self.receivedData = [NSMutableData data];
        self.progressHandler = progressHandlerBlock;
        self.sucesssHandler = successHandlerBlock;
        self.errorHandler = errorHandlerBlock;
    }
    else 
    {
        errorHandlerBlock(self.urlRequest, nil, nil);
    }
}

- (void)cleanup;
{
    // by being explicit here, we can reduce memory pressure.
    self.receivedData = nil;
    self.urlRequest = nil;
    self.urlResponse = nil;
    self.connection = nil;
    self.progressHandler = nil;
    self.sucesssHandler = nil;
    self.errorHandler = nil;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** NSURLConnectionDelegate **

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.urlResponse = response;
    self.responseTime = [NSDate date];
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.progressHandler)
        self.progressHandler(self.urlRequest, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.errorHandler)
        self.errorHandler(self.urlRequest, self.urlResponse, error);
    
    [self cleanup];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.sucesssHandler)
        self.sucesssHandler(self.urlRequest, self.urlResponse, self.receivedData);

    [self cleanup];
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Accesssors **


@end
