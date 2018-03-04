//
//  KarmaTableViewController.m
//  Controller that handles the view that manages a list of Karmas.
//  Karma
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "KarmaTableViewController.h"
#import "KarmaItem.h"
#import "AddKarmaViewController.h"
#import "GardenProvider.h"
#import "KarmaListManager.h"
#import "CloudSyncViewController.h"

@interface KarmaTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (nonnull,strong,nonatomic) GardenProvider *provider;
@property (nonnull,strong,nonatomic) KarmaListManager *mgr;

- (IBAction)editPressed:(id)sender;

@end

@implementation KarmaTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Load saved karma items
	__weak typeof(self) weakSelf = self;
	self.mgr = [KarmaListManager sharedManager:^(NSArray * _Nonnull karmaItems) {
		typeof(weakSelf) __strong strongSelf = weakSelf;
		if (!strongSelf) {
			NSLog(@"Lost strongSelf");
			return;
		}
		//This might have loaded new Karma Items, refresh the UI.
		[strongSelf performSelectorOnMainThread:@selector(refreshUI)
									 withObject:nil
								  waitUntilDone:NO];
	}];
	
	
	
	//Initialize garden name provider
	self.provider = [[GardenProvider alloc] init];
	
	//listen to appDidEnterForeground notification to refresh the list
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(appDidEnterForeground:) name:@"appDidEnterForeground" object:nil];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)appDidEnterForeground:(UIApplication *)application
{
	[self refreshUI];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.mgr.getKarmaItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KarmaListCell" forIndexPath:indexPath];
	KarmaItem *item = self.mgr.getKarmaItems[indexPath.row];
	cell.textLabel.text = item.itemName;
	cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
	cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
	if (item.completed) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	NSMutableArray *items = self.mgr.getKarmaItems;
	KarmaItem *item = items[indexPath.row];
	item.completed = !item.completed;
	if (item.completed) {
		item.completedDate = [NSDate date];
	} else {
		//Reset
		item.completedDate = nil;
	}
	[self.mgr replaceKarma:items];
	[self refreshUI];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	self.editButton.title = self.editing?  @"Done" : @"Edit";
	self.addButton.enabled = !self.editing;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.editing) {
		return NO;
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		NSMutableArray *karmaItems = self.mgr.getKarmaItems;
		[karmaItems removeObject:karmaItems[indexPath.row]];
		[self.mgr replaceKarma:karmaItems];
		[self refreshUI];
	}
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *karmaItems = self.mgr.getKarmaItems;
	KarmaItem *karmaToMove = [karmaItems objectAtIndex:fromIndexPath.row];
	[karmaItems removeObject:karmaItems[fromIndexPath.row]];
	[karmaItems insertObject:karmaToMove atIndex:toIndexPath.row];
	[self.mgr replaceKarma:karmaItems];
	[self refreshUI];
}


#pragma mark - Navigation

- (IBAction)unwindToKarmaList:(UIStoryboardSegue *)segue {
	
	if ([[segue sourceViewController] isKindOfClass:[AddKarmaViewController class]]) {
		AddKarmaViewController *controller = [segue sourceViewController];
		if (controller.karma) {
			NSMutableArray *karmaItems = self.mgr.getKarmaItems;
			[karmaItems addObject:controller.karma];
			[self.mgr replaceKarma:karmaItems];
			[self refreshUI];
		}
	}
	if ([[segue sourceViewController] isKindOfClass:[CloudSyncViewController class]]) {
		[self refreshUI];
	}
}

- (IBAction)editPressed:(id)sender {
	KarmaListManager *mgr = [KarmaListManager sharedManager:NULL];
	NSArray *karmaItems = [mgr getKarmaItems];
	if (!self.editing && karmaItems.count == 0) {
		return;
	}
	[self setEditing:!self.editing animated:YES];
}

// Handles UI refresh
- (void) refreshUI
{
	NSMutableArray *karmaItems = [self.mgr getKarmaItems];

	[self resetCompletedState];
	
	//Set the garden image based on number of completed items currently
	NSArray *completedItems = [karmaItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"completed == YES"]];
	NSString *gardenImage = [self.provider getGardenImageNameForKarmas:(int)karmaItems.count completed:(int)completedItems.count];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:gardenImage]];
	backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
	self.tableView.backgroundView = backgroundImage;
	
	
	//If there are more than 7 karma items, disable add button
	if (7 <= karmaItems.count) {
		self.addButton.enabled = NO;
	} else if (!self.editing) {
		self.addButton.enabled = YES;
	}
	
	//Reload list view
	[self.tableView reloadData];
}

// App is a daily tracker. Reset completed state if the date is yesterday
- (void) resetCompletedState {
	NSMutableArray *karmaItems = [self.mgr getKarmaItems];

	//If the app is opened past midnight, reset the completed status of karma items
	NSCalendar* calendar = [NSCalendar currentCalendar];
	BOOL changed = NO;
	for (KarmaItem *item in karmaItems) {
		if (item.completedDate && ![calendar isDateInToday:item.completedDate]) {
			item.completedDate = nil;
			item.completed = NO;
			changed = YES;
		}
	}

	if (changed) {
		[self.mgr replaceKarma:karmaItems];
	}
}

@end
