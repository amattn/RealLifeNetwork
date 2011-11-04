//
//  RLViewController.h
//  RLNetworkSampleProject
//
//  Created by Matt Nunogawa on 11/3/11.
//  Copyright (c) 2011 Matt Nunogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLViewController : UIViewController


@property (nonatomic, strong) IBOutlet UITextField *addressTextField;
@property (nonatomic, strong) IBOutlet UIButton *getButton;
@property (nonatomic, strong) IBOutlet UITextView *responseTextView;


- (IBAction)getFromAddress:(id)sender;
@end
