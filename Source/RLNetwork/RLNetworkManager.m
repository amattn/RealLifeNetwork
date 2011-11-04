/*********************************************************************
 *	\file RLNetworkManager.m
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLNetworkManager
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import "RLNetworkManager.h"
#import "RLConnection.h"

@interface RLNetworkManager ()
@property (nonatomic, retain) NSMutableDictionary *activeConnections;
@end

@implementation RLNetworkManager

#pragma mark ** Synthesis **
@synthesize activeConnections = _activeConnections;

#pragma mark ** Static Variables **
static RLNetworkManager *__sharedRLNetworkManager = nil;

#pragma mark ** Singleton **
+ (RLNetworkManager *)singleton;
#if NS_BLOCKS_AVAILABLE
{
    static dispatch_once_t createSingletonPredicate;
    dispatch_once(&createSingletonPredicate, ^
    {
        __sharedRLNetworkManager = [[RLNetworkManager alloc] init];
    });
    return __sharedRLNetworkManager;
}
#else
{
    @synchronized(self)
    {
        if (__sharedRLNetworkManager == nil)
        {
            __sharedRLNetworkManager = [[self alloc] init];
        }
    }
    return __sharedRLNetworkManager;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (__sharedRLNetworkManager == nil)
        {
            __sharedRLNetworkManager = [super allocWithZone:zone];
            return __sharedRLNetworkManager;
        }
    }
    return nil;
}
#endif

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
#pragma mark ** Basic Request Method **

- (void)httpRequestToURL:(NSURL *)url
			  httpMethod:(NSString *)httpMethod // GET, PUT or POST
					data:(NSData *)bodyData // nil for GET
		  successHandler:(RLNetworkResponseSuccessHandlerBlockType)outerSuccessHandlerBlock
			errorHandler:(RLNetworkResponseErrorHandlerBlockType)outerErrorHandlerBlock;
{
	NSMutableURLRequest *urlRequest = [RLConnection httpRequestWithURL:url
															httpMethod:httpMethod
																  data:bodyData
														  extraHeaders:nil];
	RLConnection *connection = [[RLConnection alloc] init];
	NSValue *valueKey = [NSValue valueWithPointer:&connection];

	// If we succeed, do this
	RLConnectionSuccessHandlerBlockType connectionSuccessHandler = ^(NSURLRequest *request, NSURLResponse *response, NSData *responseData)
	{
		//remove this connection from "in-flight" status
		[self.activeConnections removeObjectForKey:valueKey];
		if (outerSuccessHandlerBlock)
			outerSuccessHandlerBlock(request, response, responseData);
	};
	
	// If we fail, do this
	RLConnectionErrorHandlerBlockType connectionErrorHandler = ^(NSURLRequest *request, NSURLResponse *response, NSError *error)
	{
		//remove this connection from "in-flight" status
		[self.activeConnections removeObjectForKey:valueKey];		
		if (outerErrorHandlerBlock)
			outerErrorHandlerBlock(request, error);
	};
	
	// remember which requests are "in-flight"
	[self.activeConnections setObject:connection forKey:valueKey];
	
	// Launch the request
	[connection startHttpRequestWithURLRequest:urlRequest
								successHandler:connectionSuccessHandler
								  errorHandler:connectionErrorHandler];
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Public GET Methods **

- (void)getRequestToURL:(NSURL *)url
		 successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
		   errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;
{
	[self httpRequestToURL:url
				httpMethod:@"GET"
					  data:nil
			successHandler:successHandlerBlock
			  errorHandler:errorHandlerBlock];	
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Public POST Methods **

- (void)postRequestToURL:(NSURL *)url
					data:(NSData *)postData
		  successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
			errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;
{
	[self httpRequestToURL:url
				httpMethod:@"POST"
					  data:postData
			successHandler:successHandlerBlock
			  errorHandler:errorHandlerBlock];	
}

/*********************************************************************/
#pragma mark -
#pragma mark ** Public PUT Methods **

- (void)putRequestToURL:(NSURL *)url
				   data:(NSData *)putData
		 successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
		   errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;
{
	[self httpRequestToURL:url
				httpMethod:@"PUT"
					  data:putData
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
