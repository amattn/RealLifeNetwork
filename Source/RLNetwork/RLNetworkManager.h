/*********************************************************************
 *	\file RLNetworkManager.h
 *	\author Matt Nunogawa, @amattn
 *	\date 2010/10/04
 *	\class RLNetworkManager
 *	\brief Part of RLNetwork, http://github.com/amattn/RLNetwork
 *	\details
 *
 *	\abstract CLASS_ABSTRACT 
 *	\copyright Copyright Matt Nunogawa 2010-2011. All rights reserved.
 */

#import <Foundation/Foundation.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

typedef void (^RLNetworkResponseSuccessHandlerBlockType)(NSURLRequest *request, NSURLResponse *response, NSData *responseData);
typedef void (^RLNetworkResponseErrorHandlerBlockType)(NSURLRequest *request, NSError *error);

@interface RLNetworkManager : NSObject
{
	
}

#pragma mark ** Singleton Accessors **
+ (RLNetworkManager *)singleton;

#pragma mark ** Properties **
@property (nonatomic, readonly) NSUInteger activeConnectionsCount;

#pragma mark ** GET Methods **

- (void)getRequestToURL:(NSURL *)url
		 successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
		   errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;

#pragma mark ** POST Methods **

- (void)postRequestToURL:(NSURL *)url
					data:(NSData *)postData
		  successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
			errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;

#pragma mark ** PUT Methods **

- (void)putRequestToURL:(NSURL *)url
				   data:(NSData *)putData
		 successHandler:(RLNetworkResponseSuccessHandlerBlockType)successHandlerBlock
		   errorHandler:(RLNetworkResponseErrorHandlerBlockType)errorHandlerBlock;



@end
