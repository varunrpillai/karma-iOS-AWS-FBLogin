//
//  AddKarmaViewController.m
//  Karma
//
//  Controller that handles the view that allows the addition of
//  Karma item and the model that resprents the karma.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "AddKarmaViewController.h"
#import "KarmaItem.h"
#import "KarmaListManager.h"
#import "Karma-Swift.h"

@interface AddKarmaViewController ()
@property (readwrite,nullable,strong,nonatomic) KarmaItem *karma;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;



@end

@implementation AddKarmaViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Retrieve karma items from userdefaults
	
	
	//Set textfield place holder message
	int totalKarmas = 7;
	KarmaListManager *mgr = [KarmaListManager sharedManager:^(NSArray * _Nonnull karmaItems) {
		// Proactive measure: re-fetch from Cloud and render again if there was some network issue in accessing cloud last time.
		self.textField.placeholder = [NSString stringWithFormat:@"Enter your karma. You have %d karmas left.",(int) (totalKarmas - karmaItems.count)];
	}];

	NSArray *karmaItems = [mgr getKarmaItems];
	self.textField.placeholder = [NSString stringWithFormat:@"Enter your karma. You have %d karmas left.",(int) (totalKarmas - karmaItems.count)];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if (sender != self.saveButton) {
		return;
	}
	
	if (self.textField.text.length == 0) {
		return;
	}
	
	//Set the text field input as the name of karma item.
	self.karma = [[KarmaItem alloc]init];
	self.karma.itemName = self.textField.text;
}

@end
