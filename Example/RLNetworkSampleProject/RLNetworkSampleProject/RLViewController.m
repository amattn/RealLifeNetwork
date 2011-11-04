//
//  RLViewController.m
//  RLNetworkSampleProject
//
//  Created by Matt Nunogawa on 11/3/11.
//  Copyright (c) 2011 Matt Nunogawa. All rights reserved.
//

#import "RLViewController.h"
#import "RLNetworkManager.h"

@implementation RLViewController

@synthesize addressTextField = _addressTextField;
@synthesize getButton = _getButton;
@synthesize responseTextView = _responseTextView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)getFromAddress:(id)sender
{
	NSString *urlString = self.addressTextField.text;
	NSURL *url = [NSURL URLWithString:urlString];
	
	RLNetworkManager *networkManager = [RLNetworkManager singleton];
	
	// Do this if we succeed:
	RLNetworkResponseSuccessHandlerBlockType successHandler = ^(NSURLRequest *request, NSURLResponse *response, NSData *responseData)
	{
		NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		if (responseString)
			self.responseTextView.text = responseString;
		else
			self.responseTextView.text = [responseData description];
	};
	
	// OR do this is we fail:
	RLNetworkResponseErrorHandlerBlockType errorHandler = ^(NSURLRequest *request, NSError *error)
	{
		self.responseTextView.text = [NSString stringWithFormat:@"request failed with error: %@", error];
	};
	
	[networkManager getRequestToURL:url
					 successHandler:successHandler
					   errorHandler:errorHandler];
}

@end
