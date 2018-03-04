//
//  KarmaList.m
//  Karma
//
// The model is a singleton that stores and handles list of Karmas.
// It saves data locally or in cloud.
// It also retrieves data from cloud on installation.
//
//  Created by Varun Ramachandran on 3/2/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "KarmaListManager.h"
#import "Karma-Swift.h"
#import "KarmaItem.h"
#import "Reachability.h"


@interface KarmaListManager ()

@property NSMutableArray *karmaItems;
@property (atomic) BOOL downloadSync;
@property (nonatomic) NSString *identifier;

@end


@implementation KarmaListManager

+ (id)sharedManager:(nullable void (^)(NSArray * __nonnull))completion {
	static KarmaListManager *sharedList = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedList = [[self alloc] init:completion];
	});
	return sharedList;
}

- (id)init
{
	return [KarmaListManager sharedManager:nil];
}

- (id)init:(nullable void (^)(NSArray * __nonnull))completion {
	if (self = [super init]) {
		self.downloadSync = [[NSUserDefaults standardUserDefaults] boolForKey:@"download_synced"];
		[self loadKarmaItems:completion];
	}	return self;
}

- (void) loadKarmaItems:(nullable void (^)(NSArray * __nonnull))completion {
	self.karmaItems = [[NSMutableArray alloc] init];
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"karmaItems"];
	if (data) {
		self.karmaItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		if (completion) {
			completion(self.karmaItems);
			//Completion is called. If retrieved from cloud, dont call completion.
			completion = nil;
		}
	}
	if (!self.downloadSync) {
		//See if data exists in the cloud
		[self retrieveFromAWS:completion];
	}
}

- (NSMutableArray*) getKarmaItems {
	return self.karmaItems;
}

- (void) replaceKarma:(NSMutableArray*) karmaItems {
	//even if cloud sync is not completed, still allowing caller to modify DS.
	self.karmaItems = karmaItems;
	[self saveItems];
}

- (void) saveItems {
	//Save items to local storage
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.karmaItems];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"karmaItems"];

	//Save NSData object of items to cloud
	if (0 < self.identifier.length) {
		NSMutableSet *karmaSet = [NSMutableSet setWithObjects:data, nil];
		CloudDbHandler *cloud = [CloudDbHandler sharedInstance];
		//Create and update can use the same createKarmaWithId API
		[cloud createKarmaWithId:self.identifier karmaSet:karmaSet];
	}
}

- (void) setIdentifier:(NSString*) id completion:(nullable void (^)(NSArray * __nonnull))completion {

	_identifier = id;

	if (id == nil) {
		//sync is disabled. Available for resync.
		self.downloadSync = NO;
	} else {
		//Retrieve using new id
		[self retrieveFromAWS:completion];
	}
}

- (void) retrieveFromAWS:(nullable void (^)(NSArray * __nonnull))completion {
	//If network connection is disabled, return.
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable)
	{
		NSLog(@"No network connection. Go ahead with local changes");
		return;
	}

	//If not yet downloaded and id is valid
	if (!self.downloadSync && 0 < self.identifier.length) {
		//Query from cloud
		CloudDbHandler *cloud = [CloudDbHandler sharedInstance];
		[cloud queryKarmasWithId:self.identifier onCompletion:^(NSSet<NSData *> * _Nonnull karmaSet) {
			NSData *data = [karmaSet anyObject];
			if (data != NULL) {
				//Retrieve items from data
				NSMutableArray *items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
				if (0 < items.count && self.karmaItems.count == 0) {
					// if there are no new items added locally before sync,
					// set the received items as items.
					self.karmaItems = items;
				} else {
					// if there are new items added locally before sync,
					// keep the new ones and add rest of the items from the receiving list.
					// The max number of items is 7.
					int pickKarmaCount = (int) (7 - self.karmaItems.count);
					[self.karmaItems addObjectsFromArray:[items subarrayWithRange:NSMakeRange(0, MIN(pickKarmaCount-1, items.count-1))]];
				}
				// Persist the new list.
				[self saveItems];
			}
			// no need for another download sync.
			self.downloadSync = YES;

			if (completion) {
				completion(self.karmaItems);
			}
		}];
	} else {
		if (completion) {
			completion(self.karmaItems);
		}
	}
}
@end
