/*********************************************************************
 *	\file RLConnection.m
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLConnection
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import "RLConnection.h"

#define DEFAULT_TIMEOUT 300

@interface RLConnection ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLResponse *urlResponse;
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

- (void)startHttpRequestWithURLRequest:(NSURLRequest *)urlRequest
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
	self.receivedData = nil;
	self.urlRequest = nil;
	self.urlResponse = nil;
	self.connection = nil;
	self.sucesssHandler = nil;
	self.errorHandler = nil;
}

/*********************************************************************/
#pragma mark -
#pragma mark ** NSURLConnection Delegate Methods **

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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	self.totalBytesWritten = totalBytesWritten;
}

// Customize here if necessary
// - (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
// {
// 	return cachedResponse;
// }

// Customize here if necessary
// - (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
// {
// 	return NO;
// }

/*********************************************************************/
#pragma mark -
#pragma mark ** Accesssors **


@end
