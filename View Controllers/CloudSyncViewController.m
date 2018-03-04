//
//  CloudSyncViewController.m
//  Karma
//
//  Controller that handles the view that retrieves facebook ID using facebook SDK
//  and setup a connection with Amazon Web Services (Dynamo DB) to retrive the karmas.
//  Created by Varun Ramachandran on 3/3/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "CloudSyncViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "KarmaListManager.h"

@interface CloudSyncViewController ()<FBSDKLoginButtonDelegate>

@property (weak, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation CloudSyncViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	//Add facebook login button
	FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
	loginButton.readPermissions = @[@"public_profile", @"email"];
	loginButton.delegate = self;
	loginButton.center = self.view.center;
	[self.view addSubview:loginButton];

	//Add an activity indicator to indicate user about a server response wait time
	self.spinner	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.spinner.alpha = 1.0;
	self.spinner.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
	[self.view addSubview:self.spinner];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
				error:(NSError *)error{
	// Start activity indicator
	[self.spinner startAnimating];

	__weak typeof(self) weakSelf = self;

	//Use facebook Graph APIs to retrieve user id
	NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
	[parameters setValue:@"id" forKey:@"fields"];
	[[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
	 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
								  id result, NSError *error) {
		 typeof(weakSelf) __strong strongSelf = weakSelf;
		 if (!strongSelf) {
			 NSLog(@"Lost strongSelf");
			 return;
		 }

		 if (!error) {
			 KarmaListManager *handler = [KarmaListManager sharedManager:nil];
			 [handler setIdentifier:result[@"id"] completion:^(NSArray * _Nonnull items) {
				 //Execute in main queue/ UI queue
				 dispatch_async(dispatch_get_main_queue(), ^{
					 typeof(weakSelf) __strong strongSelf = weakSelf;
					 if (!strongSelf) {
						 NSLog(@"Lost strongSelf");
						 return;
					 }
					 [strongSelf.spinner stopAnimating];
				 });
			 }];
		 }
	 }];
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
	//Reset the ID so that sync does not happen
	KarmaListManager *handler = [KarmaListManager sharedManager:nil];
	[handler setIdentifier:nil completion:nil];
}

@end
